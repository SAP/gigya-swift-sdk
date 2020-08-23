//
//  ApiServiceDelegate.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 17/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import UIKit

public protocol BusinessApiDelegate: class {
    
    func sendApi(api: String, params: [String: Any], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void )

    func sendApi<T: Codable>(dataType: T.Type, api: String, params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void)

    func callSetAccount<T: GigyaAccountProtocol>(dataType: T.Type, params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void)

    func callNativeSocialLogin<T: GigyaAccountProtocol>(params: [String: Any], completion: @escaping (GigyaApiResult<T>?) -> Void)

    func callGetAccount<T: GigyaAccountProtocol>(completion: @escaping (GigyaApiResult<T>) -> Void)

    func callGetAccount<T: GigyaAccountProtocol>(dataType: T.Type, params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void)

    func callSociallogin<T: GigyaAccountProtocol>(provider: GigyaSocialProviders, viewController: UIViewController,
                           params: [String: Any], dataType: T.Type, completion: @escaping (GigyaLoginResult<T>) -> Void)
    
    func callLogin<T: GigyaAccountProtocol>(dataType: T.Type, loginId: String, password: String, params: [String:Any], completion: @escaping (GigyaLoginResult<T>) -> Void)
    
    func callfinalizeRegistration<T: GigyaAccountProtocol>(regToken: String, completion: @escaping (GigyaLoginResult<T>) -> Void)

    func callRegister<T: GigyaAccountProtocol>(dataType: T.Type, email: String, password: String, params: [String:Any], completion: @escaping (GigyaLoginResult<T>) -> Void)

    func callLogout(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void )

    func callForgotPassword(params: [String:Any], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void )

}

extension BusinessApiService: BusinessApiDelegate {

    func callSetAccount<T: GigyaAccountProtocol>(dataType: T.Type, params: [String : Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        self.setAccount(params: params, completion: completion)
    }
    
    func sendApi<T: Codable>(dataType: T.Type, api: String, params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        self.send(dataType: dataType, api: api, params: params, completion: completion)
    }
    func sendApi(api: String, params: [String: Any] = [:], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void ) {
        self.send(api: api, params: params, completion: completion)
    }

    func callNativeSocialLogin<T: GigyaAccountProtocol>(params: [String: Any], completion: @escaping (GigyaApiResult<T>?) -> Void) {
        self.nativeSocialLogin(params: params, completion: completion)
    }

    func callGetAccount<T: Codable>(completion: @escaping (GigyaApiResult<T>) -> Void) {
        self.getAccount(dataType: T.self, completion: completion)
    }

    func callGetAccount<T: GigyaAccountProtocol>(dataType: T.Type, params: [String : Any], completion: @escaping (GigyaApiResult<T>) -> Void) {
        self.getAccount(params: params, clearAccount: false, dataType: T.self, completion: completion)
     }
    
    func callSociallogin<T: GigyaAccountProtocol>(provider: GigyaSocialProviders, viewController: UIViewController, params: [String : Any], dataType: T.Type, completion: @escaping (GigyaLoginResult<T>) -> Void)  {
        self.login(provider: provider, viewController: viewController, params: params, dataType: dataType, completion: completion)
    }
    
    func callLogin<T: GigyaAccountProtocol>(dataType: T.Type, loginId: String, password: String, params: [String : Any], completion: @escaping (GigyaLoginResult<T>) -> Void)  {
        self.login(dataType: dataType, loginId: loginId, password: password, params: params, completion: completion)
    }
    
    func callfinalizeRegistration<T>(regToken: String, completion: @escaping (GigyaLoginResult<T>) -> Void) where T : Decodable, T : Encodable {
        self.finalizeRegistration(regToken: regToken, completion: completion)
    }

    func callRegister<T: GigyaAccountProtocol>(dataType: T.Type, email: String, password: String, params: [String:Any], completion: @escaping (GigyaLoginResult<T>) -> Void) {
        self.register(email: email, password: password, params: params, dataType: dataType, completion: completion)
    }

    func callLogout(completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void ) {
        self.logout(completion: completion)
    }

    func callForgotPassword(params: [String:Any], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {
        self.forgotPassword(params: params, completion: completion)
    }
}
