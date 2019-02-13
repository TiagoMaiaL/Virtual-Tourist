//
//  APIClientTests.swift
//  Virtual TouristTests
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import XCTest
@testable import Virtual_Tourist

/// Tests the main methods of the instances that adopt the APIClientProtocol.
class APIClientTests: XCTestCase {

    // MARK: Properties

    /// The instance under test.
    var apiClient: APIClientProtocol!

    // MARK: Setup / Teardown

    override func setUp() {
        super.setUp()

        apiClient = APIClient(session: URLSession.shared)
    }

    override func tearDown() {
        apiClient = nil

        super.tearDown()
    }

    // MARK: Tests

    func testDataTaskForGETMethodProperlyConfiguresRequest() {
        let url = URL(string: "www.testexample.com")!
        let parameters = ["testQueryParameter1" : "1", "testQueryParameter2": "2"]

        let dataTask = apiClient.makeGETDataTaskForResource(withURL: url, parameters: parameters) { _, _ in }

        guard let request = dataTask.currentRequest,
            let requestUrl = request.url,
            let components = URLComponents(url: requestUrl, resolvingAgainstBaseURL: false) else {
                XCTFail("The data task must have a valid request with a url.")
                return
        }

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(components.host, url.host)
        XCTAssertEqual(components.queryItems?.count, parameters.count)
        XCTAssertEqual(components.query!, "testQueryParameter1=1&testQueryParameter2=2")
    }
}
