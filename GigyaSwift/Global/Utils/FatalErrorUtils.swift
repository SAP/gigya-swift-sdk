//
//  FatalErrorUtils.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 27/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct FatalErrorUtil {
    static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure

    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }

    static func replaceFatalError(closure: @escaping (String, StaticString, UInt) -> Never) {
        fatalErrorClosure = closure
    }

    static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }
}

func fatalError(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never { 
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
}
