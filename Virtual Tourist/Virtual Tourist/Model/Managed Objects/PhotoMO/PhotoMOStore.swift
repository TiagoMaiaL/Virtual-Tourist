//
//  PhotoMOStore.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Store in charge of creating photos from the passed flickr formats.
struct PhotoMOStore: PhotoMOStoreProtocol {

    // MARK: Imperatives

    func createPhoto(fromFlickrImage flickrImage: FlickrImage, associatedToAlbum album: AlbumMO) -> PhotoMO {
        guard let context = album.managedObjectContext else {
            preconditionFailure("The album context must be set.")
        }

        let photo = PhotoMO(context: context)
        photo.title = flickrImage.title
        photo.url = URL(string: flickrImage.mediumUrl)
        photo.id = flickrImage.id
        photo.album = album

        return photo
    }

    func getPhotosFetchedResultsController(
        fromAlbum album: AlbumMO,
        fetchingFromContext context: NSManagedObjectContext
        ) -> NSFetchedResultsController<PhotoMO> {

        let photosRequest: NSFetchRequest<PhotoMO> = PhotoMO.fetchRequest()
        photosRequest.predicate = NSPredicate(format: "album = %@", album)
        photosRequest.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        return NSFetchedResultsController(
            fetchRequest: photosRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
}
