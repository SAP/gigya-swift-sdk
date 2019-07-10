//
//  GigyaConfig.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 25/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol GigyaConfigProtocol {
    var config: GigyaConfig { get set }
}

public class GigyaConfig {
    var apiKey: String?
    var apiDomain: String = InternalConfig.General.sdkDomain
    //TODO: Need to check if need isInitSdk
    var isInitSdk: Bool = false

    var gmid: String? {
        get {
            return UserDefaults.standard.object(forKey: InternalConfig.Storage.GMID) as? String
        }
    }
    
    var ucid: String? {
        get {
           return UserDefaults.standard.object(forKey: InternalConfig.Storage.UCID) as? String
        }
    }

    internal var biometricAllow: Bool? {
        get {
            return UserDefaults.standard.object(forKey: InternalConfig.Storage.biometricAllow) as? Bool
        }
    }

    internal var biometricLocked: Bool? {
        get {
            return UserDefaults.standard.object(forKey: InternalConfig.Storage.biometricLocked) as? Bool
        }
    }

    // save gmid, ucid to userDefaults
    func save(ids: InitSdkIdsModel) {
        UserDefaults.standard.setValue(ids.gmid, forKey: InternalConfig.Storage.GMID)
        UserDefaults.standard.setValue(ids.ucid, forKey: InternalConfig.Storage.UCID)

        UserDefaults.standard.synchronize()
    }
}
