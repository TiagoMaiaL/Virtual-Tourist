//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 11/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import MapKit
import CoreData

/// The view controller showing the pins entered by the user in a map.
class MapViewController: UIViewController {

    // MARK: Properties

    /// The data controller of the app.
    var dataController: DataController!

    /// The pin store used to create a new pin.
    var pinStore: PinMOStoreProtocol!

    /// The album store used to handle the photos for a pin.
    var albumStore: AlbumMOStoreProtocol!

    /// The service in charge of getting images from Flickr and turning them into photos inside an album.
    var flickrService: FlickrServiceProtocol!

    /// The main map view.
    @IBOutlet weak var mapView: MKMapView!

    // MARK: Life Cycle

    deinit {
        stopObservingNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(dataController != nil)
        precondition(pinStore != nil)
        precondition(albumStore != nil)
        precondition(flickrService != nil)

        configureNavigationController()

        startObservingNotification(withName: .NSManagedObjectContextDidSave,
                                   usingSelector: #selector(updateViewContext(fromNotification:)))

        mapView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayPins()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.ShowPhotoAlbumManager {
            guard let selectedPinAnnotation = mapView.selectedAnnotations.first as? PinAnnotation,
                let albumManagerController = segue.destination as? PhotoAlbumManagerViewController else {
                    assertionFailure("Couldn't prepare the album controller.")
                    return
            }
            let selectedPin = selectedPinAnnotation.pin
            
            albumManagerController.pin = selectedPin
            albumManagerController.flickrService = flickrService
            albumManagerController.dataController = dataController
            albumManagerController.photoStore = albumStore.photoStore
        }
    }

    // MARK: Actions

    /// Updates the view context with the changes of any background context.
    @objc private func updateViewContext(fromNotification notification: Notification) {
        dataController.viewContext.mergeChanges(fromContextDidSave: notification)
    }

    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            let pressMapCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            createPin(forCoordinate: pressMapCoordinate)
        default:
            break
        }
    }

    // MARK: Imperatives

    /// Creates a new pin and persists it using the passed coordinate.
    /// - Parameter coordinate: the coordinate location of the user's press gesture.
    private func createPin(forCoordinate coordinate: CLLocationCoordinate2D) {
        // Geocode the coordinate to get more details about the location.
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                var locationName: String?

                if let placemark = placemarks?.first {
                    locationName = placemark.placeName
                }

                do {
                    let createdPin = self.pinStore.createPin(
                        usingContext: self.dataController.viewContext,
                        withLocationName: locationName,
                        andCoordinate: coordinate
                    )

                    try self.dataController.save()

                    self.flickrService.populatePinWithPhotosFromFlickr(createdPin) { createdPin, error in
                        guard error == nil, createdPin != nil else {
                            /* Fail silently when in the map controller. */
                            return
                        }

                    }

                    self.display(createdPin: createdPin)
                } catch {
                    // TODO: Alert the user of the error.
                }
            }
        }
    }

    /// Displays the persisted pins on the map.
    private func displayPins() {
        mapView.removeAllAnnotations()

        // Make the fetch for pins and add them to the map.
        let pinsRequest: NSFetchRequest<PinMO> = PinMO.fetchRequest()
        pinsRequest.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        dataController.viewContext.perform {
            do {
                let pins = try self.dataController.viewContext.fetch(pinsRequest)
                self.mapView.addAnnotations(pins.map { PinAnnotation(pin: $0) })
            } catch {
                let alert = self.makeAlertController(withTitle: "Error", andMessage: "Couldn't load the added pins.")
                self.present(alert, animated: true)
            }
        }
    }

    /// Adds a recently created Pin instance to the map.
    /// - Parameter createdPin: the pin recently created by the user.
    private func display(createdPin pin: PinMO) {
        mapView.addAnnotation(PinAnnotation(pin: pin))
    }

    /// Configures the navigation controller to set up the delegate and other attributes.
    private func configureNavigationController() {
        navigationController?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
}

extension MapViewController: MKMapViewDelegate {

    // MARK: MKMapViewDelegate methods

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard view.annotation is PinAnnotation else {
            return
        }

        performSegue(withIdentifier: SegueIdentifiers.ShowPhotoAlbumManager, sender: self)
    }
}

extension MapViewController: UINavigationControllerDelegate {

    // MARK: Navigation controller delegate methods

    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return PushMapDetailsAnimator()

        case .pop:
            return PopMapDetailsAnimator()

        default:
            return nil
        }
    }
}

private class PushMapDetailsAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: UIViewControllerAnimatedTransitioning Delegate methods

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!

        // Configure the details map to have the same position as the map listing the pins.
        guard let currentMapController = transitionContext.viewController(forKey: .from) as? MapViewController else {
            preconditionFailure("The from controller must be a map controller.")
        }
        let mapRegion = currentMapController.mapView.region

        guard let detailsViewController = transitionContext.viewController(forKey: .to) as? PhotoAlbumManagerViewController else {
            preconditionFailure("The from controller must be a album manager controller.")
        }
        detailsViewController.albumDisplayerController.detailsMapController.mapView.setRegion(mapRegion, animated: false)

        toView.alpha = 0
        containerView.addSubview(toView)

        UIView.animate(withDuration: 0.3, animations: {
            toView.alpha = 1
        }) { _ in
            transitionContext.completeTransition(true)
        }
    }
}

private class PopMapDetailsAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: UIViewControllerAnimatedTransitioning Delegate methods

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!

        guard let currentDetailsViewController = transitionContext.viewController(forKey: .from) as? PhotoAlbumManagerViewController else {
            preconditionFailure("The from controller must be an album manager controller.")
        }
        let detailsMapRegion = currentDetailsViewController.albumDisplayerController.detailsMapController.mapView.region

        guard let mapViewController = transitionContext.viewController(forKey: .to) as? MapViewController else {
            preconditionFailure("The from controller must be a map view controller.")
        }
        mapViewController.mapView.setRegion(detailsMapRegion, animated: false)

        toView.alpha = 0
        containerView.addSubview(toView)

        UIView.animate(withDuration: 0.3, animations: {
            toView.alpha = 1
        }) { _ in
            mapViewController.mapView.setRegion(
                MKCoordinateRegion(center: detailsMapRegion.center,
                                   span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 40)),
                animated: true
            )
            transitionContext.completeTransition(true)
        }
    }
}
