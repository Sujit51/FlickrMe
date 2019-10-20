//
//  FlickrEndpoint.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import Foundation

public enum FlickrApi {
    case search(term: String, page: Int)
}

extension FlickrApi: EndpointType {
    
    var environmentBaseURL: String {
        switch NetworkManager.environment {
        case .production:
            return "https://api.flickr.com/"
        }
        // Scope for adding staging, qa environments with switch cases
    }
    
    var baseURL: URL {
        guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.") }
        return url
    }
    
    var path: String {
        return "services/rest/"
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    private var urlParameters: [String: String] {
        switch self {
        case .search(let term, let page):
            return ["text": term,
                    "page": "\(page)",
                    "method": "flickr.photos.search",
                    "api_key": NetworkManager.flickrAPIKey,
                    "format": "json",
                    "nojsoncallback": "1",
                    "safe_search": "1"]
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .search:
            return .requestParameters(bodyParameters: nil, urlParameters: urlParameters)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
