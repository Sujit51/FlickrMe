//
//  SearchImageViewControllerTests.swift
//  FlickrMeTests
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import XCTest
@testable import FlickrMe

class SearchImageViewControllerTests: XCTestCase {
    
    func testControllerCanBeLoadedFromStoryboard() {
        // when
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as? UINavigationController
        let topController = controller?.topViewController as? SearchImageViewController
        
        // then
        XCTAssertNotNil(controller)
        XCTAssertNotNil(topController)
    }
}
