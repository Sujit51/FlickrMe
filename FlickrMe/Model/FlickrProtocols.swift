//
//  FlickrProtocols.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import UIKit

protocol FlickrImageSearchViewModelDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func onFetchFailed(with reason: String)
    func onDownloadingImage(_ image: UIImage, forIndexPath indexPath: IndexPath)
}

protocol FlickrImageSearchViewDelegate {
    var isSearchInProgress: Bool { get }
    func search(term: String)
    func search(term: String, isFreshSearch: Bool)
    func pauseDownloadingImage(forIndexPath indexPath: IndexPath)
    func beginDownloadingImage(forIndexPath indexPath: IndexPath)
}

protocol FlickrImageSearchViewDataSource {
    var currentCount: Int { get }
    func numberOfSections() -> Int
    func numberOfItemsInSection(_ section: Int) -> Int
    func imageInfo(atIndexPath indexPath: IndexPath) -> FlickrImage?
}

extension FlickrImageSearchViewDelegate {
    func search(term: String) {
        self.search(term: term, isFreshSearch: false)
    }
}
