//
//  Config.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 03/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct InternalConfig {
    struct Storage {
        // Keychain Configuration
        internal static let defaultApiDomain = "us1.gigya.com"
        internal static let serviceName = "gigya"
        internal static let keySession = "com.gigya.GigyaSDK:Session"
        internal static let defaultTouchIDMessage = "Please authenticate to proceed"
        
        // UserDefaults objects
        internal static let UCID = "com.gigya.Gigya:ucid"
        internal static let GMID = "com.gigya.Gigya:gmid"
    }
}
