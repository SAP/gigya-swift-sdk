//
//  RegisterFlow.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 25/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya
import Flutter

class RegisterFlow<T: GigyaAccountProtocol>: NssFlow {
    var busnessApi: BusinessApiDelegate

    init(busnessApi: BusinessApiDelegate) {
        self.busnessApi = busnessApi
    }

    override func next(method: ApiChannelEvent, params: [String: Any]?, response: @escaping FlutterResult) {
        switch method {
        case .submit:
            let email = params?["email"] as? String ?? ""
            let password = params?["password"] as? String ?? ""
            let params = params?["params"] as? [String: Any] ?? [:]

            busnessApi.callRegister(dataType: T.self, email: email, password: password, params: params) { (result) in
                switch result {
                case .success(let data):
                    let resultData = ["errorCode": 0, "errorMessage": "", "callId": "", "statusCode": 200] as [String : Any]

                    response(resultData)
                case .failure(let error):
                    switch error.error {
                    case .gigyaError(let data):
                        response(FlutterError(code: "\(data.errorCode)", message: data.errorMessage, details: data.toDictionary()))
                    default:
                        response(FlutterError(code: "500", message: "", details: nil))
                    }

                    break
                }
            }
        default:
            break
        }
    }
}
