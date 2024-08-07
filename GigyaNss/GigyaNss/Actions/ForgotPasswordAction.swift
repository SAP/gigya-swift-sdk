//
//  ForgotPasswordAction.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 11/08/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya
import Flutter

class ForgotPasswordAction<T: GigyaAccountProtocol>: Action<T> {

    init(businessApi: BusinessApiDelegate, jsEval: JsEvaluatorHelper) {
        super.init()
        self.businessApi = businessApi
        self.jsEval = jsEval
    }

    override func next(method: ApiChannelEvent, params: [String: Any]?) {
        super.next(method: method, params: params)

        switch method {
        case .submit:
            businessApi?.callForgotPassword(params: params ?? [:], completion: self.delegate!.getGenericClosure())
        default:
            break
        }
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}
