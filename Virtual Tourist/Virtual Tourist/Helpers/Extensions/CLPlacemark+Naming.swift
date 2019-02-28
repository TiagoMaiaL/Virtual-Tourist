//
//  CLPlacemark+Naming.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 28/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreLocation

extension CLPlacemark {

    // MARK: Properties

    /// Generates the name of the placemark based on its own properties.
    var placeName: String? {
        var placeName = ""

        if let administrativeArea = administrativeArea {
            placeName = administrativeArea
        }

        if let locality = locality {
            placeName += ", \(locality)"
        }

        if let name = name {
            placeName += ", \(name)"
        }

        return placeName.isEmpty ? nil : placeName
    }
}
