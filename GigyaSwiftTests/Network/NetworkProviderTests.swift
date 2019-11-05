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
    var sessionService: SessionServiceProtocol?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        config = ioc.container.resolve(GigyaConfig.self)!
        config?.apiKey = "test"
        persistenceService = ioc.container.resolve(PersistenceService.self)!
        sessionService = ioc.container.resolve(SessionServiceProtocol.self)!

        networkProvider = NetworkProvider(config: config!, persistenceService: persistenceService!, sessionService: sessionService!)

        // now set up a configuration to use our mock
        let configx = URLSessionConfiguration.ephemeral
        configx.protocolClasses = [URLProtocolMock.self]

        // and create the URLSession from that
        let session = URLSession(configuration: configx)
        networkProvider?.urlSession = session

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRequest() {

        let gigyaSession = GigyaSession(sessionToken: "test", secret: "test")
        URLProtocolMock.testURLs = ["https:///tesy./tesy": Data("ok".utf8)]

        let req = ApiRequestModel(method: "/tesy", params: [:], isAnonymous: false)
        networkProvider?.sessionService.session = gigyaSession

        networkProvider?.dataRequest(model: req) { (data, error) in
            let result = String(data: data! as Data, encoding: .utf8)
            XCTAssertEqual(result, "ok")
        }
    }

    func testRequestError() {

        let gigyaSession = GigyaSession(sessionToken: "", secret: "")
        let req = ApiRequestModel(method: ".*,ֿ,,]", params: [:], isAnonymous: false)

        networkProvider?.sessionService.session = gigyaSession
        networkProvider?.dataRequest(model: req) { (result, error) in
            XCTAssertNotNil(error)
        }
    }

}
