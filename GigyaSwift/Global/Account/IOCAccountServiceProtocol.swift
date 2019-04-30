//
//  IOCAccountServiceProtocol.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 21/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol IOCAccountServiceProtocol: class {
    var account: Any? { get set }

    func getAccount<T: Codable>() -> T

    func isCachedAccount() -> Bool
}
