//
//  NetworkEndpoint.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import UIKit

public typealias NetworkEndpointCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()

protocol NetworkEndpoint: class {
    associatedtype E: EndpointType
    func request(_ endpoint: E, completion: @escaping NetworkEndpointCompletion)
    func cancel()
}

class Endpoint<E: EndpointType>: NetworkEndpoint {
    
    let session: URLSession
    private var task: URLSessionTask?
    
    init(session: URLSession? = .shared) {
        self.session = session ?? .shared
    }
    
    func request(_ endpoint: E, completion: @escaping NetworkEndpointCompletion) {
        do {
            let request = try self.createRequest(from: endpoint)
            task = session.dataTask(with: request, completionHandler: completion)
        } catch {
            completion(nil, nil, error)
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    private func createRequest(from endpoint: E) throws -> URLRequest {
        
        var request = URLRequest.init(url: endpoint.baseURL.appendingPathComponent(endpoint.path),
                                      cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                      timeoutInterval: 60.0)
        
        request.httpMethod = endpoint.httpMethod.rawValue
        
        do {
            switch endpoint.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
            case .requestParameters(let bodyParams, let urlParams):
                try self.configureParameters(bodyParameters: bodyParams, urlParameters: urlParams, request: &request)
                
            case .requestParametersAndHeaders(let bodyParams, let urlParams, let headers):
                self.addAdditionalHeaders(additionalHeaders: headers, request: &request)
                
                try self.configureParameters(bodyParameters: bodyParams, urlParameters: urlParams, request: &request)
            }
            return request
            
        } catch {
            throw error
        }
    }
    
    private func configureParameters(bodyParameters: Parameters?, urlParameters: Parameters?, request: inout URLRequest) throws {
        
        do {
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }
    
    private func addAdditionalHeaders(additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
