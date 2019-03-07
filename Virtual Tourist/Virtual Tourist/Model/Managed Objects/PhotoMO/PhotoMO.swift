//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 11/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/// The managed object representing a photo associated to an album.
class PhotoMO: NSManagedObject {

    // MARK: Properties

    /// The image of this photo entity.
    var image: UIImage?

    // MARK: Life cycle

    override func awakeFromInsert() {
        super.awakeFromInsert()

        creationDate = Date()
    }

    override func awakeFromFetch() {
        super.awakeFromFetch()

        if let data = data, image == nil {
            image = UIImage(data: data)
        }
    }
}
