//
//  XCTestCase+FatalError.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 27/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//
import XCTest
@testable import GigyaSwift

extension XCTestCase {
    func expectFatalError(expectedMessage: String, testcase: @escaping () -> Void) {
        let expectation = self.expectation(description: "expectingFatalError")
        var assertionMessage: String?

        FatalErrorUtil.replaceFatalError { message, _, _ in
            assertionMessage = message
            expectation.fulfill()
            self.unreachable()
        }
        DispatchQueue.global(qos: .userInitiated).async(execute: testcase)
        waitForExpectations(timeout: 10) { _ in
            XCTAssertEqual(assertionMessage, expectedMessage)
            FatalErrorUtil.restoreFatalError()
        }
    }
    private func unreachable() -> Never {
        repeat {
            RunLoop.current.run()
        } while (true)
    }
}
