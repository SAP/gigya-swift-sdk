//
//  PersistenceService.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 24/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public final class PersistenceService {
    var isStartSdk: Bool = false
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
    
    internal var idsRefreshTime: Double? {
        get {
            return UserDefaults.standard.double(forKey: InternalConfig.Storage.idsRefreshTime)
        }
    }

    internal var hasRunBefore: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: InternalConfig.Storage.hasRunBefore)
        }
    }

    internal var biometricAllow: Bool {
        get {
            return UserDefaults.standard.bool(forKey: InternalConfig.Storage.biometricAllow)
        }
    }

    internal var biometricLocked: Bool? {
        get {
            return UserDefaults.standard.bool(forKey: InternalConfig.Storage.biometricLocked)
        }
    }

    internal var expirationSession: Double? {
        get {
            return UserDefaults.standard.double(forKey: InternalConfig.Storage.expirationSession)
        }
    }

    internal var pushKey: String? {
        get {
            return UserDefaults.standard.string(forKey: InternalConfig.Storage.pushKey)
        }
    }
    
    public var webAuthnlist: [GigyaWebAuthnCredential] {
        get {
            if let data = UserDefaults.standard.object(forKey: InternalConfig.Storage.webAuthn) as? Data {
                do {
                    return try PropertyListDecoder().decode([GigyaWebAuthnCredential].self, from: data)
                } catch {
                    return []
                }
            }
            
            return []
        }
    }

    // save gmid, ucid to userDefaults
    internal func save(ids: InitSdkIdsModel) {
        GigyaLogger.log(with: self, message: "save Start")
        UserDefaults.standard.setValue(ids.gcid, forKey: InternalConfig.Storage.GMID)
        UserDefaults.standard.setValue(ids.ucid, forKey: InternalConfig.Storage.UCID)
        UserDefaults.standard.setValue(ids.refreshTime, forKey: InternalConfig.Storage.idsRefreshTime)
        GigyaLogger.log(with: self, message: "save done")
    }

    internal func setBiometricEnable(to allow: Bool) {
        UserDefaults.standard.setValue(allow, forKey: InternalConfig.Storage.biometricAllow)
    }

    internal func setBiometricLocked(to enable: Bool) {
        UserDefaults.standard.setValue(enable, forKey: InternalConfig.Storage.biometricLocked)
    }

    internal func setExpirationSession(to double: Double) {
        UserDefaults.standard.setValue(double, forKey: InternalConfig.Storage.expirationSession)
    }

    internal func setPushKey(to string: String) {
        UserDefaults.standard.setValue(string, forKey: InternalConfig.Storage.pushKey)
    }
    
    func addWebAuthnKey(model: GigyaWebAuthnCredential) {
        var list = webAuthnlist
        list.append(model)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(list), forKey: InternalConfig.Storage.webAuthn)
    }
    
    internal func removeAllWebAuthnKeys() {
        UserDefaults.standard.removeObject(forKey: InternalConfig.Storage.webAuthn)
    }
    
    internal func removeIds() {
        UserDefaults.standard.removeObject(forKey: InternalConfig.Storage.GMID)
        UserDefaults.standard.removeObject(forKey: InternalConfig.Storage.UCID)
    }
}
