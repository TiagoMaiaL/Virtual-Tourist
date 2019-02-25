//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 24/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// A cell displaying a photo in an image view.
class PhotoCollectionViewCell: UICollectionViewCell {

    // MARK: Properties

    /// The image view displaying a photo.
    @IBOutlet weak var photoImageView: UIImageView!

    /// The activity indicator telling if the photo is being loaded.
    @IBOutlet weak var photoLoadingActivityIndicator: UIActivityIndicatorView!

    // MARK: Life cycle

    override func prepareForReuse() {
        super.prepareForReuse()
        photoLoadingActivityIndicator.stopAnimating()
        photoImageView.image = nil
    }

}
