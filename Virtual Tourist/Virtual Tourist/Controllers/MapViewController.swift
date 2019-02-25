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

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(dataController != nil)
        precondition(pinStore != nil)
        precondition(albumStore != nil)
        precondition(flickrService != nil)

        mapView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayPins()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.ShowPhotoAlbum {
            guard let selectedPinAnnotation = mapView.selectedAnnotations.first as? PinAnnotation,
                let albumController = segue.destination as? PhotoAlbumCollectionViewController else {
                    assertionFailure("Couldn't prepare the album controller.")
                    return
            }
            let selectedPin = selectedPinAnnotation.pin

            let photosRequest: NSFetchRequest<PhotoMO> = PhotoMO.fetchRequest()
            photosRequest.predicate = NSPredicate(format: "pin = %@", selectedPin)
            photosRequest.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]

            albumController.photosFetchedResultsController = NSFetchedResultsController<PhotoMO>(
                fetchRequest: photosRequest,
                managedObjectContext: dataController.viewContext,
                sectionNameKeyPath: nil,
                cacheName: selectedPin.placeName
            )
            albumController.pin = selectedPin
            albumController.flickrService = flickrService
        }
    }

    // MARK: Actions

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
                if let placemark = placemarks?.first,
                    let administrativeArea = placemark.administrativeArea,
                    let locality = placemark.locality {
                    let createdPin = self.pinStore.createPin(usingContext: self.dataController.viewContext,
                                                             withLocationName: "\(locality), \(administrativeArea)",
                                                             andCoordinate: coordinate)
                    do {
                        try self.dataController.save()
                        self.display(createdPin: createdPin)
                    } catch {
                        // TODO: display errors to the user.
                    }
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
            // TODO: Display any errors back to the user.
            if let pins = try? self.dataController.viewContext.fetch(pinsRequest) {
                self.mapView.addAnnotations(pins.map { PinAnnotation(pin: $0) })
            }
        }
    }

    /// Adds a recently created Pin instance to the map.
    /// - Parameter createdPin: the pin recently created by the user.
    private func display(createdPin pin: PinMO) {
        mapView.addAnnotation(PinAnnotation(pin: pin))
    }
}

extension MKMapView {

    /// Removes all currently handled annotations.
    fileprivate func removeAllAnnotations() {
        removeAnnotations(annotations)
    }
}

private class PinAnnotation: MKPointAnnotation {

    // MARK: Properties

    /// The associated pin managed object.
    var pin: PinMO

    // MARK: Initializers

    init(pin: PinMO) {
        self.pin = pin

        super.init()

        // TODO: Is it a good idea to store the coordinates directly? As a Transformable property?
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
    }
}

extension MapViewController: MKMapViewDelegate {

    // MARK: MKMapViewDelegate methods

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard view.annotation is PinAnnotation else {
            return
        }

        performSegue(withIdentifier: SegueIdentifiers.ShowPhotoAlbum, sender: self)
    }
}
