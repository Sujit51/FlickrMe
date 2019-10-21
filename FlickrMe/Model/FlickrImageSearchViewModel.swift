//
//  FlickrImageSearchViewModel.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import UIKit

final class FlickrImageSearchViewModel: FlickrImageSearchViewDelegate, FlickrImageSearchViewDataSource {
    
    private let networkManager: NetworkManager
    private weak var delegate: FlickrImageSearchViewModelDelegate?
    
    private(set) public var isSearchInProgress = false
    var currentCount: Int {
        return imagesInfo.count
    }
    
    private var currentPage: Int = 0
    private var totalResults: Int = 0
    private var pageCount: Int = 0
    private var imagesInfo: [FlickrImage] = []
    
    init(networkManager: NetworkManager = NetworkManager(), delegate: FlickrImageSearchViewModelDelegate?) {
        self.networkManager = networkManager
        self.delegate = delegate
    }
    
    // FlickrImageSearchViewDataSource methods
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return totalResults > 20000 ? 20000 : 0        // Because after 20,000 collection view scrollong gets jerky
    }
    
    func imageInfo(atIndexPath indexPath: IndexPath) -> FlickrImage? {
        guard indexPath.item < imagesInfo.count else { return nil }
        return imagesInfo[indexPath.item]
    }
    
    // MARK: - FlickrImageSearchViewDelegate methods
    func search(term: String, isFreshSearch: Bool = false) {
        
        guard !term.isEmpty, term.count > 1 else {
            reset()
            return
        }
        
        guard !isSearchInProgress else { return }
        isSearchInProgress = true
        
        if isFreshSearch { reset() }
        
        networkManager.searchPhotos(withTerm: term, page: currentPage + 1) { (result) in
            switch result {
            case .success(let searchResult):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.isSearchInProgress = false
                    self.currentPage = searchResult.page
                    if self.currentPage == 1 {
                        self.totalResults = Int(searchResult.numberOfResults) ?? 0
                    }
                    self.pageCount = searchResult.numberOfPages
                    self.imagesInfo.append(contentsOf: searchResult.photos)
                    if searchResult.page > 1 {
                        let indexPathsToReload = self.calculateIndexPathsToReload(from: searchResult.photos)
                        self.delegate?.onFetchCompleted(with: indexPathsToReload)
                    } else {
                        self.delegate?.onFetchCompleted(with: .none)
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.isSearchInProgress = false
                    self.delegate?.onFetchFailed(with: error.localizedDescription)
                }
            }
        }
    }
    
    func beginDownloadingImage(forIndexPath indexPath: IndexPath) {
        guard indexPath.item < imagesInfo.count else { return }
        
        let photo = imagesInfo[indexPath.item]
        guard photo.image == nil else { return }
        networkManager.beginDownloadingImage(for: photo) { (result) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self, indexPath.item < self.imagesInfo.count else { return }
                
                switch result {
                case .success(let image):
                    self.imagesInfo[indexPath.item].image = image
                    self.delegate?.onDownloadingImage(image, forIndexPath: indexPath)
                case .failure:
                    self.imagesInfo[indexPath.item].image = UIImage(named: "warning")
                }
            }
        }
    }
    
    func pauseDownloadingImage(forIndexPath indexPath: IndexPath) {
        guard indexPath.item < imagesInfo.count else { return }
        
        let imageInfo = imagesInfo[indexPath.item]
        networkManager.pauseDownloadingImage(for: imageInfo)
    }
    
    private func reset() {
        currentPage = 0
        totalResults = 0
        pageCount = 0
        imagesInfo = []
    }
    
    private func calculateIndexPathsToReload(from newPhotos: [FlickrImage]) -> [IndexPath] {
        let startIndex = imagesInfo.count - newPhotos.count
        let endIndex = startIndex + newPhotos.count
        return (startIndex..<endIndex).map { IndexPath(item: $0, section: 0) }
    }
}
