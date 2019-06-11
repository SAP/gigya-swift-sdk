//
//  GigyaSendTest.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class GigyaCoreTest: XCTestCase {

    let ioc = GigyaContainerUtils()
    var gigya = GigyaSwift.sharedInstance()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil
        GigyaSwift.sharedInstance().container = ioc.container

        GigyaSwift.sharedInstance().initWithApi(apiKey: "123")

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

    }

    func testSendRegular() {
        let dic: [String: Any] = ["callId": "fasfsaf", "errorCode": 0, "statusCode": 200]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        ResponseDataTest.resData = jsonData

        GigyaSwift.sharedInstance().send(api: "dasd") { (res) in
            if case .success = res {
                XCTAssert(true)
            } else {
                XCTFail("Fail")
            }
        }
    }

    func testSendApiGeneric() {

        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

//        let model = RequestTestModel(callId: "34324", errorCode: 0, statusCode: 200)

        ResponseDataTest.resData = jsonData

        GigyaSwift.sharedInstance().send(dataType: RequestTestModel.self, api: "adas") { (res) in
            if case .success = res {
                XCTAssert(true)
            } else {
                XCTFail("Fail")
            }
        }
    }

    func testLogin() {
        let accountDic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200,
                                         "UID": "", "UIDSignature": "", "apiVersion": 1,
                                         "created": "", "createdTimestamp": 2.2, "isActive": false,
                                         "isRegistered": false, "isVerified": false, "lastLogin": "",
                                         "lastLoginTimestamp": 2.2, "lastUpdated": "", "lastUpdatedTimestamp": 2.2,
                                         "loginProvider": "", "oldestDataUpdated": "", "oldestDataUpdatedTimestamp": 2.2,
                                         "registered": "", "registeredTimestamp": 2.2, "signatureTimestamp": "",
                                         "socialProviders": "", "verified": "", "verifiedTimestamp": 2.2, "regToken": ""]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: accountDic, options: .prettyPrinted)
        // swiftlint:enable force_try

        ResponseDataTest.resData = jsonData

        GigyaSwift.sharedInstance().login(loginId: "test@test.com", password: "141414") { (res) in
            if case .success = res {
                XCTAssert(true)
            } else {
                XCTFail("Fail")
            }
        }
    }

    func testGetAccount() {
        let accountDic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200,
                                         "UID": "", "UIDSignature": "", "apiVersion": 1,
                                         "created": "", "createdTimestamp": 2.2, "isActive": false,
                                         "isRegistered": false, "isVerified": false, "lastLogin": "",
                                         "lastLoginTimestamp": 2.2, "lastUpdated": "", "lastUpdatedTimestamp": 2.2,
                                         "loginProvider": "", "oldestDataUpdated": "", "oldestDataUpdatedTimestamp": 2.2,
                                         "registered": "", "registeredTimestamp": 2.2, "signatureTimestamp": "",
                                         "socialProviders": "", "verified": "", "verifiedTimestamp": 2.2, "regToken": ""]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: accountDic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData

        GigyaSwift.sharedInstance().getAccount { (res) in
            if case .success = res {
                XCTAssert(true)
            } else {
                XCTFail("Fail")
            }
        }
    }

    func testGetAccountFailed() {
        let accountService = GigyaSwift.sharedInstance().container?.resolve(IOCAccountServiceProtocol.self)
        accountService?.account = [String: String]()

        ResponseDataTest.resData = nil
        expectFatalError(expectedMessage: "[AccountService]: something happend with getAccount ") {
            GigyaSwift.sharedInstance().getAccount { (res) in
                if case .success = res {
                    XCTAssert(true)
                } else {
                    XCTFail("Fail")
                }
            }
        }
    }

    func testGetAccountFromHip() {
        let accountDic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200,
                                         "UID": "", "UIDSignature": "", "apiVersion": 1,
                                         "created": "", "createdTimestamp": 2.2, "isActive": false,
                                         "isRegistered": false, "isVerified": false, "lastLogin": "",
                                         "lastLoginTimestamp": 2.2, "lastUpdated": "", "lastUpdatedTimestamp": 2.2,
                                         "loginProvider": "", "oldestDataUpdated": "", "oldestDataUpdatedTimestamp": 2.2,
                                         "registered": "", "registeredTimestamp": 2.2, "signatureTimestamp": "",
                                         "socialProviders": "", "verified": "", "verifiedTimestamp": 2.2, "regToken": ""]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: accountDic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData

        GigyaSwift.sharedInstance().getAccount { (res) in
            if case .success = res {
                GigyaSwift.sharedInstance().getAccount { rrr in
                    switch rrr {
                    case .success(let data):
                        XCTAssertNotNil(data)
                    case .failure:
                        XCTFail("Fail")
                    }
                }
            } else {
                XCTFail("Fail")
            }
        }
    }

    func testGetAccountError() {
        ResponseDataTest.resData = nil

        GigyaSwift.sharedInstance().getAccount { (res) in
            if case .success = res {
                XCTFail("Fail")
            } else {
                XCTAssert(true)
            }
        }
    }

    func testLogout() {
        GigyaSwift.sharedInstance().logout() { result in

        }

        XCTAssert(!GigyaSwift.sharedInstance().isLoggedIn())
    }

    func testRegister() {
        let accountDic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200,
                                         "UID": "", "UIDSignature": "", "apiVersion": 1,
                                         "created": "", "createdTimestamp": 2.2, "isActive": false,
                                         "isRegistered": false, "isVerified": false, "lastLogin": "",
                                         "lastLoginTimestamp": 2.2, "lastUpdated": "", "lastUpdatedTimestamp": 2.2,
                                         "loginProvider": "", "oldestDataUpdated": "", "oldestDataUpdatedTimestamp": 2.2,
                                         "registered": "", "registeredTimestamp": 2.2, "signatureTimestamp": "",
                                         "socialProviders": "", "verified": "", "verifiedTimestamp": 2.2, "regToken": ""]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: accountDic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData

        GigyaSwift.sharedInstance().register(params: ["email": "sadfsaf@dasf.com", "password": "123123"]) { (result) in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure:
                XCTFail("Fail")
            }
        }
    }

    func testRegisterFail() {

        ResponseDataTest.resData = nil

        GigyaSwift.sharedInstance().register(params: ["email": "sadfsaf@dasf.com", "password": "123123"]) { (result) in
            switch result {
            case .success:
                XCTFail("Fail")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
        }
    }

    func testAddConnection() {
        let viewController = UIViewController()

        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData
        ResponseDataTest.clientID = "123"
        ResponseDataTest.providerToken = "123"
        ResponseDataTest.providerSecret = "123"

        GigyaSwift.sharedInstance().addConnection(provider: .yahoo, viewController: viewController, params: ["testParam": "test"]) { (result) in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data )
            case .failure(let error):
                XCTFail("Fail: \(error)")
            }
        }
    }


    func testRemoveConnection() {
        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData
        ResponseDataTest.clientID = "123"
        ResponseDataTest.providerToken = "123"
        ResponseDataTest.providerSecret = "123"

        GigyaSwift.sharedInstance().removeConnection(provider: .yahoo) { (result) in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data )
            case .failure(let error):
                XCTFail("Fail: \(error)")
            }
        }
    }

    // MARK: - Exclude tests

    func testShowScreenSet() {
        let viewController = UIViewController()

        GigyaSwift.sharedInstance().showScreenSet(name: "registration", viewController: viewController) { (result) in

        }
    }

//    func testShowComments() {
//        let viewController = UIViewController()
//
//        GigyaSwift.sharedInstance().showComments(viewController: viewController) { _ in
//
//        }
//    }


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
