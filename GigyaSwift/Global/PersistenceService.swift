//
//  PersistenceService.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 24/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class PersistenceService {
    var isInitSdk: Bool = false

    // MARK: - UserDefault

    internal var gmid: String? {
        get {
            return UserDefaults.standard.string(forKey: InternalConfig.Storage.GMID)
        }
    }

    internal var ucid: String? {
        get {
            return UserDefaults.standard.string(forKey: InternalConfig.Storage.UCID)
        }
    }

    internal var hasRunBefore: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: InternalConfig.Storage.hasRunBefore)
        }
    }

    internal var biometricAllow: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: InternalConfig.Storage.biometricAllow)
        }
    }

    internal var biometricLocked: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: InternalConfig.Storage.biometricLocked)
        }
    }

    // save gmid, ucid to userDefaults
    internal func save(ids: InitSdkIdsModel) {
        UserDefaults.standard.setValue(ids.gmid, forKey: InternalConfig.Storage.GMID)
        UserDefaults.standard.setValue(ids.ucid, forKey: InternalConfig.Storage.UCID)
    }

    internal func setBiometricEnable(to allow: Bool) {
        UserDefaults.standard.setValue(allow, forKey: InternalConfig.Storage.biometricAllow)
    }

    internal func setBiometricLocked(to enable: Bool) {
        UserDefaults.standard.setValue(enable, forKey: InternalConfig.Storage.biometricLocked)
    }
}
