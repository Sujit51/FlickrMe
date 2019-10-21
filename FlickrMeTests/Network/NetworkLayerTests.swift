//
//  NetworkLayerTests.swift
//  FlickrMeTests
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import Foundation

import XCTest
@testable import FlickrMe

class NetworkLayerTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testURLEncoding() {
        guard let url = URL(string: "https:www.google.com/") else {
            XCTAssertTrue(false, "Could not instantiate url")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        let parameters: Parameters = [
            "UserID": 1,
            "Name": "Malcolm",
            "Email": "malcolm@network.com",
            "IsCool": true
        ]
        
        do {
            try URLParameterEncoder.encode(urlRequest: &urlRequest, with: parameters)
            guard let fullURL = urlRequest.url else {
                XCTAssertTrue(false, "urlRequest url is nil.")
                return
            }
            let expectedURL = "https:www.google.com/?Name=Malcolm&Email=malcolm%2540network.com&UserID=1&IsCool=true"
            XCTAssertEqual(fullURL.absoluteString.sorted(), expectedURL.sorted())
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testJSONEncoding() {
        guard let url = URL(string: "https:www.google.com/") else {
            XCTAssertTrue(false, "Could not instantiate url")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        let parameters: Parameters = [
            "UserID": 1,
            "Name": "Malcolm",
            "Email": "malcolm@network.com",
            "IsCool": true
        ]
        
        do {
            try JSONParameterEncoder.encode(urlRequest: &urlRequest, with: parameters)
            guard let fullURL = urlRequest.url else {
                XCTFail("urlRequest url is nil.")
                return
            }
            let expectedURL = "https:www.google.com/"
            XCTAssertEqual(fullURL.absoluteString.sorted(), expectedURL.sorted())
            
            guard let body = urlRequest.httpBody else {
                XCTFail("body in urlRequest is nil.")
                return
            }
            
            let json = try JSONSerialization.jsonObject(with: body, options: .mutableContainers)
            XCTAssertNotNil(json, "Unable to deserialize json")
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
