//
//  FlickrService.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 12/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// A service in charge of getting and persisting any external resources from Flickr, using its API.
class FlickrService: FlickrServiceProtocol {

    // MARK: Properties

    /// The flickr API key.
    private let flickrAPIKey: String

    let apiClient: APIClientProtocol

    /// The base url used to make the requests to the flickr API.
    private lazy var baseURL: URL = {
        var components = URLComponents()
        components.scheme = API.Scheme
        components.host = API.Host
        components.path = API.Path
        return components.url!
    }()

    // MARK: Initializers

    required init(apiClient: APIClientProtocol) {
        guard let flickrAPIKey = Bundle.main.object(forInfoDictionaryKey: "Flickr api key") as? String else {
            preconditionFailure("The flickr API key must be properly configured.")
        }

        self.apiClient = apiClient
        self.flickrAPIKey = flickrAPIKey
    }

    // MARK: Imperatives

    func requestPinRelatedImages(
        fromPin pin: PinMO,
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

        let task = apiClient.makeGETDataTaskForResource(withURL: baseURL, parameters: parameters) { data, error in
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
}
