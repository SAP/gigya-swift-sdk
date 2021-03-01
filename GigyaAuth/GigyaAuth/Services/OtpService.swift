//
//  OtpService.swift
//  GigyaAuth
//
//  Created by Shmuel, Sagi on 21/01/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Gigya

public class OtpService<T: GigyaAccountProtocol>: OtpServiceProtocol {

    let busnessApi: BusinessApiDelegate
    var accountService: AccountServiceProtocol

    private var type: OtpType = .login

    private var _vToken: String?
    private var _data: [String: Any]?
    private var _params: [String: Any]?

    private var completionHandler: Any?

    init(businessApi: BusinessApiDelegate, accountService: AccountServiceProtocol) {
        self.busnessApi = businessApi
        self.accountService = accountService
    }

    public func login<T: GigyaAccountProtocol>(phone: String, completion: @escaping (GigyaOtpResult<T>) -> Void) {
        login(phone: phone, params: [:], completion: completion)
    }

    public func login<T: GigyaAccountProtocol>(phone: String, params: [String : Any], completion: @escaping (GigyaOtpResult<T>) -> Void) {
        type = .login

        var params = params
        self._params = params

        params["phoneNumber"] = phone
        sendRequest(params: params, completion: completion)
    }

    public func update<T: GigyaAccountProtocol>(phone: String, completion: @escaping (GigyaOtpResult<T>) -> Void) {
        update(phone: phone, params: [:], completion: completion)
    }

    public func update<T: GigyaAccountProtocol>(phone: String, params: [String : Any], completion: @escaping (GigyaOtpResult<T>) -> Void) {
        type = .update

        var params = params
        self._params = params

        params["phoneNumber"] = phone
        sendRequest(params: params, completion: completion)
    }


    private func sendRequest<T: GigyaAccountProtocol>(params: [String : Any], completion: @escaping (GigyaOtpResult<T>) -> Void) {
        completionHandler = completion

        busnessApi.sendApi(api: "accounts.otp.sendCode", params: params) { [weak self] (result) in
            guard let self = self else { return }

            switch result {
            case .success(data: let data):
                self._vToken = data["vToken"]?.value as? String
                self._data = data

                completion(.pendingOtpVerification(resolver: self as OtpServiceVerifyProtocol))
            case .failure(let error):
                let e = LoginApiError<T>(error: error)
                completion(.failure(error: e))
            }
        }
    }
}

extension OtpService: OtpServiceVerifyProtocol {

    public var vToken: String? {
        return _vToken
    }

    public var data: [String : Any]? {
        return _data
    }

    public func verify(code: String) {
        busnessApi.sendApi(dataType: T.self, api: type.getApi(), params: ["code": code, "vToken": vToken ?? ""]) { [weak self] result in
            let handler: (GigyaOtpResult<T>) -> Void = self!.completionHandler as! (GigyaOtpResult<T>) -> Void

            switch result {
            case .success(data: let data):
                if self?.type == .update {
                    self?.accountService.clear()

                    self?.busnessApi.callGetAccount(dataType: T.self, params: self?._params ?? [:]) { (result) in
                        switch result {
                        case .success(data: let data):
                            handler(.success(data: data))
                        case .failure(let error):
                            let e = LoginApiError<T>(error: error)
                            handler(.failure(error: e))
                        }
                    }
                } else {
                    self?.accountService.account = data

                    handler(.success(data: data))
                }
            case .failure(let error):
                self?.busnessApi.callInterruptionResolver(dataType: T.self, error: error) { (result) in
                    switch result {
                    case .success(data: let data):
                        handler(.success(data: data))
                    case .failure(let error):
                        handler(.failure(error: error))
                    }
                }

            }
        }
    }
}
