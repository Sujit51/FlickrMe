//
//  FlickrPhotoDownloadEndpoint.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import Foundation

struct FlickrPhotoDownloadEndpoint: EndpointType {
    private let photo: FlickrPhoto
    
    var baseURL: URL {
        guard let url = URL(string: "https://farm\(photo.farm).static.flickr.com/") else { fatalError("baseURL could not be configured.") }
        return url
    }
    
    var path: String {
        return "\(photo.server)/\(photo.id)_\(photo.secret).jpg"
    }
    
    var httpMethod: HTTPMethod { return .get }
    var task: HTTPTask { return .request }
    var headers: HTTPHeaders? { return nil }
    
    init(photo: FlickrPhoto) {
        self.photo = photo
    }
}
