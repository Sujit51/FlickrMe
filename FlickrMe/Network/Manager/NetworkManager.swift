//
//  NetworkManager.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import UIKit

enum NetworkEnvironment {
    case production
    // Scope to add staging, development etc
}

class NetworkManager {
    
    static let environment: NetworkEnvironment = .production
    
    // Can be secured by sourcing from environment variable
    static let flickrAPIKey = "3e7cc266ae2b0e0d78e279ce8e361736"
    
    private let flickrEndpoint = Endpoint<FlickrApi>()
    private let imageDownloader = ImageDownloader<FlickrPhotoDownloadEndpoint>(session: .shared)
    
    func searchPhotos(withTerm term: String, page: Int, completion: @escaping (Result<PhotoSearchResult, Error>) -> ()) {
        
        flickrEndpoint.request(.search(term: term, page: page)) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(.failure(NetworkResponse.noData))
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(PhotoSearchRespose.self, from: responseData)
                        completion(.success(apiResponse.photos))
                    } catch {
                        completion(.failure(NetworkResponse.unableToDecode))
                    }
                case .failure(let networkFailureError):
                    completion(.failure(networkFailureError))
                }
            }
        }
    }
    
    func beginDownloadingImage(for imageInfo: FlickrImage, completion: @escaping (Result<UIImage, Error>) -> ()) {
        
        imageDownloader.request(.image(with: imageInfo, size: .sqare)) { (image, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let image = image {
                completion(.success(image))
                return
            }
            
            completion(.failure(NetworkResponse.noData))
        }
    }
    
    func pauseDownloadingImage(for imageInfo: FlickrImage) {
        imageDownloader.pause(for: .image(with: imageInfo, size: .sqare))
    }
    
    private func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<NetworkResponse, NetworkResponse> {
        switch response.statusCode {
        case 200...299: return .success(.success)
        case 401...500: return .failure(NetworkResponse.authenticationError)
        case 501...599: return .failure(NetworkResponse.badRequest)
        case 600: return .failure(NetworkResponse.outdated)
        default: return .failure(NetworkResponse.failed)
        }
    }
}

enum NetworkResponse: String, Error {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}
