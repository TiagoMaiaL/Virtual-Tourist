//
//  APIClientProtocol.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 12/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

extension URLSessionTask {

    /// Describes the general kind of errors that might happen with a data task.
    enum TaskError: Error {
        case connection
        case serverResponse
        case malformedJsonResponse
        case unexpectedResource
    }
}

/// An instance in charge of generating configured data tasks, using the Foundation URL Loading System.
protocol APIClientProtocol {

    // MARK: Types

    /// A Data json object waiting to be deserialized.
    typealias JsonData = Data

    // MARK: Properties

    /// The session used by the APIClientProtocol adopter to create the data tasks.
    var session: URLSession { get }

    // MARK: Initializers

    init(session: URLSession)

    // MARK: Imperatives

    /// Creates and configures a data task for a GET HTTP method with the passed parameters.
    /// - Parameters:
    ///     - resourceUrl: the url of the desired resource.
    ///     - parameters: the parameters to be passed with the request.
    ///     - headers: the headers to be sent with the request.
    ///     - completionHandler: the completion handler called when the task finishes, with an error or the data.
    /// - Returns: the configured and not resumed data task.
    func makeGETDataTaskForResource(
        withURL resourceURL: URL,
        parameters: [String: String],
        headers: [String: String]?,
        andCompletionHandler handler: @escaping (JsonData?, URLSessionTask.TaskError?) -> Void
    ) -> URLSessionDataTask
}
