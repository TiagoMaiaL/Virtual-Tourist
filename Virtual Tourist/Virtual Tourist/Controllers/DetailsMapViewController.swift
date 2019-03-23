//
//  DetailsMapViewController.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 23/03/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import MapKit

/// The controller in charge of displaying the details of a specific pin,
/// allowing the change of coordinates by dragging.
class DetailsMapViewController: UIViewController {

    // MARK: Properties

    /// The map view displaying the pin.
    @IBOutlet weak var mapView: MKMapView!

    /// The pin being displayed.
    var pin: PinMO!

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        precondition(pin != nil)

        mapView.addAnnotation(PinAnnotation(pin: pin))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let pinAnnotation = mapView.annotations.first!
        mapView.setRegion(
            MKCoordinateRegion(center: pinAnnotation.coordinate,
                               span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)),
            animated: true
        )
    }
}

extension DetailsMapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        view.isDraggable = true

        return view
    }

    func mapView(
        _ mapView: MKMapView,
        annotationView view: MKAnnotationView,
        didChange newState: MKAnnotationView.DragState,
        fromOldState oldState: MKAnnotationView.DragState
        ) {
        switch newState {
        case .starting:
            view.dragState = .dragging

        case .canceling, .ending:
            view.dragState = .none
            // Finish the drag by setting the coordinates of the pin managed object.
            guard let coordinate = view.annotation?.coordinate else { preconditionFailure() }
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude

        default: break
        }
    }
}
