//
//  RegisterFlow.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 25/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya
import Flutter

class RegisterAction<T: GigyaAccountProtocol>: NssAction<T> {
    var busnessApi: BusinessApiDelegate

    init(busnessApi: BusinessApiDelegate) {
        self.busnessApi = busnessApi
    }

    override func next(method: ApiChannelEvent, params: [String: Any]?) {
        super.next(method: method, params: params)

        switch method {
        case .submit:
            let email = params?["email"] as? String ?? ""
            let password = params?["password"] as? String ?? ""
            let params = params?["params"] as? [String: Any] ?? [:]

            busnessApi.callRegister(dataType: T.self, email: email, password: password, params: params, completion: delegate!.getMainLoginClosure())
        default:
            break
        }
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}
