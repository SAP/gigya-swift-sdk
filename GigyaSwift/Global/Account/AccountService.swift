//
//  AccountManager.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 06/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

final class AccountService: AccountServiceProtocol {
    var account: Any? {
        didSet {
            self.accountInvalidationTimestamp = Int(Date().timeIntervalSince1970) + accountCacheTime.minToSec()
        }
    }

    private var accountInvalidationTimestamp: Int = 0

    // caches time in minutes
    private var accountCacheTime: Int = 5

    func getAccount<T: Codable>() -> T {
        guard let account = account as? T else {
            GigyaLogger.error(with: AccountService.self, message: "something happend with getAccount")
        }
        return account
    }

    func isCachedAccount() -> Bool {
        let timeNow = Int(Date().timeIntervalSince1970)
        if account != nil && accountInvalidationTimestamp > timeNow {
            return true
        }

        return false
    }

    func setAccount<T: Codable>(newAccount: T) -> [String: AnyObject] {
        guard let oldAccount = account as? T else {
            GigyaLogger.error(with: AccountService.self, message: "something happend with setAccount")
        }

        do {
            let oldAccountDictionary = try DecodeEncodeUtils.encodeToDictionary(obj: oldAccount)
            let newAccountDictionary = try DecodeEncodeUtils.encodeToDictionary(obj: newAccount)


            return getDiff(old: oldAccountDictionary, new: newAccountDictionary)

        } catch {
            GigyaLogger.log(with: self, message: error.localizedDescription)
        }

        return [:]
    }

    func getDiff(old: [String: AnyObject], new: [String: AnyObject]) -> [String: AnyObject] {
        var newObject: [String: AnyObject] = [:]

        for item in new {
            if let itemAsDictionary = item.value as? [String: AnyObject], let olditemAsDictionary = old[item.key] as? [String: AnyObject] {
                newObject[item.key] = getDiff(old: olditemAsDictionary, new: itemAsDictionary) as AnyObject
            } else {
                if !item.value.isEqual(old[item.key]) {
                    newObject[item.key] = item.value
                }
            }
        }

        return newObject
    }

    func clear() {
        GigyaLogger.log(with: self, message: "[clear]")

        account = nil
        accountInvalidationTimestamp = 0
    }

}
