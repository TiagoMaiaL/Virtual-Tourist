//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 11/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// The managed object representing a photo associated to a pin.
class PhotoMO: NSManagedObject {

    // MARK: Life cycle

    override func awakeFromInsert() {
        super.awakeFromInsert()

        creationDate = Date()
    }
}
