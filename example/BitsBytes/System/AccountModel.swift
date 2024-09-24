//
//  AccountModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 04/09/2024.
//

import Foundation
import Gigya

struct AccountModel: GigyaAccountProtocol {
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
    
    var phoneNumber: String?
    
    
}
