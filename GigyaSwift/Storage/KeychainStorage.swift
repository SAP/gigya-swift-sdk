////
////  KeychainStorage.swift
////  GigyaSwift
////
////  Created by Shmuel, Sagi on 28/02/2019.
////  Copyright © 2019 Gigya. All rights reserved.
////
//
//import Foundation
//
//typealias GSKeychainCompletionHandler = (KeychainResult) -> Void
//
//internal class GSKeychainStorage {
//    /*
//     Mehod: add
//     Params: name: String, data: Data?, completionHandler: Clousre
//     Action: Save Dictionary in Keychain with name
//    */
//    internal static func add(with name: String, data: Data?, completionHandler: GSKeychainCompletionHandler?) {
//        guard let data = data else {
//            assertionFailure("There is not have data")
//            return
//        }
//        
//        guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
//                                                                  kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
//                                                                  SecAccessControlCreateFlags.userPresence,
//                                                                  nil) else {
//                                                                    //                    completionHandler?(GSError(withMessage: "Can not require passcode on current version of iOS"));
//                                                                    return
//        }
//
//        let attributes: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
//                                            kSecAttrService: InternalConfig.Storage.serviceName,
//                                            kSecAttrAccount: name,
//                                            kSecValueData: data,
//                                            kSecUseAuthenticationUI: true,
//                                            kSecAttrAccessControl: accessControl]
//        
//        DispatchQueue.global().async {
//            let status = SecItemAdd(attributes as CFDictionary, nil)
//            
//            if status != errSecSuccess {
//                completionHandler?(KeychainResult.error(error: .addFailed))
//                return
//            }
//            
//            completionHandler?(KeychainResult.succses(data: nil))
//            return
//        }
//    }
//    
//    /*
//     Mehod: get
//     Params: name: String, completionHandler: Clousre
//     Action: get Data from Keychain
//     */
//    static internal func get(name: String, _ completionHandler: GSKeychainCompletionHandler?) {
//        let query: [CFString: Any] = [ kSecClass: kSecClassGenericPassword,
//                                      kSecAttrService: InternalConfig.Storage.serviceName,
//                                      kSecAttrAccount: name,
//                                      kSecReturnData: true,
//                                      kSecUseOperationPrompt: InternalConfig.Storage.defaultTouchIDMessage // TODO: need to add message from plist
//                                      ]
//        
//        DispatchQueue.global().async {
//            var extractedData: CFTypeRef?
//            let status = SecItemCopyMatching(query as CFDictionary, &extractedData)
//            
//            if status == errSecSuccess {
//                if let data = extractedData as? Data {
//                    completionHandler?(KeychainResult.succses(data: data))
//                    return
//                } else {
//                    completionHandler?(KeychainResult.error(error: .getAttributeFailed))
//                }
//            } else {
//                    completionHandler?(KeychainResult.error(error: .getAttributeFailed))
//            }
//        }
//    }
//    
//    /*
//     Mehod: delete
//     Params: name: String, completionHandler: Clousre
//     Action: delete Data from Keychain
//     */
//    static internal func delete(name: String, completionHandler: GSKeychainCompletionHandler?) {
//        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
//                                       kSecAttrService: InternalConfig.Storage.serviceName,
//                                       kSecAttrAccount: name]
//        
//        DispatchQueue.global().async {
//            let status = SecItemDelete(query as CFDictionary)
//            
//            if status != errSecSuccess {
//                completionHandler?(KeychainResult.error(error: .deleteFailed))
//            } else {
//                completionHandler?(KeychainResult.succses(data: nil))
//            }
//        }
//    }
//}
