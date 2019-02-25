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

    // MARK: Properties

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

        requestImages(relatedToPin: pin) { flickrResponseData, taskError in
            guard taskError == nil, let flickrResponseData = flickrResponseData else {
                handler(nil, taskError!)
                return
            }

            self.dataController.persistentContainer.performBackgroundTask { context in
                guard let pinInBackgroundContext = context.object(with: pinObjectID) as? PinMO else {
                    preconditionFailure("Pin must be correctly fetched in bg context.")
                }

                do {
                    try self.albumStore.addPhotos(fromFlickrImages: flickrResponseData.data.photos,
                                                  toAlbum: pinInBackgroundContext.album!)
                } catch {
                    handler(nil, error)
                }
            }
        }
    }

    func requestImages(
        relatedToPin pin: PinMO,
        usingCompletionHandler handler: @escaping ((FlickrSearchResponseData?, URLSessionTask.TaskError?) -> Void)
        ) {
        let parameters = [
            ParameterKeys.APIKey: flickrAPIKey,
            ParameterKeys.Format: ParameterDefaultValues.Format,
            ParameterKeys.NoJsonCallback: ParameterDefaultValues.NoJsonCallback,
            ParameterKeys.Method: Methods.PhotosSearch,
            ParameterKeys.Text: pin.placeName!,
            ParameterKeys.Extra: ParameterDefaultValues.ExtraMediumURL
        ]

        let task = apiClient.makeGETDataTaskForResource(
            withURL: baseURL,
            parameters: parameters,
            headers: nil
        ) { data, error in
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
        task.resume()
    }
}
