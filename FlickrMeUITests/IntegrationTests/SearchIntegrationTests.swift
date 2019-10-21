//
//  SearchIntegrationTests.swift
//  FlickrMeUITests
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import XCTest

class SearchIntegrationTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func testEmptyPageOnLaunch() {
        let welcomeLabel = app.staticTexts["Search something, like: Cats"]
        XCTAssertEqual(welcomeLabel.exists, true)
    }
    
    func testCanEnterSearchTerm() {
        let searchfeild = app.searchFields["Search"]
        XCUIApplication().navigationBars["FlickrMe.SearchImageView"].searchFields["Search"].tap()

        XCTAssertEqual(searchfeild.exists, true)
        
        searchfeild.typeText("Cats")
    }
}
