//
//  OtpAction.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 04/02/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Gigya
import Flutter

class OtpAction<T: GigyaAccountProtocol>: Action<T> {
    var otpHelper: OtpProtocol?

    enum State { case phone, code }

    var state: State = .phone

    init(businessApi: BusinessApiDelegate, jsEval: JsEvaluatorHelper, otpHelper: OtpProtocol?) {
        super.init()
        self.businessApi = businessApi
        self.jsEval = jsEval
        self.otpHelper = otpHelper

        checkAavilablity()
    }

    override func next(method: ApiChannelEvent, params: [String: Any]?) {
        super.next(method: method, params: params)

        checkAavilablity()

        switch method {
        case .submit:
            guard let params = params else {
                return
            }

            switch state {
            case .phone:
                let loginId = params["phone"] as? String ?? ""
                let paramss = params["params"] as? [String: Any] ?? [:]
                otpHelper?.login(obj: T.self, phone: loginId, params: paramss) { [weak self] result in
                    let closure = self?.delegate!.getMainLoginClosure(obj: T.self)

                    switch result {
                    case .success:
                        closure!(result)
                    case .failure(let error):
                        let engineClosure = self?.delegate!.getEngineResultClosure()

                        if case .emptyResponse = error.error {
                            self?.state = .code

                            engineClosure!(GigyaResponseModel.successfullyResponse())
                        } else {
                            closure!(.failure(error))
                        }
                    }
                }
            case .code:
                let code = params["code"] as? String ?? ""
                otpHelper?.validate(code: code)
            }
        default:
            break
        }
    }

    private func checkAavilablity() {
        if let otpHelper = otpHelper, otpHelper.isAvailable() == false {
            GigyaLogger.log(with: self, message: "Gigya Auth is not available. please add the GigyaAuth framework to your project.")
        }
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}
