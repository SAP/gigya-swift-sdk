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
    func create(identifier: NssAction) -> Action<T> {
        var action: Action<T>

        switch identifier {
        case .register:
            action = GigyaNss.shared.dependenciesContainer.resolve(RegisterAction<T>.self)!
        case .login:
            action = GigyaNss.shared.dependenciesContainer.resolve(LoginAction<T>.self)!
        case .setAccount:
            action = GigyaNss.shared.dependenciesContainer.resolve(SetAccountAction<T>.self)!
        case .forgotPassword:
            action = GigyaNss.shared.dependenciesContainer.resolve(ForgotPasswordAction<T>.self)!
        case .linkAccount:
            action = GigyaNss.shared.dependenciesContainer.resolve(LinkAccountAction<T>.self)!
        case .unknown:
            GigyaLogger.error(with: GigyaNss.self, message: "action not found")
        }
        action.actionId = identifier
        
        return action
    }
}

public enum NssAction: String {
    case register
    case login
    case setAccount
    case forgotPassword
    case linkAccount
    case unknown
}
