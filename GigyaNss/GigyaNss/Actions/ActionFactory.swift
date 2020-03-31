//
//  CreateFlowFactory.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 25/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya
import Flutter

class ActionFactory<T: GigyaAccountProtocol> {
    func create(identifier: Action) -> NssAction<T> {
        switch identifier {
        case .register:
            return GigyaNss.shared.dependenciesContainer.resolve(RegisterAction<T>.self)!
        case .login:
            return GigyaNss.shared.dependenciesContainer.resolve(LoginAction<T>.self)!
        case .setAccount:
            return GigyaNss.shared.dependenciesContainer.resolve(SetAccountAction<T>.self)!
        }
    }
}

enum Action: String {
    case register
    case login
    case setAccount = "account"
}
