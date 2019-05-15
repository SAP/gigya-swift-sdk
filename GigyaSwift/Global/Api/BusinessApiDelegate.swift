//
//  ApiServiceDelegate.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 17/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol BusinessApiDelegate: class {
    func sendApi(api: String, params: [String: String], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void )

    func sendApi<T: Codable>(dataType: T.Type, api: String, params: [String: String], completion: @escaping (GigyaApiResult<T>) -> Void)

    func callNativeSocialLogin<T: Codable>(params: [String: Any], completion: @escaping (GigyaApiResult<T>?) -> Void)

    func callGetAccount<T: Codable>(completion: @escaping (GigyaApiResult<T>) -> Void)
    
    func callSociallogin<T: Codable>(provider: GigyaSocielProviders, viewController: UIViewController,
                           params: [String: Any], dataType: T.Type, completion: @escaping (GigyaLoginResult<T>) -> Void)
    
    func callLogin<T: Codable>(dataType: T.Type, loginId: String, password: String, params: [String:Any], completion: @escaping (GigyaLoginResult<T>) -> Void)
}

extension BusinessApiService: BusinessApiDelegate {
    func sendApi<T: Codable>(dataType: T.Type, api: String, params: [String: String], completion: @escaping (GigyaApiResult<T>) -> Void) {
        self.send(dataType: dataType, api: api, params: params, completion: completion)
    }
    func sendApi(api: String, params: [String: String] = [:], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void ) {
        self.send(api: api, params: params, completion: completion)
    }

    func callNativeSocialLogin<T: Codable>(params: [String: Any], completion: @escaping (GigyaApiResult<T>?) -> Void) {
        self.nativeSocialLogin(params: params, completion: completion)
    }

    func callGetAccount<T: Codable>(completion: @escaping (GigyaApiResult<T>) -> Void) {
        self.getAccount(dataType: T.self, completion: completion)
    }   
    
    func callSociallogin<T: Codable>(provider: GigyaSocielProviders, viewController: UIViewController, params: [String : Any], dataType: T.Type, completion: @escaping (GigyaLoginResult<T>) -> Void)  {
        self.login(provider: provider, viewController: viewController, params: params, dataType: dataType, completion: completion)
    }
    
    func callLogin<T: Codable>(dataType: T.Type, loginId: String, password: String, params: [String : Any], completion: @escaping (GigyaLoginResult<T>) -> Void)  {
        self.login(dataType: dataType, loginId: loginId, password: password, params: params, completion: completion)
    }
}
