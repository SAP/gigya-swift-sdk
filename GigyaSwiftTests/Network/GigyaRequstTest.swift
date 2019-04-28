////
////  GigyaRequstMock.swift
////  GigyaSwiftTests
////
////  Created by Shmuel, Sagi on 20/03/2019.
////  Copyright © 2019 Gigya. All rights reserved.
////
//
//import XCTest
//@testable import GigyaSwift
//
//class GigyaRequstTest: XCTestCase {
//    var ioc: GigyaContainerUtils?
//
//    var apiService: IOCApiServiceProtocol?
//
//    var provider: GSRequestMock?
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
////        let model = ApiRequestModel(method: "account.getAccount", params: [:])
//        ioc = GigyaContainerUtils()
//        request = NetworkAdapterMock()
//
//        provider = GSRequestMock(forMethod: "123")
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testResponseSuccess() {
//        let dic: [String: Any] = ["callId": "fasfsaf", "errorCode": 123, "statusCode": 200]
//
//        // swiftlint:disable force_try
//        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
//        // swiftlint:enable force_try
//
//        request!.data = jsonData as NSData
//
//        request?.send(model: [String: AnyCodable].self, completion: { (res) in
//            switch res {
//            case .success(let data):
//                XCTAssertNotNil(data)
//            case .failure(let error):
//                XCTFail("Response fail: \(error)")
//            }
//        })
//    }
//
//    func testSendReturnError() {
//        let dic: [String: Any] = ["callId": "fasfsaf", "errorCode": 123, "statusCode": 200]
//
//        // swiftlint:disable force_try
//        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
//        // swiftlint:enable force_try
//
//        requestMock!.data = jsonData as NSData
//        requestMock?.error = NetworkError.dataNotFound
//
//        requst?.send(responseType: [String: AnyCodable].self, completion: { (res) in
//            switch res {
//            case .failure(let error):
//                if case .networkError = error {
//                    XCTAssert(true)
//                }
//            default:
//                XCTFail("Fail")
//            }
//        })
//
//    }
//
//    func testSendReturnErrorFromGigyaObjc() {
//        let error = NSError(domain: "gigya", code: 400093, userInfo: ["callId": "dasdasdsad"])
//
//        requestMock?.error = error
//
//        requst?.send(responseType: [String: AnyCodable].self, completion: { (res) in
//            switch res {
//            case .failure(let error):
//                if case .gigyaError(let eee) = error {
//                    XCTAssertNotNil(eee)
//                } else {
//                    XCTFail("Fail")
//                }
//            default:
//                XCTFail("Fail")
//            }
//        })
//
//    }
//
//    func testResponseFailed() {
//        let dic: [String: Any] = ["callId": "fasfsaf", "errorCode": 123, "statusCode": 403]
//
//        // swiftlint:disable force_try
//        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
//        // swiftlint:enable force_try
//
//        requestMock!.data = jsonData as NSData
//        requst?.send(responseType: [String: AnyCodable].self, completion: { (res) in
//            switch res {
//            case .success:
//                XCTFail("Fail")
//            case .failure(let error):
//                XCTAssertNotNil(error)
//            }
//        })
//    }
//
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
//
//    func testResponseGeneric() {
//        let dic: [String: Any] = ["callId": "fasfsaf", "errorCode": 123, "statusCode": 200]
//
//        // swiftlint:disable force_try
//        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
//        // swiftlint:enable force_try
//
//        requestMock!.data = jsonData as NSData
//        requst?.send(responseType: RequestTestModel.self, completion: { (res) in
//            switch res {
//            case .success(let data):
//                XCTAssertNotNil(data.callId)
//                XCTAssertNotNil(data.errorCode)
//                XCTAssertNotNil(data.statusCode)
//            case .failure(let error):
//                XCTAssertNotNil(error)
//            }
//        })
//
//    }
//
//    func testResponseGenericParseError() {
//        let dic: [String: Any] = ["callId": "fasfsaf", "errorCode": 123, "statusCode": 200]
//
//        // swiftlint:disable force_try
//        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
//        // swiftlint:enable force_try
//
//        requestMock!.data = jsonData as NSData
//        requst?.send(responseType: RequestTestParseFailModel.self, completion: { (res) in
//            switch res {
//            case .success:
//                XCTFail("Fail")
//            case .failure(let error):
//                if case .jsonParsingError = error {
//                    XCTAssert(true)
//                } else {
//                    XCTFail("Fail")
//                }
//            }
//        })
//
//    }
//
//    func testApiRequest() {
//        let adapter = NetworkAdapter()
//
//        adapter.send { (res, error) in
//            XCTAssert(true)
//        }
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
//}
