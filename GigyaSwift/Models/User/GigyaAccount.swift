//
//  GigyaUser.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 10/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

/**
 Protocol used for applying a custom schema for your account model.
 To edit your site schema: https://developers.gigya.com/display/GD/Schema+Editor
 */

public protocol GigyaAccountProtocol: Codable {
    var UID: String? { get set }
    var profile: GigyaProfile? { get set }
    var UIDSignature: String? { get set }
    var apiVersion: Int? { get set }
    var created: String? { get set }
    var createdTimestamp: Double? { get set }

    var isActive: Bool? { get set }
    var isRegistered: Bool? { get set }
    var isVerified: Bool? { get set }

    var lastLogin: String? { get set }
    var lastLoginTimestamp: Double? { get set }
    var lastUpdated: String? { get set }
    var lastUpdatedTimestamp: Double? { get set }
    var loginProvider: String? { get set }
    var oldestDataUpdated: String? { get set }
    var oldestDataUpdatedTimestamp: Double? { get set }
    var registered: String? { get set }
    var registeredTimestamp: Double? { get set }

    //    private SessionInfo sessionInfo;
    var signatureTimestamp: String? { get set }
    var socialProviders: String? { get set }
    var verified: String? { get set }
    var verifiedTimestamp: Double? { get set }

    // TODO: Need to add emails
}

public struct GigyaDataDefault: Codable { }

/**
 The `GigyaAccount` is an default of custom generic schema type.
 To edit your site schema: https://developers.gigya.com/display/GD/Schema+Editor
 */
public struct GigyaAccount: GigyaAccountProtocol {

    public var UID: String?

    public var profile: GigyaProfile?

    public var UIDSignature: String?

    public var apiVersion: Int?

    public var created: String?

    public var createdTimestamp: Double?

    public var isActive: Bool?

    public var isRegistered: Bool?

    public var isVerified: Bool?

    public var lastLogin: String?

    public var lastLoginTimestamp: Double?

    public var lastUpdated: String?

    public var lastUpdatedTimestamp: Double?

    public var loginProvider: String?

    public var oldestDataUpdated: String?

    public var oldestDataUpdatedTimestamp: Double?

    public var registered: String?

    public var registeredTimestamp: Double?

    public var signatureTimestamp: String?

    public var socialProviders: String?

    public var verified: String?

    public var verifiedTimestamp: Double?

    public let data: GigyaDataDefault?

//    private Emails emails;
}
