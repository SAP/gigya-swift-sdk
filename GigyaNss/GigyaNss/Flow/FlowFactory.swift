//
//  CreateFlowFactory.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 25/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya

class FlowFactory<T: GigyaAccountProtocol> {
    func create(identifier: Flow) -> NssFlow {
        switch identifier {
        case .register:
            return GigyaNss.shared.dependenciesContainer.resolve(RegisterFlow<T>.self)!
        case .login:
            return GigyaNss.shared.dependenciesContainer.resolve(LoginFlow<T>.self)!
        }
    }
}

enum Flow: String {
    case register
    case login
}
