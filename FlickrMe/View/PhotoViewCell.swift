//
//  PhotoViewCell.swift
//  FlickrMe
//
//  Created by Sujit Yadawad
//  Copyright © 2019 Sujit Yadawad. All rights reserved.
//

import UIKit

final class PhotoViewCell: UICollectionViewCell {
    @IBOutlet weak var flickrImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func prepareForReuse() {
        flickrImageView?.image = nil
        titleLabel?.text = nil
        activityIndicator?.isHidden = false
        activityIndicator?.startAnimating()
        super.prepareForReuse()
    }
    
    func configure(with photo: FlickrImage?) {
        guard let photo = photo else {
            activityIndicator?.isHidden = false
            activityIndicator?.startAnimating()
            return
        }
        activityIndicator?.stopAnimating()
        activityIndicator?.isHidden = true
        flickrImageView?.image = photo.image
        titleLabel?.text = photo.title
    }
}

protocol Reusable { }

extension UICollectionViewCell: Reusable { }

extension Reusable where Self: UICollectionViewCell {
    static var reuseID: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    func dequeueReusableCell<Cell: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> Cell {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: Cell.reuseID, for: indexPath) as? Cell
            else {
                fatalError("Fatal error for cell at \(indexPath)")
        }
        return cell
    }
}
