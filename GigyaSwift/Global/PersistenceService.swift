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
    let config: GigyaConfig?

    private var apiKey: String {
        return config?.apiKey ?? "zxyt"
    }

    init(config: GigyaConfig?) {
        self.config = config
    }

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
            if let data = GigyaKeyChainService.read(key: InternalConfig.Storage.webAuthnKey(apiKey: apiKey)) {
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
        UserDefaults.standard.setValue(ids.gcid, forKey: InternalConfig.Storage.GMID)
        UserDefaults.standard.setValue(ids.ucid, forKey: InternalConfig.Storage.UCID)
        UserDefaults.standard.setValue(ids.refreshTime, forKey: InternalConfig.Storage.idsRefreshTime)
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
        if let data = try? PropertyListEncoder().encode(list) {
            GigyaKeyChainService.save(key: InternalConfig.Storage.webAuthnKey(apiKey: apiKey), valueData: data)
        }
    }
    
    internal func removeAllWebAuthnKeys() {
        GigyaKeyChainService.delete(key: InternalConfig.Storage.webAuthnKey(apiKey: apiKey))
    }
}

class GigyaKeyChainService {
    static func save(key: String, valueData: Data) {
        var query = getQuery()
        query[String(kSecAttrAccount)] = key
        var attributes = getQuery()
        attributes[String(kSecAttrAccount)] = key
        attributes[String(kSecValueData)] = valueData
        attributes[String(kSecAttrAccessible)] = kSecAttrAccessibleAfterFirstUnlock
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == noErr {
            let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if updateStatus != noErr {
                SecItemDelete(query as CFDictionary)
                let addStatus = SecItemAdd(attributes as CFDictionary, nil)
                if addStatus != noErr {
                    GigyaLogger.log(with: self, message: "Failed to store value for key = '\(addStatus)'")
                }
            }
        } else {
            SecItemDelete(query as CFDictionary)
            let status = SecItemAdd(attributes as CFDictionary, nil)
            if status != noErr {
                GigyaLogger.log(with: self, message: "Failed to add value for key '\(key)'")
            }
        }
    }

    static func read(key: String) -> Data? {
        var query = getQuery()
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        query[String(kSecReturnData)] = kCFBooleanTrue
        query[String(kSecAttrAccount)] = key
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == noErr, let data = dataTypeRef as? Data {
            return data
        } else {
            return nil
        }
    }

    static func delete(key: String) {
        var query = getQuery()
        query[String(kSecAttrAccount)] = key
        query[String(kSecAttrSynchronizable)] = kSecAttrSynchronizableAny
        SecItemDelete(query as CFDictionary)
    }

    private class func getQuery() -> [String: Any] {
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        var query: [String : Any] = [
            String(kSecClass): String(kSecClassGenericPassword),
            String(kSecAttrService): bundleId
        ]
        query[String(kSecAttrSynchronizable)] = kCFBooleanTrue
        return query
    }
}
