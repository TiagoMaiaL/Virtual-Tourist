//
//  PhotoAlbumManagerViewController.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 23/03/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit

/// Controller in charge of downloading the images from Flickr and
/// displaying them using the photo album displayer controller.
class PhotoAlbumManagerViewController: UIViewController {

    // MARK: Controller view states

    /// The possible states of the album manager.
    private enum State {
        case displayingAlbumm, loadingAlbum, doesNotHavePhotos
    }

    // MARK: Properties

    /// The Data controller used to access the main view context.
    var dataController: DataController!

    /// The pin object associated with the album.
    var pin: PinMO!

    /// The Photo store used to get the photos fetched results controller.
    var photoStore: PhotoMOStoreProtocol!

    /// The flickr service used to request the images.
    var flickrService: FlickrServiceProtocol!

    /// The contained album display controller.
    private var albumDisplayerController: PhotoAlbumDisplayerViewController!

    /// The current view controller state.
    private var viewState = State.displayingAlbumm {
        didSet {
            // Update the album displayed.
            albumDisplayerController.displayAlbum()

            switch viewState {
            case .displayingAlbumm:
                // Simply update the display.
                break
            case .doesNotHavePhotos:
                // Show no photos view
                break
            case .loadingAlbum:
                // Show loading view
                break
            }
        }
    }

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(dataController != nil)
        precondition(photoStore != nil)
        precondition(pin != nil)
        precondition(flickrService != nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Request photos if necessary.
        if !pin.album!.hasImages {
            populatePinWithPhotos(pin)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Inject the dependencies.
        if segue.identifier == SegueIdentifiers.ShowPhotoAlbumDisplayer {
            guard let albumDisplayerController = segue.destination as? PhotoAlbumDisplayerViewController else {
                preconditionFailure("The album display controller must be configured.")
            }
            self.albumDisplayerController = albumDisplayerController
            self.albumDisplayerController.pin = pin
            self.albumDisplayerController.flickrService = flickrService
            self.albumDisplayerController.photosFetchedResultsController = photoStore.getPhotosFetchedResultsController(
                fromAlbum: pin.album!,
                fetchingFromContext: dataController.viewContext
            )
        }
    }

    // MARK: Actions

    @IBAction func refreshAlbum(_ sender: UIBarButtonItem) {
        // Remove all photos from the album.
        if let photos = pin.album?.photos {
            if let photosSet = photos as? Set<PhotoMO> {
                photosSet.forEach { self.pin.managedObjectContext?.delete($0) }
            }
        }

        populatePinWithPhotos(pin)
    }

    // MARK: imperatives

    /// Populates the current pin album with the photos from flickr.
    private func populatePinWithPhotos(_ pin: PinMO) {
        viewState = .loadingAlbum

        func displayDownloadError(withMessage message: String) {
            DispatchQueue.main.async {
                self.viewState = self.pin.album!.hasImages ? .displayingAlbumm : .doesNotHavePhotos
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
                self.viewState = self.pin.album!.hasImages ? .displayingAlbumm : .doesNotHavePhotos

                // TODO: Hide the loading view.
                // TODO: Show the empty state, if there's no photos in the album.
            }
        }
    }
}
