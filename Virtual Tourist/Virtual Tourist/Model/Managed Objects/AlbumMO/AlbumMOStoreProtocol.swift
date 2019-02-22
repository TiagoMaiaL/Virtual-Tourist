//
//  AlbumMOStoreProtocol.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// Store in charge of managing the save, fetch and removal operations related to album entities.
protocol AlbumMOStoreProtocol {

    // MARK: Properties

    /// The store used to create new photos.
    var photoStore: PhotoMOStoreProtocol { get }

    // MARK: Initializers

    init(photoStore: PhotoMOStoreProtocol)

    // MARK: Imperatives

    /// Creates and saves the images in the Flickr response format into the album entity.
    /// - Parameters:
    ///     - images: the Flickr response images.
    ///     - album: the album entity to be populated with images.
    func addPhotos(fromFlickrImages flickrImages: [FlickrImage], toAlbum album: AlbumMO) throws
}
