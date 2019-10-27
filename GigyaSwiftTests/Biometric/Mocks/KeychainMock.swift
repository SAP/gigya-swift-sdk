//
//  KeychainMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 16/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import Gigya

class KeychainMock: KeychainStorageFactory {

    override func add(with name: String, data: Data?, state: KeychainMode = .regular, completionHandler: GSKeychainCompletionHandler?) {

        completionHandler!(KeychainResult.success(data: nil))
    }
    override func get<T: NSObject & NSCoding>(object: T.Type, name: String, _ completionHandler: @escaping ((KeychainResultWithObject<T>) -> Void)) {
        let session = GigyaSession(sessionToken: "123", secret: "123") as! T
//        let archive = try! NSKeyedArchiver.archivedData(withRootObject: session!, requiringSecureCoding: false)

        completionHandler(.success(data: session))

    }

    override func delete(name: String, completionHandler: GSKeychainCompletionHandler?) {
        completionHandler?(KeychainResult.success(data: nil))
    }

}
