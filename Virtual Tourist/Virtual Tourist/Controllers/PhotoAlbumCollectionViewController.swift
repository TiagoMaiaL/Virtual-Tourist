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

    /// The flow layout of the collection view.
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    /// The reuse identifier of the collection cells.
    private let reuseIdentifier = "photoCell"

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

        photosFetchedResultsController.delegate = self
        fetchAlbumPhotos()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Save any images into core data.
        do {
            try pin.managedObjectContext?.save()
        } catch {
            pin.managedObjectContext?.rollback()
            let alert = makeAlertController(
                withTitle: "Error",
                andMessage: "The photos of the album couldn't be saved. Please, make sure you have enough space available in your device."
            )
            present(alert, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Download the images, if necessary.
        if !pin.album!.hasImages {
            populatePinWithPhotos(pin)
        }
    }

    // MARK: Actions

    @IBAction func refreshAlbum(_ sender: UIBarButtonItem) {
        // Invalidate the delegate of the fetched results controller,
        // so it doesn't call the update methods (all objects are being removed).
        photosFetchedResultsController.delegate = nil

        // Remove all photos from the album.
        if let photos = pin.album?.photos {
            if let photosSet = photos as? Set<PhotoMO> {
                photosSet.forEach { self.pin.managedObjectContext?.delete($0) }
            }
        }

        // Clear the current fetch results by making s empty fetch.
        fetchAlbumPhotos()
        collectionView.reloadData()

        photosFetchedResultsController.delegate = self

        // Fetch them all over again.
        populatePinWithPhotos(pin)
    }

    // MARK: Imperatives

    /// Fetches the photos of the current album.
    private func fetchAlbumPhotos() {
        do {
            try photosFetchedResultsController.performFetch()
        } catch {
            let alert = makeAlertController(
                withTitle: "Error",
                andMessage: "There was an error while fetching the photos of the album."
            )
            present(alert, animated: true)
        }
    }

    /// Populates the current pin album with the photos from flickr.
    private func populatePinWithPhotos(_ pin: PinMO) {
        func displayDownloadError(withMessage message: String) {
            DispatchQueue.main.async {
                self.present(self.makeAlertController(withTitle: "Error", andMessage: message), animated: true)
            }
        }

        flickrService.populatePinWithPhotosFromFlickr(pin) { [weak self] pin, error in
            guard let self = self else { return }

            guard error == nil, pin != nil else {
                displayDownloadError(withMessage: "The photos couldn't be downloaded. Please, check your connection and try again later.")
                return
            }

            DispatchQueue.main.async {
                do {
                    try self.photosFetchedResultsController.performFetch()
                } catch {
                    displayDownloadError(withMessage: "The photos of the album couldn't be saved. Please, make sure you have enough space available in your device.")
                }

                self.collectionView.reloadData()
            }
        }
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
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
            ) as? PhotoCollectionViewCell else {
                preconditionFailure("The cell must be of photo type.")
        }

        let currentPhoto = photosFetchedResultsController.object(at: indexPath)

        if let imageData = currentPhoto.data {
            if let holdedImage = currentPhoto.image {
                cell.photoImageView.image = holdedImage
                cell.photoLoadingActivityIndicator.stopAnimating()
            } else {
                DispatchQueue.global(qos: .userInteractive).async {
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        // Hold this image for future use.
                        currentPhoto.image = image
                        cell.photoImageView.image = image
                        cell.photoLoadingActivityIndicator.stopAnimating()
                    }
                }
            }
        } else {
            // Request the images and save them into core data.
            cell.photoLoadingActivityIndicator.startAnimating()

            flickrService.requestImage(fromUrl: currentPhoto.url!) { image, error in
                guard error == nil, let image = image else {
                    // TODO: Display the failure in the cell?
                    // TODO: Find a way to display this error to the user.
                    print("Error loading image...")
                    return
                }

                DispatchQueue.main.async {
                    currentPhoto.data = image.jpegData(compressionQuality: 1)

                    // Only update the cell with the photo if it still holds the one to be displayed
                    if let currentIndexPath = self.collectionView.indexPath(for: cell) {
                        let photoAtResponseTime = self.photosFetchedResultsController.object(at: currentIndexPath)
                        if photoAtResponseTime == currentPhoto {
                            cell.photoImageView.image = image
                            cell.photoLoadingActivityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentPhoto = photosFetchedResultsController.object(at: indexPath)
        // Remove the image from the album.
        currentPhoto.album = nil
        photosFetchedResultsController.managedObjectContext.delete(currentPhoto)
    }
}

extension PhotoAlbumCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
        ) -> CGSize {
        let sidesMetric = (collectionView.frame.size.width / 3) - 1 // 1 px of padding between the cells.
        return CGSize(width: sidesMetric, height: sidesMetric)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
        ) -> CGFloat {
        return 1
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
        ) -> CGFloat {
        return 1
    }
}

extension PhotoAlbumCollectionViewController: NSFetchedResultsControllerDelegate {

    // MARK: Fetched results controller delegate methods

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
        ) {
        switch type {
        case .delete:
            collectionView.deleteItems(at: [indexPath!])

        default: break
        }
    }
}
