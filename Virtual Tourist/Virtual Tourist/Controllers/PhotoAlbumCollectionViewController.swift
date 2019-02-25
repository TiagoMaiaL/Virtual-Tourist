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

    /// The fetched results controller in charge of populating the collection view.
    var photosFetchedResultsController: NSFetchedResultsController<PhotoMO>!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(pin != nil)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        let currentPhoto = photosFetchedResultsController.object(at: indexPath)
        // TODO: Configure the cell
        // TODO: Download, associate, save, and display the image.
    
        return cell
    }
}
