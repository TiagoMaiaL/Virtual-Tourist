//
//  APIClient.swift
//  Virtual Tourist
//
//  Created by Tiago Maia Lopes on 12/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation

/// An instance in charge of generating configured data tasks, using the Foundation URL Loading System.
struct APIClient: APIClientProtocol {

    // MARK: Properties

    var session: URLSession

    // MARK: Initializers

    init(session: URLSession) {
        self.session = session
    }

    // MARK: Imperatives

    func makeGETDataTaskForResource(
        withURL resourceURL: URL,
        parameters: [String : String],
        andCompletionHandler handler: @escaping (APIClientProtocol.JsonData?, URLSessionTask.TaskError?) -> Void
        ) -> URLSessionDataTask {

        var components = URLComponents(url: resourceURL, resolvingAgainstBaseURL: false)!
        components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        return session.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else {
                handler(nil, .connection)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                handler(nil, .serverResponse)
                return
            }

            handler(data, nil)
        }
    }
}
