//
//  NetworkProviderTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 06/10/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class NetworkProviderTests: XCTestCase {
    let ioc = GigyaContainerUtils.shared
    var config: GigyaConfig?
    var persistenceService: PersistenceService?
    var networkProvider: NetworkProvider?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        config = ioc.container.resolve(GigyaConfig.self)!
        config?.apiKey = "test"
        persistenceService = ioc.container.resolve(PersistenceService.self)!

        networkProvider = NetworkProvider(url: "", config: config!, persistenceService: persistenceService!)

        // now set up a configuration to use our mock
        let configx = URLSessionConfiguration.ephemeral
        configx.protocolClasses = [URLProtocolMock.self]

        // and create the URLSession from that
        let session = URLSession(configuration: configx)
        networkProvider?.session = session

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRequest() {

        let gigyaSession = GigyaSession(sessionToken: "test", secret: "test")
        URLProtocolMock.testURLs = ["https:///tesy./tesy": Data("ok".utf8)]

        networkProvider?.dataRequest(gsession: gigyaSession, path: "/tesy", params: [:]) { (data, error) in
            let result = String(data: data! as Data, encoding: .utf8)
            XCTAssertEqual(result, "ok")
        }
    }

    func testRequestError() {

        let gigyaSession = GigyaSession(sessionToken: "", secret: "")

        networkProvider?.dataRequest(gsession: gigyaSession, path: ".*,ֿ,,]", params: [:]) { (result, error) in
            XCTAssertNotNil(error)
        }
    }

}
