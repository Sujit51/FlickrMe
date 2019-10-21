//
//  SearchViewController.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import UIKit

final class SearchImageViewController: UIViewController {
    
    private let photosPerRow: CGFloat = 3.0
    private let sectionInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    
    private var searchTerm: String = ""
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var emptyView: UIView?
    @IBOutlet weak var photosCollectionView: UICollectionView?
    
    private var viewModel: PhotoSearchResultViewModel!
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSearchController()
        viewModel = PhotoSearchResultViewModel.init(delegate: self)
        photosCollectionView?.reloadData()
    }
    
    private func setupSearchController() {
        
        // Search bar related UI setup
        searchController.searchResultsUpdater = self
        self.navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true
    }
    
    private func showAlert(withMessage message: String) {
        
        // Common alert display logic
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "Retry", style: .default, handler: { (action) in
            self.triggerSearch()
        }))
        
        self.present(alert, animated: true)
    }
    
    private func showEmptyOrLoadingViewIfNeeded() {
        
        // Logic to determine whether to show empty screen, activity indicator, or results
        guard let viewModel = viewModel,
            let collectionView = photosCollectionView,
            let activityIndicator = activityIndicator else { return }
        
        if let emptyView = emptyView, searchTerm.count < 2 {
            self.view.bringSubviewToFront(emptyView)
        }
        else if viewModel.isSearchInProgress && viewModel.currentCount == 0 {
            self.view.bringSubviewToFront(collectionView)
            self.view.bringSubviewToFront(activityIndicator)
            activityIndicator.startAnimating()
        } else {
            self.view.bringSubviewToFront(collectionView)
        }
    }
}

// MARK: - UICollectionViewDataSource and UICollectionViewDelegate
extension SearchImageViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        showEmptyOrLoadingViewIfNeeded()
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfItemsInSection(section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as PhotoViewCell
        
        let photo = viewModel?.photo(atIndexPath: indexPath)
        cell.configure(with: photo)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel?.beginDownloadingPhoto(forIndexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel?.pauseDownloadingPhoto(forIndexPath: indexPath)
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension SearchImageViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        guard let viewModel = viewModel else { return }
        let isLoadingCell = indexPaths.contains { (indexPath) -> Bool in
            return indexPath.item >= viewModel.currentCount
        }

        if isLoadingCell {
            viewModel.search(term: searchTerm)
        }
    }
    
    func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.item >= viewModel.currentCount
    }
}

// MARK: - Collection View Flow Layout Delegate
extension SearchImageViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (photosPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / photosPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

// MARK: - UISearchResultsUpdating
extension SearchImageViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        // Throttle inputs by delaying search 0.5 sec and atleast 2 characters
        if searchController.searchBar.text?.isEmpty == false  {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reloadSearch), object: nil)
            self.perform(#selector(self.reloadSearch), with: nil, afterDelay: 0.5)
        } else {
            reloadSearch()
        }
    }
    
    @objc func reloadSearch() {
        guard let searchText = searchController.searchBar.text, searchTerm != searchText else { return }
        searchTerm = searchText
        triggerSearch(isFreshSearch: true)
        photosCollectionView?.reloadData()
    }
    
    private func triggerSearch(isFreshSearch: Bool = false) {
        viewModel.search(term: searchTerm, isFreshSearch: isFreshSearch)
        activityIndicator?.startAnimating()
    }
}

// MARK: - PhotoSearchResultViewModelDelegate
extension SearchImageViewController: PhotoSearchResultViewModelDelegate {
    
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
        guard let newIndexPathsToReload = newIndexPathsToReload else {
            activityIndicator?.stopAnimating()
            photosCollectionView?.isHidden = false
            photosCollectionView?.reloadData()
            return
        }
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
        photosCollectionView?.reloadItems(at: indexPathsToReload)
    }
    
    func onFetchFailed(with reason: String) {
        searchController.searchBar.endEditing(true)
        activityIndicator?.stopAnimating()
        showAlert(withMessage: reason)
    }
    
    func onDownloadingImage(_ image: UIImage, forIndexPath indexPath: IndexPath) {
        let indexPathsToReload = visibleIndexPathsToReload(intersecting: [indexPath])
        photosCollectionView?.reloadItems(at: indexPathsToReload)
    }
    
    func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
        let indexPathsForVisibleRows = photosCollectionView?.indexPathsForVisibleItems ?? []
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        return Array(indexPathsIntersection)
    }
}

// MARK: - UIScrollViewDelegate
extension SearchImageViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.endEditing(true)
    }
}
