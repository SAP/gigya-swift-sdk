//
//  RegisterFlow.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 25/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya
import Flutter

class RegisterAction<T: GigyaAccountProtocol>: Action<T> {

    init(busnessApi: BusinessApiDelegate, jsEval: JsEvaluatorHelper) {
        super.init()
        self.busnessApi = busnessApi
        self.jsEval = jsEval
    }

    override func next(method: ApiChannelEvent, params: [String: Any]?) {
        super.next(method: method, params: params)

        switch method {
        case .submit:
            var exportedParams = params

            let email = params?["email"] as? String ?? ""
            let password = params?["password"] as? String ?? ""
            exportedParams?.removeValue(forKey: "email")
            exportedParams?.removeValue(forKey: "password")

            busnessApi?.callRegister(dataType: T.self, email: email, password: password, params: exportedParams!, completion: delegate!.getMainLoginClosure(obj: T.self))
        default:
            break
        }
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}
