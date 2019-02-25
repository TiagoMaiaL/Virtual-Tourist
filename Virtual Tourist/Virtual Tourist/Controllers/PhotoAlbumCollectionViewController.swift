//
//  PhotoAlbumCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 11/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

/// The controller in charge of presenting the photo album with images from Flickr.
class PhotoAlbumCollectionViewController: UICollectionViewController {

    // MARK: Properties

    /// The reuse identifier of the collection cells.
    private let reuseIdentifier = "Cell"

    /// The pin object associated with the album.
    var pin: PinMO!

    /// The flickr service used to request the images.
    var flickrService: FlickrServiceProtocol!

    /// The fetched results controller in charge of populating the collection view.
    var photosFetchedResultsController: NSFetchedResultsController<PhotoMO>!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(pin != nil)
        precondition(flickrService != nil)
        precondition(photosFetchedResultsController != nil)

        title = pin.placeName

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photosFetchedResultsController.sections?.count ?? 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosFetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier:
            reuseIdentifier, for: indexPath
            ) as? PhotoCollectionViewCell else {
                preconditionFailure("The cell must be of photo type.")
        }

        let currentPhoto = photosFetchedResultsController.object(at: indexPath)
        flickrService.requestImage(fromUrl: currentPhoto.url!) { image, error in
            guard error == nil, let image = image else {
                // TODO: Display the failure in the cell?
                // TODO: Find a way to display this error to the user.
                return
            }

            cell.photoImageView.image = image
            cell.photoLoadingActivityIndicator.stopAnimating()
        }

        return cell
    }
}
