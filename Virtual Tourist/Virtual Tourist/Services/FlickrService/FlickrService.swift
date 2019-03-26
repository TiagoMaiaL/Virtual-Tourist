//
//  FlickrService.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 12/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import UIKit

/// A service in charge of getting and persisting any external resources from Flickr, using its API.
class FlickrService: FlickrServiceProtocol {

    /// The completion handler called when a photos request finishes.
    private typealias photosRequestCompletionHandler = (PinMO?, Error?) -> Void

    // MARK: Properties

    /// The photos completion handlers associated with a request for photos of an specific pin album.
    private var photosRequestHandlers: [PinMO: [photosRequestCompletionHandler]] = [:]

    /// The flickr API key.
    private let flickrAPIKey: String

    let apiClient: APIClientProtocol

    var albumStore: AlbumMOStoreProtocol

    var dataController: DataController

    /// The base url used to make the requests to the flickr API.
    private lazy var baseURL: URL = {
        var components = URLComponents()
        components.scheme = API.Scheme
        components.host = API.Host
        components.path = API.Path
        return components.url!
    }()

    // MARK: Initializers

    required init(apiClient: APIClientProtocol, albumStore: AlbumMOStoreProtocol, dataController: DataController) {
        guard let flickrAPIKey = Bundle.main.object(forInfoDictionaryKey: "Flickr api key") as? String else {
            preconditionFailure("The flickr API key must be properly configured.")
        }

        self.apiClient = apiClient
        self.flickrAPIKey = flickrAPIKey
        self.albumStore = albumStore
        self.dataController = dataController
    }

    // MARK: Imperatives

    func populatePinWithPhotosFromFlickr(
        _ pin: PinMO,
        withCompletionHandler handler: @escaping (PinMO?, Error?) -> Void
        ) {
        let pinObjectID = pin.objectID

        // This caches many calls for photos of a single pin,
        // so all of them get responded when the single request finishes.
        if var handlers = photosRequestHandlers[pin] {
            // If there's already a request for this pin, simply append this completion handler.
            handlers.append(handler)
            photosRequestHandlers[pin] = handlers

        } else {
            // Otherwise, add the first handler for this pin, and start the request.
            photosRequestHandlers[pin] = [handler]
            requestImages(relatedToPin: pin) { flickrResponseData, taskError in
                // Retrieve the callbacks to be invoked.
                let handlers = self.photosRequestHandlers[pin]!

                // Clear the handlers for a next request for this pin photos.
                self.photosRequestHandlers[pin] = nil

                guard taskError == nil, let flickrResponseData = flickrResponseData else {
                    handlers.forEach { $0(nil, taskError!) }
                    return
                }

                self.dataController.persistentContainer.performBackgroundTask { context in
                    guard let pinInBackgroundContext = context.object(with: pinObjectID) as? PinMO else {
                        preconditionFailure("Pin must be correctly fetched in bg context.")
                    }

                    do {
                        try self.albumStore.addPhotos(fromFlickrImages: flickrResponseData.data.photos,
                                                      toAlbum: pinInBackgroundContext.album!)
                        handlers.forEach { $0(pin, nil) }
                    } catch {
                        handlers.forEach { $0(nil, error) }
                    }
                }
            }
        }
    }

    func requestImages(
        relatedToPin pin: PinMO,
        usingCompletionHandler handler: @escaping ((FlickrSearchResponseData?, URLSessionTask.TaskError?) -> Void)
        ) {
        var parameters = [
            ParameterKeys.APIKey: flickrAPIKey,
            ParameterKeys.Format: ParameterDefaultValues.Format,
            ParameterKeys.NoJsonCallback: ParameterDefaultValues.NoJsonCallback,
            ParameterKeys.Method: Methods.PhotosSearch,
            ParameterKeys.Extra: ParameterDefaultValues.ExtraMediumURL
        ]

        if let locationName = pin.placeName {
            parameters[ParameterKeys.Text] = locationName
        } else {
            parameters[ParameterKeys.BoundingBox] =
            "\(pin.longitude - 0.1), \(pin.latitude - 0.1), \(pin.longitude + 0.1), \(pin.latitude + 0.1)"
        }

        let task = apiClient.makeGETDataTaskForResource(
            withURL: baseURL,
            parameters: parameters,
            headers: nil
        ) { data, error in
            UIApplication.shared.enableNetworkingActivityIndicator(false)

            guard error == nil, let data = data else {
                handler(nil, error!)
                return
            }

            let decoder = JSONDecoder()
            do {
                let flickrResponseData = try decoder.decode(FlickrSearchResponseData.self, from: data)
                handler(flickrResponseData, nil)
            } catch {
                handler(nil, .malformedJsonResponse)
            }
        }
        UIApplication.shared.enableNetworkingActivityIndicator(true)

        task.resume()
    }

    func requestImage(
        fromUrl flickrUrl: URL,
        usingComplitionHandler handler: @escaping (UIImage?, URLSessionTask.TaskError?) -> Void
        ) {
        let task = apiClient.makeGETDataTaskForResource(
            withURL: flickrUrl,
            parameters: [:],
            headers: [:]
        ) { data, taskError in
            UIApplication.shared.enableNetworkingActivityIndicator(false)

            guard let data = data, taskError == nil else {
                handler(nil, taskError)
                return
            }

            guard let image = UIImage(data: data) else {
                handler(nil, .unexpectedResource)
                return
            }

            handler(image, nil)
        }
        UIApplication.shared.enableNetworkingActivityIndicator(true)

        task.resume()
    }
}
