//
//  ImageTask.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import UIKit

public typealias ImageTaskCompletion = (_ imageTask: ImageTask?, _ image: UIImage?,_ error: Error?) -> ()

public class ImageTask {
    
    let session: URLSession
    let url: URL
    let completion: ImageTaskCompletion?
    
    private var isDownloading = false
    private var isFinishedDownloading = false
    
    private var task: URLSessionDownloadTask?
    private var resumeData: Data?
    
    init(url: URL, session: URLSession, completion: @escaping ImageTaskCompletion) {
        self.url = url
        self.session = session
        self.completion = completion
    }
    
    func resume() {
        if !isDownloading && !isFinishedDownloading {
            isDownloading = true
            
            if let resumeData = resumeData {
                
                task = session.downloadTask(withResumeData: resumeData, completionHandler: downloadTaskCompletionHandler)
            } else {
                task = session.downloadTask(with: url, completionHandler: downloadTaskCompletionHandler)
            }
            task?.resume()
        }
    }
    
    func pause() {
        if isDownloading && !isFinishedDownloading {
            task?.cancel(byProducingResumeData: { (data) in
                self.resumeData = data
            })
            
            self.isDownloading = false
        }
    }
    
    private func downloadTaskCompletionHandler(url: URL?, response: URLResponse?, error: Error?) {
        if let error = error {
            self.completion?(self, nil, error)
            return
        }
        
        guard let url = url else {
            self.completion?(self, nil, ImageDownloadError.missingURL)
            return
        }
        
        guard let data = FileManager.default.contents(atPath: url.path) else {
            self.completion?(self, nil, ImageDownloadError.missingImageData)
            return
        }
        
        guard let image = UIImage(data: data) else {
            self.completion?(self, nil, ImageDownloadError.invalidData)
            return
        }
        
        self.completion?(self, image, nil)
        self.isFinishedDownloading = true
    }
}

extension ImageTask: Hashable {
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(self.url.hashValue)
    }
}

extension ImageTask: Equatable {
    public static func == (lhs: ImageTask, rhs: ImageTask) -> Bool {
        return lhs.url == rhs.url
    }
}

public enum ImageDownloadError: String, Error {
    case invalidData = "Unable to create image from data."
    case missingImageData = "Image data is missing."
    case missingURL = "URL is nil"
}
