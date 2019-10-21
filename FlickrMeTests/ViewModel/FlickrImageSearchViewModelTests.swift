//
//  FlickrImageSearchViewModelTests.swift
//  FlickrMeTests
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import XCTest
@testable import FlickrMe

class FlickrImageSearchViewModelTests: XCTestCase {
    
    private var viewModel: FlickrImageSearchViewModel!
    private var mockNetworkManager: NetworkManagerMock!
    private var mockDelegate: MockFlickrImageSearchViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = NetworkManagerMock()
        mockDelegate = MockFlickrImageSearchViewModelDelegate()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOnFailedFetchDelegateIsInformed() {
        // given
        viewModel = FlickrImageSearchViewModel.init(networkManager: mockNetworkManager, delegate: mockDelegate)
        let expectation = self.expectation(description: "Fetch completion")
        
        // when
        mockNetworkManager.simulateError = true
        viewModel.search(term: "Something", isFreshSearch: true)
        
        // then
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(mockDelegate.onFetchFailedCalled)
    }
    
    func testOnSuccessfulFetchDelegateIsInformed() {
        // given
        viewModel = FlickrImageSearchViewModel.init(networkManager: mockNetworkManager, delegate: mockDelegate)
        let expectation = self.expectation(description: "Fetch completion")
        
        // when
        mockNetworkManager.simulateError = false
        viewModel.search(term: "Something", isFreshSearch: true)
        
        // then
        // now trigger - we can look for variable value now
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(mockDelegate.onFetchCompletedCalled)
    }
    
    func testOnSuccessfulImageDownloadDelegateIsInformed() {
        // given
        viewModel = FlickrImageSearchViewModel.init(networkManager: mockNetworkManager, delegate: mockDelegate)
        let expectation = self.expectation(description: "Fetch completion")
        
        // when
        mockNetworkManager.simulateError = false
        viewModel.search(term: "Something", isFreshSearch: true) // has atleast on test photo
        
        DispatchQueue.main.async {
            self.viewModel.beginDownloadingImage(forIndexPath: .init(item: 0, section: 0))
            
            // now trigger - we can look for variable value now
            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }
        
        // then
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(mockDelegate.onDownloadingImageCalled)
    }
}

private class MockFlickrImageSearchViewModelDelegate: FlickrImageSearchViewModelDelegate {
    
    var onFetchCompletedCalled = false
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        onFetchCompletedCalled = true
    }
    
    var onFetchFailedCalled = false
    func onFetchFailed(with reason: String) {
        onFetchFailedCalled = true
    }
    
    var onDownloadingImageCalled = false
    func onDownloadingImage(_ image: UIImage, forIndexPath indexPath: IndexPath) {
        onDownloadingImageCalled = true
    }
}

private class NetworkManagerMock: NetworkManager {
    
    var simulateError: Bool = false
    override func searchPhotos(withTerm term: String, page: Int, completion: @escaping (Result<PhotoSearchResult, Error>) -> ()) {
        if simulateError {
            completion(.failure(NetworkManagerMockError.testError))
        } else {
            completion(.success(NetworkManagerMock.testResultObject))
        }
    }
    
    override func beginDownloadingImage(for imageInfo: FlickrImage, completion: @escaping (Result<UIImage, Error>) -> ()) {
        if simulateError {
            completion(.failure(NetworkManagerMockError.testError))
        } else {
            completion(.success(UIImage()))
        }
    }
    
    private enum NetworkManagerMockError: String, Error {
        case testError = "This is a test error message"
    }
    
    static var testResultObject: PhotoSearchResult = PhotoSearchResult.init(page: 1, numberOfPages: 123, photosPerPage: 10, numberOfResults: "3000", photos: [sampleImageInfo])
    
    static let sampleImageInfo: FlickrImage = FlickrImage(image: nil, id: "Test id", title: "Title", owner: "owner", farm: 123, secret: "secret", server: "server")
}
