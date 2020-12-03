////
////  GigyaNssTests.swift
////  GigyaNssTests
////
////  Created by Shmuel, Sagi on 08/01/2020.
////  Copyright © 2020 Gigya. All rights reserved.
////
//
//import XCTest
//@testable import Gigya
//@testable import GigyaNss
//
//class GigyaNssTests: XCTestCase {
//
//    override func setUp() {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        Gigya.sharedInstance().initFor(apiKey: "123")
//        let bbb = Gigya.getContainer().resolve(BusinessApiServiceProtocol.self)
//        let factory = ActionFactory<GigyaAccount>()
//        let flow = FlowManager(flowFactory: factory)
//        flow.interruptions["pendingRegistration"] = PendingRegistrationResolver<GigyaAccount>(originalError: .emptyResponse, regToken: "", businessDelegate: bbb! as! BusinessApiDelegate) { _ in
//
//        }
//
//        let resolver = flow.getResolver(name: "pendingRegistration", as: PendingRegistrationResolver<GigyaAccount>.self)
////        resolver?.setAccount(params: <#T##[String : Any]#>)
//
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
