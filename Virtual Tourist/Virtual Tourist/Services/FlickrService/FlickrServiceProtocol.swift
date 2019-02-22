//
//  FlickrServiceProtocol.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 12/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// A service in charge of getting and persisting any external resources from Flickr, using its API.
protocol FlickrServiceProtocol {

    // MARK: Properties

    /// The base api client used to load the resources from flickr.
    var apiClient: APIClientProtocol { get }

    // MARK: Initializers

    init(apiClient: APIClientProtocol)

    // MARK: Imperatives

    /// Gets the images related to the passed pin, and puts them in the Album associated with the pin.
    /// - Parameters:
    ///     - pin: the pin associated to the images to be downloaded.
    func getPinRelatedImages(_ pin: PinMO)
}
