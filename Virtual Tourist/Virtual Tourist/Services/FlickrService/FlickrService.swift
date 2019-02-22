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

    // MARK: Initializers

    required init(apiClient: APIClientProtocol) {
        guard let flickrAPIKey = Bundle.main.object(forInfoDictionaryKey: "Flickr api key") as? String else {
            preconditionFailure("The flickr API key must be properly configured.")
        }

        self.apiClient = apiClient
        self.flickrAPIKey = flickrAPIKey
    }

    // MARK: Imperatives

    func getPinRelatedImages(_ pin: PinMO) {
        // TODO: Make the download of images.
    }
}
