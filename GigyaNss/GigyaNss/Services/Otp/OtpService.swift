//
//  OtpHelper.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 04/02/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Foundation
import Gigya
import GigyaAuth

class OtpService: NSObject, OtpProtocol {
    var resolver: OtpServiceVerifyProtocol?
    var handler: Any?

    func login<T: GigyaAccountProtocol>(obj: T.Type, phone: String, params: [String: Any], completion: (@escaping (GigyaLoginResult<T>) -> Void)) {
        handler = { [weak self] (result: GigyaOtpResult<T>) in
            switch result {
            case .success(let data):
                completion(.success(data: data))
            case .pendingOtpVerification(let resolver):
                self?.resolver = resolver

                let error = LoginApiError<T>(error: NetworkError.emptyResponse)
                completion(.failure(error))
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }

        GigyaAuth.shared.otp.login(phone: phone, params: params, completion: handler as! (GigyaOtpResult<T>) -> Void)
    }

    func validate(code: String) {
        resolver?.verify(code: code)
    }
}

extension OtpHead {
    func isAvailable() -> Bool {
        otpHelper = otpHelper == nil ? OtpService() : otpHelper
        return true
    }

    func login<T: GigyaAccountProtocol>(obj: T.Type, phone: String, params: [String : Any], completion: (@escaping (GigyaLoginResult<T>) -> Void)) {
        guard let otpHelper: OtpProtocol = self.otpHelper as? OtpProtocol else {
            return
        }
        otpHelper.login(obj: T.self, phone: phone, params: params, completion: completion)
    }

    func validate(code: String) {
        guard let otpHelper: OtpProtocol = self.otpHelper as? OtpProtocol else {
            return
        }

        otpHelper.validate(code: code)

    }
}
