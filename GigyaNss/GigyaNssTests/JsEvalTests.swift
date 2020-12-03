//
//  JsEvalTests.swift
//  GigyaNssTests
//
//  Created by Shmuel, Sagi on 05/11/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaNss

class JsEvalTests: XCTestCase {
    let jsEval = JsEvaluatorHelper()

    override func setUp() {
        jsEval.setData(data: ["account": "{profile: {firstName: 'Sagi'}}"])
        jsEval.setConditions(data: [
                                "cId123": "account.profile.firstName == 'Sagi'",
                                "cId124": "account.profile.firstName == 'Tal'",
        ])
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCondition() throws {
        let result = jsEval.eval()

        print(result)


    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
