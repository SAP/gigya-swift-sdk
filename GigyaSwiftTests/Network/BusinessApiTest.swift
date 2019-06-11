//
//  BuiesnessApiTest.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 17/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class BusinessApiTest: XCTestCase {

    var ioc: GigyaContainerUtils?

    var gigyaWrapperMock: IOCGigyaWrapperProtocol?

    var apiService: IOCApiServiceProtocol?

    var businessApi: IOCBusinessApiServiceProtocol?

    var accountService: IOCAccountServiceProtocol?

    var resData: NSData = NSData()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ioc = GigyaContainerUtils()

        gigyaWrapperMock = ioc?.container.resolve(IOCGigyaWrapperProtocol.self)
        businessApi =  ioc?.container.resolve(IOCBusinessApiServiceProtocol.self)
        accountService =  ioc?.container.resolve(IOCAccountServiceProtocol.self)

        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil
        ResponseDataTest.errorCalled = 0

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Login

    func testLogin() {
        // This is an example of a functional test case.
        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", params: [:], completion: { (result) in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data.callId)
                XCTAssertNotNil(data.errorCode)
                XCTAssertNotNil(data.statusCode)
            case .failure:
                XCTFail("Fail")
            }
        })
    }

    func testLoginWithError() {
        // This is an example of a functional test case.
        ResponseDataTest.resData = nil

        businessApi?.login(dataType: RequestTestModel.self, loginId: "", password: "", params: [:], completion: { (result) in
            switch result {
            case .success:
                XCTFail("Fail")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
        })
    }

    // MARK: - Account

    func testGetAccount() {
        // This is an example of a functional test case.
        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData

        businessApi?.getAccount(dataType: RequestTestModel.self, completion: { (result) in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data.callId)
                XCTAssertNotNil(data.errorCode)
                XCTAssertNotNil(data.statusCode)
            case .failure:
                XCTFail("Fail")
            }
        })
    }

    func testGetAccountDic() {
        // This is an example of a functional test case.
        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData

        businessApi?.getAccount(dataType: [String: AnyCodable].self, completion: { (result) in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data["callId"])
                XCTAssertNotNil(data["errorCode"])
                XCTAssertNotNil(data["statusCode"])
            case .failure(let error):
                XCTFail("Fail: \(error)")
            }
        })
    }

    func testGetAccountError() {
        // This is an example of a functional test case.

        ResponseDataTest.resData = nil

        businessApi?.getAccount(dataType: [String: AnyCodable].self, completion: { (result) in
            switch result {
            case .success:
                XCTFail("Fail")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
        })
    }


    func testSetAccount() {
        let dic: [String: Any] = ["UID": "123", "UIDSignature": "123","callId": "34324", "errorCode": 0, "statusCode": 200]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData

        accountService?.account = GigyaAccount(UID: nil, profile: nil, UIDSignature: nil, apiVersion: 1, created: nil, createdTimestamp: nil, isActive: nil, isRegistered: nil, isVerified: nil, lastLogin: nil, lastLoginTimestamp: nil, lastUpdated: nil, lastUpdatedTimestamp: nil, loginProvider: nil, oldestDataUpdated: nil, oldestDataUpdatedTimestamp: nil, registered: nil, registeredTimestamp: nil, signatureTimestamp: nil, socialProviders: nil, verified: nil, verifiedTimestamp: nil, regToken: nil, data: nil)

        let account = GigyaAccount(UID: "123", profile: nil, UIDSignature: "123", apiVersion: 1, created: nil, createdTimestamp: nil, isActive: nil, isRegistered: nil, isVerified: nil, lastLogin: nil, lastLoginTimestamp: nil, lastUpdated: nil, lastUpdatedTimestamp: nil, loginProvider: nil, oldestDataUpdated: nil, oldestDataUpdatedTimestamp: nil, registered: nil, registeredTimestamp: nil, signatureTimestamp: nil, socialProviders: nil, verified: nil, verifiedTimestamp: nil, regToken: nil, data: nil)

        businessApi?.setAccount(obj: account, completion: { (result) in
            self.businessApi?.getAccount(dataType: GigyaAccount.self, completion: { (reult) in
                switch result {
                case .success(let data):
                    XCTAssertEqual(data.UID, account.UID)
                case .failure(_):
                    XCTFail()
                }
            })
        })
    }

    func testSetAccountFailInGetAccount() {
        let dic: [String: Any] = ["UID": 123, "UIDSignature": "123","callId": "34324", "errorCode": 0, "statusCode": 200]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData

        accountService?.account = GigyaAccount(UID: nil, profile: nil, UIDSignature: nil, apiVersion: 1, created: nil, createdTimestamp: nil, isActive: nil, isRegistered: nil, isVerified: nil, lastLogin: nil, lastLoginTimestamp: nil, lastUpdated: nil, lastUpdatedTimestamp: nil, loginProvider: nil, oldestDataUpdated: nil, oldestDataUpdatedTimestamp: nil, registered: nil, registeredTimestamp: nil, signatureTimestamp: nil, socialProviders: nil, verified: nil, verifiedTimestamp: nil, regToken: nil, data: nil)

        let account = GigyaAccount(UID: "123", profile: nil, UIDSignature: "123", apiVersion: 1, created: nil, createdTimestamp: nil, isActive: nil, isRegistered: nil, isVerified: nil, lastLogin: nil, lastLoginTimestamp: nil, lastUpdated: nil, lastUpdatedTimestamp: nil, loginProvider: nil, oldestDataUpdated: nil, oldestDataUpdatedTimestamp: nil, registered: nil, registeredTimestamp: nil, signatureTimestamp: nil, socialProviders: nil, verified: nil, verifiedTimestamp: nil, regToken: nil, data: nil)

        businessApi?.setAccount(obj: account, completion: { (result) in
            self.businessApi?.getAccount(dataType: GigyaAccount.self, completion: { (reult) in
                switch result {
                case .success:
                    XCTFail()
                case .failure(_):
                    XCTAssert(true)
                }
            })
        })
    }

    func testSetAccountFailed() {
        let dic: [String: Any] = ["callId": "34324", "errorCode": 4, "statusCode": 400]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData

        accountService?.account = GigyaAccount(UID: nil, profile: nil, UIDSignature: nil, apiVersion: 1, created: nil, createdTimestamp: nil, isActive: nil, isRegistered: nil, isVerified: nil, lastLogin: nil, lastLoginTimestamp: nil, lastUpdated: nil, lastUpdatedTimestamp: nil, loginProvider: nil, oldestDataUpdated: nil, oldestDataUpdatedTimestamp: nil, registered: nil, registeredTimestamp: nil, signatureTimestamp: nil, socialProviders: nil, verified: nil, verifiedTimestamp: nil, regToken: nil, data: nil)

        let account = GigyaAccount(UID: "123", profile: nil, UIDSignature: "123", apiVersion: 1, created: nil, createdTimestamp: nil, isActive: nil, isRegistered: nil, isVerified: nil, lastLogin: nil, lastLoginTimestamp: nil, lastUpdated: nil, lastUpdatedTimestamp: nil, loginProvider: nil, oldestDataUpdated: nil, oldestDataUpdatedTimestamp: nil, registered: nil, registeredTimestamp: nil, signatureTimestamp: nil, socialProviders: nil, verified: nil, verifiedTimestamp: nil, regToken: nil, data: nil)

        businessApi?.setAccount(obj: account, completion: { (result) in
            self.businessApi?.getAccount(dataType: GigyaAccount.self, completion: { (reult) in
                switch result {
                case .success:
                    XCTFail()
                case .failure(_):
                    XCTAssert(true)
                }
            })
        })
    }

    // MARK: - Add/Remove Connection
    
    func testRemoveConnection() {
        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData

        businessApi?.removeConnection(providerName: .facebook, completion: { (result) in
            switch result {
            case .success:
                XCTAssert(true)
            case .failure(_):
                XCTAssert(false)
            }
        })
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
