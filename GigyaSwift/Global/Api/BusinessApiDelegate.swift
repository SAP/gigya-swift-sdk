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
    
    func callNativeSocialLogin<T: Codable>(params: [String: Any], completion: @escaping (GigyaApiResult<T>?) -> Void)

    func callGetAccount<T: Codable>(completion: @escaping (GigyaApiResult<T>) -> Void)
}

extension BusinessApiService: BusinessApiDelegate {
    func sendApi(api: String, params: [String: String] = [:], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void ) {
        self.send(api: api, params: params, completion: completion)
    }

    func callNativeSocialLogin<T: Codable>(params: [String: Any], completion: @escaping (GigyaApiResult<T>?) -> Void) {
        self.nativeSocialLogin(params: params, completion: completion)
    }

    func callGetAccount<T: Codable>(completion: @escaping (GigyaApiResult<T>) -> Void) {
        self.getAccount(dataType: T.self, completion: completion)
    }
}
