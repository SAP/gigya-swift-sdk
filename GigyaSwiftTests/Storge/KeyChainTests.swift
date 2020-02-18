//
//  KeyChainTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 06/10/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

@available(iOS 11.0, *)
class KeyChainTests: XCTestCase {
    let ioc = GigyaContainerUtils.shared
    var keychainFactory: KeychainStorageFactory?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        keychainFactory = KeychainStorageFactory(plistFactory: ioc.container.resolve(PlistConfigFactory.self)!)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddError() {
        let gsession = GigyaSession(sessionToken: "token", secret: "secret")
        let data = try? NSKeyedArchiver.archivedData(withRootObject: gsession!, requiringSecureCoding: true)

        keychainFactory?.add(with: "testKey", data: data, completionHandler: { result in
            switch result {
            case .success:
                XCTFail()
            case .error(let error):
                XCTAssertNotNil(error)
            }
        })
    }

    func testGetError() {
        keychainFactory?.get(object: GigyaSession.self, name: "testKey", { result in
            switch result {
            case .success:
                XCTFail()
            case .error(let error):
                XCTAssertNotNil(error)
            }
        })
    }

    func testDeleteError() {
        keychainFactory?.delete(name: "testkey", completionHandler: { result in
            switch result {
            case .success:
                XCTFail()
            case .error(let error):
                XCTAssertNotNil(error)
            }
        })
    }

}
