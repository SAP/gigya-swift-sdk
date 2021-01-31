//
//  OtpService.swift
//  GigyaAuth
//
//  Created by Shmuel, Sagi on 21/01/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Gigya

/**
 The `GigyaOtpResult` is an Enum representing a result from login api.
 */
@frozen
public enum GigyaOtpResult<ResponseType: GigyaAccountProtocol> {
    case success(data: ResponseType)

    case pendingVerification(resolver: OtpServiceVerifyProtocol)

    case failure(error: NetworkError)
}

public protocol OtpServiceProtocol {

    /**
     This method is used to trigger a Phone Number OTP Login flow.
     Returns a vToken, and sends an email containing the authentication code to the user.

     - Parameter phoneNumber: User's phone number.
     - Parameter params:        .
     */

    func login<T>(phone: String, completion: @escaping (GigyaOtpResult<T>) -> Void)

    func login<T>(phone: String, params: [String: Any], completion: @escaping (GigyaOtpResult<T>) -> Void)

    func update<T>(phone: String, completion: @escaping (GigyaOtpResult<T>) -> Void)

    func update<T>(phone: String, params: [String: Any], completion: @escaping (GigyaOtpResult<T>) -> Void)

}

enum OtpType {
    case login, update

    func getApi() -> String {
        switch self {
        case .login:
            return "accounts.otp.login"
        case .update:
            return "accounts.otp.update"
        }
    }
}

public protocol OtpServiceVerifyProtocol {
    var vToken: String? { get }
    var data: [String: Any]? { get }

    /**
     This method is used to log in users via Phone Number Login. It requires the vToken and code returned from accounts.OTP.sendCode.

     - Parameter code:   OTP code.
     */

    func verify(code: String)
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
                handler(.success(data: data))
                break
            case .failure(let error):
                handler(.failure(error: error))
            }
        }
    }
}

public class OtpService<T: GigyaAccountProtocol>: OtpServiceProtocol {

    let busnessApi: BusinessApiDelegate

    private var type: OtpType = .login

    private var _vToken: String?
    private var _data: [String: Any]?

    private var completionHandler: Any?

    init(businessApi: BusinessApiDelegate) {
        self.busnessApi = businessApi
    }

    public func login<T: GigyaAccountProtocol>(phone: String, completion: @escaping (GigyaOtpResult<T>) -> Void) {
        login(phone: phone, params: [:], completion: completion)
    }

    public func login<T: GigyaAccountProtocol>(phone: String, params: [String : Any], completion: @escaping (GigyaOtpResult<T>) -> Void) {
        type = .login

        var params = params
        params["phoneNumber"] = phone
        sendRequest(params: params, completion: completion)
    }

    public func update<T: GigyaAccountProtocol>(phone: String, completion: @escaping (GigyaOtpResult<T>) -> Void) {
        update(phone: phone, params: [:], completion: completion)
    }

    public func update<T: GigyaAccountProtocol>(phone: String, params: [String : Any], completion: @escaping (GigyaOtpResult<T>) -> Void) {
        type = .update

        var params = params
        params["phone"] = phone
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

                completion(.pendingVerification(resolver: self as OtpServiceVerifyProtocol))
            case .failure(let error):
                completion(.failure(error: error))
            }
        }
    }
}

