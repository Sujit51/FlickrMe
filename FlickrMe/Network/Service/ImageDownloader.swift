//
//  ImageDownloader.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import UIKit

public typealias ImageDownloadCompletion = (_ image: UIImage?,_ error: Error?) -> ()

protocol ImageDownloadable: class {
    associatedtype E: EndpointType
    func request(_ endpoint: E, completion: @escaping ImageDownloadCompletion)
    func pause(for endpoint: E)
}

class ImageDownloader<E: EndpointType>: ImageDownloadable {
    
    let session: URLSession
    private var tasks: Set<ImageTask> = []
    
    init(session: URLSession? = .shared) {
        self.session = session ?? .shared
    }
    
    func request(_ endpoint: E, completion: @escaping ImageDownloadCompletion) {
        guard let url = createRequest(from: endpoint).url else {
            completion(nil, NetworkError.missingURL)
            return
        }
        let task: ImageTask
        if let found = tasks.first(where: { (imageTask) -> Bool in
            return imageTask.url == url
        }) {
            task = found
        } else {
            task = ImageTask.init(url: url, session: session) { [weak self] (imageTask, image, error) in
                
                guard let self = self else {
                    completion(image, error)
                    return
                }
                
                DispatchQueue.main.async {
                    if let completedTask = imageTask, self.tasks.contains(completedTask) {
                        self.tasks.remove(completedTask)
                    }
                }
                completion(image, error)
            }
            self.tasks.insert(task)
        }
        
        task.resume()
    }
    
    private func createRequest(from endpoint: E) -> URLRequest {
        
        var request = URLRequest.init(url: endpoint.baseURL.appendingPathComponent(endpoint.path),
                                      cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,  // comeback to this
            timeoutInterval: 60.0)
        
        request.httpMethod = endpoint.httpMethod.rawValue
        return request
    }
    
    func pause(for endpoint: E) {
        guard let url = createRequest(from: endpoint).url else { return }
        let task = self.tasks.first{$0.url == url}
        task?.pause()
    }
}
