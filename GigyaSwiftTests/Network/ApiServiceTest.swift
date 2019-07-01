//
//  GigyaApiService.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class GigyaApiService: XCTestCase {

    var ioc: GigyaContainerUtils?

    var gigyaWrapperMock: IOCGigyaWrapperProtocol?

    var apiService: IOCApiServiceProtocol?

    var businessApi: IOCBusinessApiServiceProtocol?

    var resData: NSData = NSData()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ioc = GigyaContainerUtils()

        gigyaWrapperMock = ioc?.container.resolve(IOCGigyaWrapperProtocol.self)
        apiService =  ioc?.container.resolve(IOCApiServiceProtocol.self)
        businessApi =  ioc?.container.resolve(IOCBusinessApiServiceProtocol.self)

        ResponseDataTest.resData = nil
        ResponseDataTest.error = nil
        ResponseDataTest.errorCalled = 0
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSendApiService() {
        // This is an example of a functional test case.
        let responseDic: [String: Any] = ["callId": "fasfsaf", "errorCode": 0, "statusCode": 200]
        //swiftlint:disable:next force_try
        let objData = try! JSONSerialization.data(withJSONObject: responseDic, options: .prettyPrinted)

        ResponseDataTest.resData = objData as NSData

        let requestModel = ApiRequestModel(method: "test")

        apiService?.send(model: requestModel, responseType: [String: AnyCodable].self) { (res) in
            switch res {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure:
                XCTFail("Fail")
            }
        }
    }

    func testSendReturnError() {
        let dic: [String: Any] = ["callId": "fasfsaf", "errorCode": 123, "statusCode": 200]

        //swiftlint:disable:next force_try
        let objData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)

        ResponseDataTest.resData = objData as NSData

        let requestModel = ApiRequestModel(method: "test")

        apiService?.send(model: requestModel, responseType: [String: AnyCodable].self) { (res) in
            switch res {
            case .failure(let error):
                switch error {
                case .gigyaError(let data):
                    let json = data.asJson()
                    XCTAssertNotNil(json)
                    XCTAssertNotNil(data.callId)
                    XCTAssertNotNil(data.errorCode)
                    XCTAssertNotNil(data.statusCode)
                default:
                    XCTFail("Fail")
                }

            default:
                XCTFail("Fail")
            }
        }

    }

    func testSendReturnErrorFromGigyaObjc() {
        let error = NSError(domain: "gigya", code: 400093, userInfo: ["callId": "dasdasdsad"])

        ResponseDataTest.error = error

        let requestModel = ApiRequestModel(method: "test")

        apiService?.send(model: requestModel, responseType: [String: AnyCodable].self) { (res) in
            switch res {
            case .failure(let error):
                if case .gigyaError(let eee) = error {
                    XCTAssertNotNil(eee) // TODO: Check object
                } else {
                    XCTFail("Fail")
                }
            default:
                XCTFail("Fail")
            }
        }

    }

    func testGigyaResponseFailed() {
        let dic: [String: Any] = ["callId": "fasfsaf", "errorCode": 123, "statusCode": 403]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        ResponseDataTest.resData = jsonData as NSData

        let requestModel = ApiRequestModel(method: "test")

        apiService?.send(model: requestModel, responseType: [String: AnyCodable].self) { (res) in
            switch res {
            case .success:
                XCTFail("Fail")
            case .failure(let error):
                XCTAssertNotNil(error) // TODO: Check oject
            }
        }
    }

//    func testResponseWithoutData() {
//        requestMock!.data = nil
//        requst?.send(responseType: [String: AnyCodable].self, completion: { (res) in
//            switch res {
//            case .success:
//                XCTFail("Fail")
//            case .failure(let error):
//                if case .dataNotFound = error {
//                    XCTAssert(true)
//                } else {
//                    XCTFail("Fail")
//                }
//            }
//        })
//    }

    func testResponseGeneric() {
        let dic: [String: Any] = ["callId": "fasfsaf", "errorCode": 123, "statusCode": 200]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        ResponseDataTest.resData = jsonData as NSData

        let requestModel = ApiRequestModel(method: "test")

        apiService?.send(model: requestModel, responseType: RequestTestModel.self) { (res) in
            switch res {
            case .success(let data):
                XCTAssertNotNil(data.callId)
                XCTAssertNotNil(data.errorCode)
                XCTAssertNotNil(data.statusCode)
            case .failure(let error):
                XCTAssertNotNil(error)
            }
        }

    }

    func testResponseGenericParseError() {
        let dic: [String: Any] = ["callId": "fasfsaf", "errorcode": 0, "statusCode": 200]

        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try

        ResponseDataTest.resData = jsonData as NSData

        let requestModel = ApiRequestModel(method: "test")

        apiService?.send(model: requestModel, responseType: RequestTestParseFailModel.self) { (res) in
            switch res {
            case .success:
                XCTFail("Fail")
            case .failure(let error):
                if case .jsonParsingError = error {
                    XCTAssert(true)
                } else {
                    XCTFail("Fail")
                }
            }
        }

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
