//
//  FlickrPhotoDownloadEndpoint.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import Foundation

public enum ImageSize: String {
    case thumbnail = "t"
    case sqare = "q"
    // Scope for other sizes here
}

enum FlickrPhotoDownloadEndpoint {
    case image(with: FlickrImage, size: ImageSize)
}

extension FlickrPhotoDownloadEndpoint: EndpointType {

    var baseURL: URL {
        switch self {
        case .image(let imageInfo, _):
            guard let url = URL(string: "https://farm\(imageInfo.farm).static.flickr.com/") else { fatalError("baseURL could not be configured.") }
            return url
        }
    }
    
    var path: String {
        switch self {
        case .image(let imageInfo, let imageSize):
            return "\(imageInfo.server)/\(imageInfo.id)_\(imageInfo.secret)_\(imageSize.rawValue).jpg"
        }
    }
    
    var httpMethod: HTTPMethod { return .get }
    var task: HTTPTask { return .request }
    var headers: HTTPHeaders? { return nil }
}
