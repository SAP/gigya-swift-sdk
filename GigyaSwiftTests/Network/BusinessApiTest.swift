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

    var resData: NSData = NSData()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        ioc = GigyaContainerUtils()

        gigyaWrapperMock = ioc?.container.resolve(IOCGigyaWrapperProtocol.self)
        businessApi =  ioc?.container.resolve(IOCBusinessApiServiceProtocol.self)

        ResponseDataTest.resData = nil
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogin() {
        // This is an example of a functional test case.
        let dic: [String: Any] = ["callId": "34324", "errorCode": 0, "statusCode": 200]
        // swiftlint:disable force_try
        let jsonData = try! JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
        // swiftlint:enable force_try
        ResponseDataTest.resData = jsonData

        businessApi?.login(dataType: RequestTestModel.self, loginId: "tes@test.com", password: "151515", completion: { (result) in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure:
                XCTFail("Fail")
            }
        })
    }

    func testLoginWithError() {
        // This is an example of a functional test case.
        ResponseDataTest.resData = nil

        businessApi?.login(dataType: RequestTestModel.self, loginId: "", password: "", completion: { (result) in
            switch result {
            case .success:
                XCTFail("Fail")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
        })
    }

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
                XCTAssertNotNil(data)
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
                XCTAssertNotNil(data )
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

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
