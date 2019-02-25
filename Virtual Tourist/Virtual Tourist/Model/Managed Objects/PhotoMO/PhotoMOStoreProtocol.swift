//
//  PhotoMOStoreProtocol.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Store in charge of creating photos from the passed flickr formats.
protocol PhotoMOStoreProtocol {

    // MARK: Imperatives

    /// Creates an image from the passed intermediate Flickr format.
    /// - Parameters:
    ///     - flickrImage: the flickr image to be persisted as a PhotoMO entity.
    ///     - album: the album to be associated with the created image.
    func createPhoto(fromFlickrImage flickrImage: FlickrImage, associatedToAlbum album: AlbumMO) -> PhotoMO

    /// Creates a configured fetched results controller for the photos in the passed album.
    /// - Parameters:
    ///     - album: the album to get the photos from.
    ///     - context: the context to be fetched.
    /// - Returns: the configured fetched results controller.
    func getPhotosFetchedResultsController(
        fromAlbum album: AlbumMO,
        fetchingFromContext context: NSManagedObjectContext
        ) -> NSFetchedResultsController<PhotoMO>
}
