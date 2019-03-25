//
//  PhotoAlbumDisplayerViewController.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 11/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData
import MapKit

/// The controller in charge of presenting the photo album with the pin images.
class PhotoAlbumDisplayerViewController: UIViewController {

    // MARK: Properties

    /// The reuse identifier of the collection cells.
    private let reuseIdentifier = "photoCell"

    /// The pin object associated with the album.
    var pin: PinMO!

    /// The flickr service used to request the images.
    var flickrService: FlickrServiceProtocol!

    /// The fetched results controller in charge of populating the collection view.
    var photosFetchedResultsController: NSFetchedResultsController<PhotoMO>!

    /// The blur view on top of the map background view.
    @IBOutlet weak var blurView: UIVisualEffectView!

    /// The photo album collection view.
    @IBOutlet weak var collectionView: UICollectionView!

    /// The top inset of the collection view, so it displays map view when in the top.
    var mapTopInset: CGFloat!

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(pin != nil)
        precondition(flickrService != nil)
        precondition(photosFetchedResultsController != nil)

        title = pin.placeName

        configureFlowLayout()

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

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.ShowDetailsMap {
            guard let detailsMapController = segue.destination as? DetailsMapViewController else {
                preconditionFailure("There must be a details map controller.")
            }
            detailsMapController.pin = pin
        }
    }

    // MARK: Imperatives

    /// Fetches and displays the album photos.
    func displayAlbum() {
        fetchAlbumPhotos()
        collectionView.reloadData()
    }

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

    /// Configures the collection view layout.
    private func configureFlowLayout() {
        mapTopInset = 6 * (view.frame.size.height / 8)
        collectionView.contentInset = UIEdgeInsets(top: mapTopInset, left: 0, bottom: 0, right: 0)
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 1
            flowLayout.minimumInteritemSpacing = 1

            let sidesMetric = (collectionView.frame.width / 3) - 1 // 1 px of padding between the cells.
            flowLayout.itemSize = CGSize(width: sidesMetric, height: sidesMetric)
            flowLayout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: 50)
        }

        collectionView.register(
            UINib(nibName: "AlbumSectionHeaderView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "Header view"
        )
    }

    /// Scrolls the collection view to the album photos.
    @objc private func scrollToAlbumPhotos() {
        collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension PhotoAlbumDisplayerViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: UICollectionView data source methods

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photosFetchedResultsController.sections?.count ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosFetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentPhoto = photosFetchedResultsController.object(at: indexPath)
        // Remove the image from the album.
        currentPhoto.album = nil
        photosFetchedResultsController.managedObjectContext.delete(currentPhoto)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
        ) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "Header view",
                                                                         for: indexPath)
        if (headerView.gestureRecognizers ?? []).count == 0 {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollToAlbumPhotos))
            headerView.addGestureRecognizer(tapRecognizer)
        }

        return headerView
    }
}

extension PhotoAlbumDisplayerViewController: NSFetchedResultsControllerDelegate {

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

extension PhotoAlbumDisplayerViewController {

    // MARK: ScrollView delegate methods

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetAlphaRange = (min: CGFloat(mapTopInset * -0.95), max: CGFloat(mapTopInset * -0.4))
        let topOffset = scrollView.contentOffset.y

        if topOffset <= offsetAlphaRange.min {
            blurView.alpha = 0

        } else if topOffset <= offsetAlphaRange.max, topOffset > offsetAlphaRange.min {
            let difference = abs(offsetAlphaRange.min) - abs(offsetAlphaRange.max)
            let alpha = 1 - (abs(topOffset) + offsetAlphaRange.max) / difference
            blurView.alpha = alpha

        } else {
            blurView.alpha = 1
        }
    }
}
