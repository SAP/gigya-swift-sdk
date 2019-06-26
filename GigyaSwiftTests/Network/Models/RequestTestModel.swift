//
//  RequestTestModel.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 21/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import Gigya

struct RequestTestModel: GigyaAccountProtocol {
    var UID: String?
    
    var profile: GigyaProfile?
    
    var UIDSignature: String?
    
    var apiVersion: Int?
    
    var created: String?
    
    var createdTimestamp: Double?
    
    var isActive: Bool?
    
    var isRegistered: Bool?
    
    var isVerified: Bool?
    
    var lastLogin: String?
    
    var lastLoginTimestamp: Double?
    
    var lastUpdated: String?
    
    var lastUpdatedTimestamp: Double?
    
    var loginProvider: String?
    
    var oldestDataUpdated: String?
    
    var oldestDataUpdatedTimestamp: Double?
    
    var registered: String?
    
    var registeredTimestamp: Double?
    
    var signatureTimestamp: String?
    
    var socialProviders: String?
    
    var verified: String?
    
    var verifiedTimestamp: Double?
    
    let callId: String
    let errorCode: Int
    let statusCode: Int
}

