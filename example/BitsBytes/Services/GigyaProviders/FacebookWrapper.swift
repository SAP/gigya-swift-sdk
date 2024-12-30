//
//  FacebookWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 23/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import Gigya

// MARK: - for Gigya v1.7.0+

class FacebookWrapper: ProviderWrapperProtocol {

    private var completionHandler: (_ jsonData: [String: Any]?, _ error: String?) -> Void = { _, _  in }

    var clientID: String?

    private let defaultReadPermissions = ["email", "user_birthday", "user_gender", "user_hometown", "user_location"]

    lazy var fbLogin: LoginManager = {
        return LoginManager()
    }()

    required init() {

    }

    func login(params: [String: Any]?, viewController: UIViewController?,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void) {
        completionHandler = completion
        
        fbLogin.logIn(permissions: defaultReadPermissions, from: viewController) { (result, error) in
            if result?.isCancelled != false {
                completion(nil, "canceled")
                return
            }

            if let error = error {
                completion(nil, error.localizedDescription)
            }
            let expiration: Int = Int(result?.token?.expirationDate.timeIntervalSince1970 ?? 0)

            let jsonData: [String: Any] = ["authToken": result?.token?.tokenString ?? "", "idToken": result?.authenticationToken?.tokenString ?? "", "tokenExpiration": expiration > Int32.max ? Int32.max : expiration]

            completion(jsonData, nil)
        }
    }

    func logout() {
        fbLogin.logOut()
    }
}
