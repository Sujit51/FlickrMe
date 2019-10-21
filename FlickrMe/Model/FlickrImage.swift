//
//  FlickrImage.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import UIKit

struct FlickrImage: Decodable {
    var image: UIImage?
    let id: String
    let title: String
    let owner: String
    let farm: Int
    let secret: String
    let server: String
    
    init(image: UIImage?, id: String, title: String, owner: String, farm: Int, secret: String, server: String) {
        self.image = image
        self.id = id
        self.title = title
        self.owner = owner
        self.farm = farm
        self.secret = secret
        self.server = server
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case owner
        case farm
        case secret
        case server
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        owner = try container.decode(String.self, forKey: .owner)
        farm = try container.decode(Int.self, forKey: .farm)
        secret = try container.decode(String.self, forKey: .secret)
        server = try container.decode(String.self, forKey: .server)
    }
}
