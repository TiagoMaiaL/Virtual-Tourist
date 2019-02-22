//
//  PhotoMOStoreProtocol.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// Store in charge of creating photos from the passed flickr formats.
protocol PhotoMOStoreProtocol {

    // MARK: Imperatives

    /// Creates an image from the passed intermediate Flickr format.
    /// - Parameters:
    ///     - flickrImage: the flickr image to be persisted as a PhotoMO entity.
    ///     - album: the album to be associated with the created image.
    func createPhoto(fromFlickrImage flickrImage: FlickrImage, associatedToAlbum album: AlbumMO) -> PhotoMO
}
