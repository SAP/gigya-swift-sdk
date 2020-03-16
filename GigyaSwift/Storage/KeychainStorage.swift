//
//  KeychainStorage.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 28/02/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

typealias GSKeychainCompletionHandler = (KeychainResult) -> Void

internal class KeychainStorageFactory {

    let plistConfig: PlistConfig?

    init(plistFactory: PlistConfigFactory) {
        self.plistConfig = plistFactory.parsePlistConfig()
    }

    /*
     Mehod: add
     Params: name: String, data: Data?, completionHandler: Clousre
     Action: Save Dictionary in Keychain with name
    */

    func add(with name: String, data: Data?, state: KeychainMode = .regular, completionHandler: GSKeychainCompletionHandler?) {
        guard let data = data else {
            assertionFailure("Keychain data not found.")
            return
        }

        var attributes: [CFString: Any] =  [:]
        attributes = [kSecClass: kSecClassGenericPassword,
                                               kSecAttrService: InternalConfig.Storage.serviceName,
                                               kSecAttrAccount: name,
                                               kSecValueData: data]

        if state == .biometric {
            guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                                      state.attributeAccess(),
                                                                      state.flag(),
                                                                      nil) else {
                                                                                       completionHandler?(.error(error: .getAttributeFailed)) // "Can not require passcode on current version of iOS"
                                                                        return
            }

            attributes[kSecAttrAccessControl] = accessControl
        } else {
            attributes[kSecAttrAccessible] = state.attributeAccess()
        }

        DispatchQueue.global(qos: .utility).async {
            let status = SecItemAdd(attributes as CFDictionary, nil)

            if status != errSecSuccess {
                completionHandler?(KeychainResult.error(error: .addFailed))

                GigyaLogger.log(with: self, message: "[KeychainStorageFactory.add]: failed - \(status.description)")
                return
            }

            completionHandler?(KeychainResult.success(data: nil))
            return
        }
    }

    /*
     Mehod: get
     Params: name: String, completionHandler: Clousre
     Action: get Data from Keychain
     */
    func get<T: NSObject & NSCoding>(object: T.Type, name: String, _ completionHandler: @escaping ((KeychainResultWithObject<T>) -> Void)) {
        let query: [CFString: Any] = [ kSecClass: kSecClassGenericPassword,
                                      kSecAttrService: InternalConfig.Storage.serviceName,
                                      kSecAttrAccount: name,
                                      kSecReturnData: kCFBooleanTrue!,
                                      kSecUseOperationPrompt: plistConfig?.touchIDText ?? InternalConfig.Storage.defaultTouchIDMessage
                                      ]

        DispatchQueue.global(qos: .userInitiated).async {
            var extractedData: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &extractedData)

            if status == errSecSuccess {
                if let data = extractedData as? Data {

                    var session: T?
                    if #available(iOS 11.0, *) {
                        do {
                            session = try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data)
                        } catch (let error) {
                            GigyaLogger.log(with: self, message: "[getSession]: failed unarchiveObject session - \(error.localizedDescription) ")
                        }
                    } else {
                        // Fallback on earlier versions
                        session = NSKeyedUnarchiver.unarchiveObject(with: data) as? T
                    }

                    guard let sessionObject = session else {
                        completionHandler(.error(error: .getAttributeFailed))
                        return
                    }
                    
                    completionHandler(.success(data: sessionObject))
                    GigyaLogger.log(with: self, message: "[KeychainStorageFactory.get]: succses")
                    return
                } else {
                    completionHandler(.error(error: .getAttributeFailed))
                    GigyaLogger.log(with: self, message: "[KeychainStorageFactory.get]: failed - data not found")
                }
            } else {
                    completionHandler(.error(error: .getAttributeFailed))
                    GigyaLogger.log(with: self, message: "[KeychainStorageFactory.get]: failed - \(status)")
            }
        }
    }

    /*
     Mehod: delete
     Params: name: String, completionHandler: Clousre
     Action: delete Data from Keychain
     */
    func delete(name: String, completionHandler: GSKeychainCompletionHandler?) {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                       kSecAttrService: InternalConfig.Storage.serviceName,
                                       kSecAttrAccount: name]

        DispatchQueue.global(qos: .userInitiated).async {
            let status = SecItemDelete(query as CFDictionary)

            if status != errSecSuccess {
                completionHandler?(KeychainResult.error(error: .deleteFailed))
            } else {
                completionHandler?(KeychainResult.success(data: nil))
            }
        }
    }

    deinit {
        GigyaLogger.log(with: self, message: "[KeychainStorageFactory]: deinit")
    }
}
