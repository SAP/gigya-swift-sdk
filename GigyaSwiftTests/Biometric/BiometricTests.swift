//
//  BiometricTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 16/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class BiometricTests: XCTestCase {

    let ioc = GigyaContainerUtils.shared
    
    var biometricService: BiometricServiceProtocol?

    var sessionService: SessionServiceProtocol?

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        biometricService = ioc.container.resolve(BiometricServiceProtocol.self)
        sessionService = ioc.container.resolve(SessionServiceProtocol.self)

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func removeDataFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: InternalConfig.Storage.biometricLocked)
        UserDefaults.standard.removeObject(forKey: InternalConfig.Storage.biometricAllow)
    }

    func testIsOptIn() {
        removeDataFromUserDefaults()
        XCTAssertFalse(biometricService!.isOptIn)
    }

    func testIsLocked() {
        removeDataFromUserDefaults()
        XCTAssertFalse(biometricService!.isLocked)
    }
    
    func testOptIn() {
        let session = GigyaSession(sessionToken: "123", secret: "123")

        sessionService?.session = session

        if biometricService?.isOptIn == false {
            biometricService?.optIn(completion: { (res) in
                switch res {
                case .success:
                    XCTAssert(true)
                case .failure:
                    XCTFail()
                }
            })
        }
    }

    func testLock() {
        testOptIn()

        biometricService?.lockSession(completion: { (result) in
            switch result {
            case .success:
                XCTAssert(true)
            case .failure:
                XCTFail()
            }
        })
    }

    func testUnlockSession() {
        testOptIn()
        if biometricService!.isLocked {
            biometricService?.unlockSession(completion: { (result) in
                switch result {
                case .success:
                    self.sessionService?.getSession(completion: { (result) in
                        if result == true {
                            XCTAssertEqual(self.sessionService?.session?.secret, "123")
                        }
                    })
                case .failure:
                    XCTFail()
                }

                let biometricInternal = self.ioc.container.resolve(BiometricServiceInternalProtocol.self)
                biometricInternal?.clearBiometric()
            })
        }
    }

    func testOptOut() {
        testOptIn()

        if biometricService?.isOptIn == true {
            biometricService?.optOut(completion: { (res) in
                switch res {
                case .success:
                    XCTAssert(true)
                case .failure:
                    XCTFail()
                }
            })
        }

    }


    func testLockSessionFail() {
        UserDefaults.standard.setValue(false, forKey: InternalConfig.Storage.biometricAllow)

        biometricService?.lockSession(completion: { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure:
                XCTAssert(true)
            }
        })
    }

        func testDecoderSession() {

            let path = NSTemporaryDirectory() as NSString
            let locToSave = path.appendingPathComponent("teststasks")

            let newTask = GigyaSession(sessionToken: "test", secret: "test")

            // save tasks
            NSKeyedArchiver.archiveRootObject([newTask], toFile: locToSave)

            // load tasks
            let data = NSKeyedUnarchiver.unarchiveObject(withFile: locToSave) as? [GigyaSession]

            XCTAssertNotNil(data)
            XCTAssertEqual(data!.first!.token, "test")
            XCTAssertEqual(data!.first!.secret, "test")

        }
}
