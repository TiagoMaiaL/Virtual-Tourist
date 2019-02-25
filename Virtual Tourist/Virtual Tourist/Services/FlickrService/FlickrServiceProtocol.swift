//
//  FlickrServiceProtocol.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 12/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import UIKit

/// A service in charge of getting and persisting any external resources from Flickr, using its API.
protocol FlickrServiceProtocol {

    // MARK: Properties

    /// The base api client used to load the resources from flickr.
    var apiClient: APIClientProtocol { get }

    /// The store used to add photos to the album and persist them.
    var albumStore: AlbumMOStoreProtocol { get }

    /// The data controller used to access core data.
    var dataController: DataController { get }

    // MARK: Initializers

    init(apiClient: APIClientProtocol, albumStore: AlbumMOStoreProtocol, dataController: DataController)

    // MARK: Imperatives

    /// Requests and saves the associated Flickr images inside the album of the passed pin.
    /// - Parameters:
    ///     - pin: the pin containing the album.
    ///     - handler: the completion handler called after the work finishes.
    func populatePinWithPhotosFromFlickr(
        _ pin: PinMO,
        withCompletionHandler handler: @escaping (PinMO?, Error?) -> Void
    )

    /// Gets the images related to the passed pin, and puts them in the Album associated with the pin.
    /// - Parameters:
    ///     - pin: the pin associated to the images to be downloaded.
    ///     - handler: the completion handler called after the request returns.
    func requestImages(
        relatedToPin pin: PinMO,
        usingCompletionHandler handler: @escaping ((FlickrSearchResponseData?, URLSessionTask.TaskError?) -> Void)
    )

    /// Requests the image from the passed Flickr url.
    /// - Parameters:
    ///     - url: the url of the image to be loaded.
    ///     - handler: the closure called as a completion handler.
    func requestImage(
        fromUrl flickrUrl: URL,
        usingComplitionHandler handler: @escaping (UIImage?, URLSessionTask.TaskError?) -> Void
    )
}
