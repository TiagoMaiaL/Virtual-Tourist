//
//  AlbumMO.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// The managed object representing an album associated to a pin.
class AlbumMO: NSManagedObject {

    // MARK: Properties

    /// Flag indicating if the album has images.
    var hasImages: Bool {
        return (photos?.count ?? 0) > 0
    }

    // MARK: Life cycle

    override func awakeFromInsert() {
        super.awakeFromInsert()

        creationDate = Date()
        id = UUID().uuidString
    }
}
