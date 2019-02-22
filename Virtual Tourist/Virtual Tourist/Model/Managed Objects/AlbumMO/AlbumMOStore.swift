//
//  AlbumMOStore.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// The store in charge of managing album related operations.
struct AlbumMOStore: AlbumMOStoreProtocol {

    // MARK: Properties

    var photoStore: PhotoMOStoreProtocol

    // MARK: Initializers

    init(photoStore: PhotoMOStoreProtocol) {
        self.photoStore = photoStore
    }

    // MARK: Imperatives

    func addPhotos(fromFlickrImages flickrImages: [FlickrImage], toAlbum album: AlbumMO) throws {
        guard let context = album.managedObjectContext else {
            preconditionFailure("Album instances passed to this method must have a context")
        }

        flickrImages.forEach { _ = photoStore.createPhoto(fromFlickrImage: $0, associatedToAlbum: album) }
        try context.save()
    }
}
