//
//  ConflictingAccount.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 15/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct ConflictingAccountHead: Codable {
    let conflictingAccount: ConflictingAccount
}

public struct ConflictingAccount: Codable {

    public let loginProviders: [String]?
    public let loginID: String?

    private enum CodingKeys: String, CodingKey {
        case loginProviders = "loginProviders"
        case loginID = "loginID"
    }
}
