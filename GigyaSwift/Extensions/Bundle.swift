//
//  Bundle.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 05/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

extension Bundle {
    static func appName() -> String {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return ProcessInfo.processInfo.environment["XCInjectBundle"] ?? ""
        }

        guard let dictionary = Bundle.main.infoDictionary else {
            return ""
        }

        if let version: String = dictionary["CFBundleName"] as? String {
            return version
        } else {
            return ""
        }
    }
}
