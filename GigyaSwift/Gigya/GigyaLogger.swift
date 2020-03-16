//
//  GigyaLogger.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 27/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public final class GigyaLogger {
    private static var debugMode: Bool = false

    public static func setDebugMode(to debugModeEnabled: Bool) {
        self.debugMode = debugModeEnabled
    }

    internal static func isDebug() -> Bool {
        return self.debugMode
    }

    static func error(message: String) -> Never {
        fatalError("\(message)")
    }

    public static func error(with clazz: AnyClass, message: String, generic: Any? = nil) -> Never {
        fatalError("[\(String(describing: clazz))]: \(message) \(genericName(generic))")
    }

    public static func log(with clazz: Any?, message: String) {
        guard let clazz = clazz else { return }
        
        if debugMode {
            print("[\(genericName(clazz))]: \(message)")
        }
    }

    internal static func genericName(_ clazz: Any?) -> String {
        guard let clazz = clazz else {
            return ""
        }

        let fullName: String = String(describing: clazz)
        let range = fullName.range(of: ".", options: .backwards)
        if let range = range {
            return String(fullName[range.upperBound...]).replacingOccurrences(of: ">", with: "")
        }
        return fullName
    }
}
