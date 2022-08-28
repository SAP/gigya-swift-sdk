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
    let persistenceService: PersistenceService
    
    init(businessApiService: BusinessApiServiceProtocol, webAuthnDeviceIntegration: WebAuthnDeviceIntegration, oauthService: OauthService, attestationUtils: WebAuthnAttestationUtils, persistenceService: PersistenceService) {
        self.businessApiService = businessApiService
        self.webAuthnDeviceIntegration = webAuthnDeviceIntegration
        self.oauthService = oauthService
        self.attestationUtils = attestationUtils
        self.persistenceService = persistenceService
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
                    case .securityRegister(let token):
                        let attestation: [String: Any] = self.attestationUtils.makeRegisterData(object: token)
                        
                        Task {
                            let result = await self.registerCredentials(params: ["attestation": attestation, "token": options.token])
                            switch result {
                            case .success(data: let data):
                                self.oauthService.connect(token: data["idToken"]!.value as! String) { result in
                                    self.addKey(token: token.credentialID.base64EncodedString(), user: options.options.user, type: .crossPlatform)
                                    
                                    continuation.resume(returning: result)
                                } // TODO: idToken - save for delete device?
                            case .failure(let error):
                                continuation.resume(returning: GigyaApiResult.failure(error))
                            }
                        }
                    case .register(let token):

                        let attestation: [String: Any] = self.attestationUtils.makeRegisterData(object: token)
                        
                        Task {
                            let result = await self.registerCredentials(params: ["attestation": attestation, "token": options.token])
                            switch result {
                            case .success(data: let data):
                                self.oauthService.connect(token: data["idToken"]!.value as! String) { result in
                                    self.addKey(token: token.credentialID.base64EncodedString(), user: options.options.user, type: .platform)

                                    continuation.resume(returning: result)
                                } // TODO: idToken - save for delete device?
                            case .failure(let error):
                                continuation.resume(returning: GigyaApiResult.failure(error))
                            }
                        }
                    case .canceled:
                        continuation
                            .resume(returning: .failure(NetworkError.providerError(data: "cancelled")))
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
    private func initRegistration() async -> GigyaApiResult<WebAuthnInitRegisterResponseModel> {
        return await withCheckedContinuation() { continuation in
            businessApiService.send(dataType: WebAuthnInitRegisterResponseModel.self, api: GigyaDefinitions.WenAuthn.initRegister, params: [:]) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    @available(iOS 15.0.0, *)
    private func registerCredentials(params: [String: Any]) async -> GigyaApiResult<GigyaDictionary> {
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
            return await withCheckedContinuation() { continuationA in
                var continuation = Optional(continuationA)
                
                let allowedKeys = persistenceService.webAuthnlist
                
                webAuthnDeviceIntegration.login(viewController: viewController, options: options, allowedKeys: allowedKeys) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    switch result {
                    case .login(let token):
                        let attestation: [String: Any] = self.attestationUtils.makeLoginData(object: token)
                        
                        Task {
                            var continuation = Optional(continuationA)
                            let result =  await self.verifyAssertion(params: ["authenticatorAssertion": attestation, "token": options.token])
                            switch result {
                            case .success(data: let data):
                                let user: GigyaLoginResult<T> = await self.oauthService.authorize(token: data["idToken"]!.value as! String) // idToken for login
                                continuation?.resume(returning: user)
                                continuation = nil
                            case .failure(let error):
                                continuation?.resume(returning: .failure(LoginApiError(error: error)))
                                continuation = nil
                            }
                        }
                    case .securityLogin(let token):
                        let attestation: [String: Any] = self.attestationUtils.makeSecurityLoginData(object: token)
                        
                        Task {
                            var continuation = Optional(continuationA)
                            let result =  await self.verifyAssertion(params: ["authenticatorAssertion": attestation, "token": options.token])
                            switch result {
                            case .success(data: let data):
                                let user: GigyaLoginResult<T> = await self.oauthService.authorize(token: data["idToken"]!.value as! String) // idToken for login
                                continuation?.resume(returning: user)
                                continuation = nil
                            case .failure(let error):
                                continuation?.resume(returning: .failure(LoginApiError(error: error)))
                                continuation = nil
                            }
                        }
                    case .canceled:
                        continuation?
                            .resume(returning: .failure(LoginApiError(error: NetworkError.providerError(data: "cancelled"))))
                        continuation = nil
                    default:
                        let error = GigyaResponseModel(statusCode: .unknown, errorCode: 400301, callId: "", errorMessage: "Operation failed", sessionInfo: nil)
                        continuation?
                            .resume(returning: .failure(LoginApiError(error: NetworkError.gigyaError(data: error))))
                        continuation = nil
                    }
                }
            }
        case .failure(let error):
            return .failure(LoginApiError(error: error))
        }
    }
    
    @available(iOS 15.0.0, *)
    private func getAssertionOptions() async -> GigyaApiResult<WebAuthnGetOptionsResponseModel> {
        return await withCheckedContinuation({
            continuation in
            businessApiService.send(dataType: WebAuthnGetOptionsResponseModel.self, api: GigyaDefinitions.WenAuthn.getAssertionOptions, params: [:]) { result in
                continuation.resume(returning: result)
            }
        })
    }
    
    @available(iOS 15.0.0, *)
    private func verifyAssertion(params: [String: Any]) async -> GigyaApiResult<GigyaDictionary> {
        return await withCheckedContinuation({
            continuation in
            businessApiService.send(dataType: GigyaDictionary.self, api: GigyaDefinitions.WenAuthn.verifyAssertion, params: params) { result in
                continuation.resume(returning: result)
            }
        })
    }
    
    @available(iOS 13.0.0, *)
    private func revoke(key: String) async -> GigyaApiResult<GigyaDictionary> {
        return await withCheckedContinuation({
            continuation in
            businessApiService.send(dataType: GigyaDictionary.self, api: GigyaDefinitions.WenAuthn.removeCredential, params: ["credentialId": key]) { result in
                continuation.resume(returning: result)
            }
        })
    }
    
    @available(iOS 13.0.0, *)
    @discardableResult
    public func revoke() async -> GigyaApiResult<GigyaDictionary> {
        if let lastKey = self.persistenceService.webAuthnlist.last {
            let result = await self.revoke(key: lastKey.key)
            switch result {
            case .success(data: _):
                self.persistenceService.removeAllWebAuthnKeys()
            case .failure(_):
                break
            }
            return result
        } else {
            let error = GigyaResponseModel(statusCode: .unknown, errorCode: 400301, callId: "", errorMessage: "Operation failed", sessionInfo: nil)

            return GigyaApiResult.failure(.gigyaError(data: error))
        }
    }
    
    @available(iOS 13.0, *)
    private func addKey(token: String, user: WebAuthnUserModel, type: GigyaWebAuthnCredentialType) {
        Task {
            if let lastKey = self.persistenceService.webAuthnlist.last {
                let result = await self.revoke(key: lastKey.key)
                switch result {
                case .success(data: _):
                    self.persistenceService.removeAllWebAuthnKeys()
                case .failure(_):
                    break
                }
            }
            
            let credential = GigyaWebAuthnCredential(name: user.name, displayName: user.displayName, type: type, key: token)
            self.persistenceService.addWebAuthnKey(model: credential)
        }
    }
}
