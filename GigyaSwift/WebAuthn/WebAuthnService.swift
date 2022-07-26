//
//  WebAuthnService.swift
//  Gigya
//
//  Created by Sagi Shmuel on 30/06/2022.
//  Copyright © 2022 Gigya. All rights reserved.
//

import Foundation
import UIKit

public class WebAuthnService<T: GigyaAccountProtocol> {
    let businessApiService: BusinessApiServiceProtocol
    let webAuthnDeviceIntegration: WebAuthnDeviceIntegration
    let oauthService: OauthService
    let attestationUtils: WebAuthnAttestationUtils
    
    init(businessApiService: BusinessApiServiceProtocol, webAuthnDeviceIntegration: WebAuthnDeviceIntegration, oauthService: OauthService, attestationUtils: WebAuthnAttestationUtils) {
        self.businessApiService = businessApiService
        self.webAuthnDeviceIntegration = webAuthnDeviceIntegration
        self.oauthService = oauthService
        self.attestationUtils = attestationUtils
    }
    
    // MARK: Registration flow
    
    @available(iOS 15.0.0, *)
    public func register(viewController: UIViewController) async -> GigyaApiResult<GigyaDictionary> {
        let initResult = await initRegistration()
        switch initResult {
        case .success(let options):
            return await withCheckedContinuation({ continuation in
                webAuthnDeviceIntegration.register(viewController: viewController, options: options) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    
                    switch result {
                    case .register(let token):

                        let attestation: [String: Any] = self.attestationUtils.makeRegisterData(object: token)
                        
                        Task {
                            let result = await self.registerCredentials(params: ["attestation": attestation, "token": options.token])
                            switch result {
                            case .success(data: let data):
                                self.oauthService.connect(token: data["idToken"]!.value as! String) { result in
                                    continuation.resume(returning: result)
                                } // TODO: idToken - save for delete device?
                            case .failure(let error):
                                continuation.resume(returning: GigyaApiResult.failure(error))
                            }
                        }
                    case .canceled:
                        continuation
                            .resume(returning: .failure(NetworkError.providerError(data: "canceled")))
                    default:
                        let error = GigyaResponseModel(statusCode: .unknown, errorCode: 400301, callId: "", errorMessage: "Operation failed", sessionInfo: nil)
                        continuation
                            .resume(returning: .failure(NetworkError.gigyaError(data: error)))
                    }
                }
            })
        case .failure(let error):
            return .failure(error)
        }
    }
    
    @available(iOS 15.0.0, *)
    func initRegistration() async -> GigyaApiResult<WebAuthnInitRegisterResponseModel> {
        return await withCheckedContinuation() { continuation in
            businessApiService.send(dataType: WebAuthnInitRegisterResponseModel.self, api: GigyaDefinitions.WenAuthn.initRegister, params: [:]) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    @available(iOS 15.0.0, *)
    func registerCredentials(params: [String: Any]) async -> GigyaApiResult<GigyaDictionary> {
        return await withCheckedContinuation({
            continuation in
            businessApiService.send(dataType: GigyaDictionary.self, api: GigyaDefinitions.WenAuthn.registerCredentials, params: params) { result in
                continuation.resume(returning: result)
            }
        })
    }
    
    // MARK: Login flow
        
    @available(iOS 15.0.0, *)
    public func login(viewController: UIViewController) async -> GigyaLoginResult<T> {
        let assertionOptions = await getAssertionOptions()
        
        switch assertionOptions {
        case .success(let options):
            return await withCheckedContinuation() { continuation in
                webAuthnDeviceIntegration.login(viewController: viewController, options: options) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    
                    switch result {
                    case .login(let token):
                        let attestation: [String: Any] = self.attestationUtils.makeLoginData(object: token)
                        
                        Task {
                            let result =  await self.verifyAssertion(params: ["authenticatorAssertion": attestation, "token": options.token])
                            switch result {
                            case .success(data: let data):
                                let user: GigyaLoginResult<T> = await self.oauthService.authorize(token: data["idToken"]!.value as! String) // idToken for login
                                continuation.resume(returning: user)
                            case .failure(let error):
                                continuation.resume(returning: .failure(LoginApiError(error: error)))
                            }
                        }
                    case .canceled:
                        continuation
                            .resume(returning: .failure(LoginApiError(error: NetworkError.providerError(data: "canceled"))))
                    default:
                        let error = GigyaResponseModel(statusCode: .unknown, errorCode: 400301, callId: "", errorMessage: "Operation failed", sessionInfo: nil)
                        continuation
                            .resume(returning: .failure(LoginApiError(error: NetworkError.gigyaError(data: error))))
                    }
                }
            }
        case .failure(let error):
            return .failure(LoginApiError(error: error))
        }
    }
    
    @available(iOS 15.0.0, *)
    func getAssertionOptions() async -> GigyaApiResult<WebAuthnGetOptionsResponseModel> {
        return await withCheckedContinuation({
            continuation in
            businessApiService.send(dataType: WebAuthnGetOptionsResponseModel.self, api: GigyaDefinitions.WenAuthn.getAssertionOptions, params: [:]) { result in
                continuation.resume(returning: result)
            }
        })
    }
    
    @available(iOS 15.0.0, *)
    func verifyAssertion(params: [String: Any]) async -> GigyaApiResult<GigyaDictionary> {
        return await withCheckedContinuation({
            continuation in
            businessApiService.send(dataType: GigyaDictionary.self, api: GigyaDefinitions.WenAuthn.verifyAssertion, params: params) { result in
                continuation.resume(returning: result)
            }
        })
    }

    @available(iOS 13.0.0, *)
    func oauthAuthorize(token: String) async -> GigyaLoginResult<T> {
        return await withCheckedContinuation() { continuation in
            var model = ApiRequestModel(method: "oauth.authorize", params: ["response_type": "code"])
            model.headers = ["Authorization": "Bearer \(token)"]
            businessApiService.apiService.send(model: model, responseType: GigyaDictionary.self) { [weak self] result in
                switch result {
                case .success(data: let data):
                    print(data)
                    self?.businessApiService.send(dataType: GigyaDictionary.self, api: "oauth.token", params: ["grant_type": "authorization_code", "code": data["code"]?.value as! String]) { result in
                        
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
}
