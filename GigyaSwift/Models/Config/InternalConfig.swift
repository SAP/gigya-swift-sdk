//
//  Config.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 03/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct InternalConfig {
    struct General {
        internal static let version = "\(GigyaDefinitions.versionPrefix ?? "")ios_swift_1.1.8"
        internal static let sdkDomain = "com.gigya.GigyaSDK"
        internal static let defaultLang = "en"
    }

    struct Storage {
        // Keychain Configuration
        internal static let defaultApiDomain = "us1.gigya.com"
        internal static let serviceName = "com.gigya.GigyaSDK"
        internal static let keySession = "com.gigya.GigyaSDK:Session"
        internal static let defaultTouchIDMessage = "Please authenticate to proceed"

        // UserDefaults objects
        internal static let UCID = "com.gigya.GigyaSDK:ucid"
        internal static let GMID = "com.gigya.GigyaSDK:gmid"
        internal static let biometricAllow = "com.gigya.GigyaSDK:biometricAllow"
        internal static let biometricLocked = "com.gigya.GigyaSDK:biometricLocked"
        internal static let hasRunBefore = "com.gigya.GigyaSDK:hasRunBefore"
        internal static let expirationSession = "com.gigya.GigyaSDK:expirationSession"
        internal static let pushKey = "com.gigya.GigyaTfa:pushKey"

    }

    struct Network {
        internal static let requestTimeoutDefult: Double = 60
    }
}
