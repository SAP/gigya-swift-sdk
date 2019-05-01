//
//  AccountManager.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 06/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class AccountService: IOCAccountServiceProtocol {
    var account: Any? {
        didSet {
            self.accountInvalidationTimestamp = Int(Date().timeIntervalSince1970) + accountCacheTime.minToSec()
        }
    }

    private var accountInvalidationTimestamp: Int = 0
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

    func clear() {
        account = nil
        accountInvalidationTimestamp = 0
    }

}
