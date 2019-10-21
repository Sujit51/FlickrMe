//
//  PhotoSearchRespose.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import Foundation

struct PhotoSearchRespose: Decodable {
    let photos: PhotoSearchResult
}

struct PhotoSearchResult {
    let page: Int
    let numberOfPages: Int
    let photosPerPage: Int
    let numberOfResults: String
    let photos: [FlickrImage]
}

extension PhotoSearchResult: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case page
        case numberOfPages = "pages"
        case photosPerPage = "perpage"
        case numberOfResults = "total"
        case photos = "photo"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        page = try container.decode(Int.self, forKey: .page)
        numberOfPages = try container.decode(Int.self, forKey: .numberOfPages)
        photosPerPage = try container.decode(Int.self, forKey: .photosPerPage)
        numberOfResults = try container.decode(String.self, forKey: .numberOfResults)
        photos = try container.decode([FlickrImage].self, forKey: .photos)
    }
}
