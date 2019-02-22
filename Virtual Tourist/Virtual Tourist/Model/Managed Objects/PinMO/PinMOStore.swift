//
//  PinMOStore.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

struct PinMOStore: PinMOStoreProtocol {

    // MARK: Imperatives

    func createPin(
        usingContext context: NSManagedObjectContext,
        withLocationName locationName: String,
        andCoordinate coordinate: CLLocationCoordinate2D) -> PinMO {

        let pin = PinMO(context: context)
        pin.placeName = locationName
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude

        return pin
    }
}
