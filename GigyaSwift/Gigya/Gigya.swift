//
//  GigyaSwift.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 25/02/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
// TODO: Need to make unit test

public final class Gigya {

    private static var storedInstance: GigyaInstanceProtocol?

    internal static var container: IOCContainer?

    // Get container - internal sdk usage
    public static func getContainer() -> IOCContainer {
        guard let container = container else {
            GigyaLogger.error(message: "error")
        }

        return container
    }

    private static func makeContainer<T: GigyaAccountProtocol>(_ type: T.Type) -> IOCContainer {
        if let container = container {
            return container
        } else {
            let gigyaContainer = GigyaIOCContainer<T>()
            self.container = gigyaContainer.container

            return gigyaContainer.container
        }
    }

    // Get instance with default user
    @discardableResult
    public static func sharedInstance() -> GigyaCore<GigyaAccount> {
        return sharedInstance(GigyaAccount.self)
    }

    // Get instance with generic schema
    @discardableResult
    public static func sharedInstance<T: GigyaAccountProtocol>(_ dataType: T.Type) -> GigyaCore<T> {
        if storedInstance == nil {

            self.container = makeContainer(T.self)

            let newInstance = container?.resolve(GigyaCore<T>.self)
            storedInstance = newInstance
            return newInstance!
        }

        guard let instance = storedInstance as? GigyaCore<T> else {
            GigyaLogger.error(with: self, message: "Gigya instance was originally created with a different GigyaAccountProtocol:", generic: storedInstance)
        }

        return instance
    }

    #if DEBUG
    internal static func removeStoredInstance() {
        storedInstance = nil
    }
    #endif
}
