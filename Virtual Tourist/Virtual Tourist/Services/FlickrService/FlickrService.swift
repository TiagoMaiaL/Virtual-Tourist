//
//  FlickrService.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 12/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// The class in charge of getting resources from Flickr and persisting them to core data.
class FlickrService: FlickrServiceProtocol {

    // MARK: Properties

    /// The flickr API key.
    private let flickrAPIKey: String

    // MARK: Initializers

    init() {
        guard let flickrAPIKey = Bundle.main.object(forInfoDictionaryKey: "Flickr api key") as? String else {
            preconditionFailure("The flickr API key must be properly configured.")
        }

        self.flickrAPIKey = flickrAPIKey
    }
}
