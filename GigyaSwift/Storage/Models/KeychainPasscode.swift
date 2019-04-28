//
//  KeychainPasscode.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 28/02/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

internal enum KeychainPasscode: String, Codable {
    case ignorePasscode = "keychainIgnorePasscode"
    case preferPasscode = "keychainPreferPasscode"
    case requirePasscode = "keychainRequirePasscode"
}

internal enum KeychainResult {
    case succses(data: Data?)
    case error(error: KeychainError)
}

internal enum KeychainError {
    case addFailed
    case getAttributeFailed
    case deleteFailed
}
