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

    /// The main map view.
    @IBOutlet weak var mapView: MKMapView!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(dataController != nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayPins()
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Inject the main dependencies.
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
        // Geocode the coordinate to get more details of the location.
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            self.dataController.persistentContainer.performBackgroundTask { context in
                let pin = PinMO(context: context)
                pin.latitude = coordinate.latitude
                pin.longitude = coordinate.longitude

                if let placemark = placemarks?.first,
                    let administrativeArea = placemark.administrativeArea,
                    let locality = placemark.locality {
                    pin.placeName = "\(locality), \(administrativeArea)"
                }

                do {
                    try context.save()
                    let pinID = pin.objectID
                    self.dataController.viewContext.perform {
                        guard let mainQueuePin = self.dataController.viewContext.object(with: pinID) as? PinMO else {
                            preconditionFailure("The fetched object wasn't correctly found.")
                        }
                        self.display(createdPin: mainQueuePin)
                    }
                } catch {
                    // TODO: Display the error back to the user.
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
                self.mapView.addAnnotations(pins.map {
                    let annotation = MKPointAnnotation()
                    // TODO: Is it a good idea to store the coordinates directly? As a Transformable property?
                    annotation.coordinate = CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)

                    return annotation
                })
            }
        }
    }

    /// Adds a recently created Pin instance to the map.
    /// - Parameter createdPin: the pin recently created by the user.
    private func display(createdPin pin: PinMO) {
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        mapView.addAnnotation(pinAnnotation)
    }
}

extension MKMapView {

    /// Removes all currently handled annotations.
    fileprivate func removeAllAnnotations() {
        removeAnnotations(annotations)
    }
}
