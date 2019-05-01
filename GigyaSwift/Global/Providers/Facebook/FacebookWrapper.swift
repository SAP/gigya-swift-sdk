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

class FacebookWrapper: NSObject, ProviderWrapperProtocol {

    private var completionHandler: (_ token: String?, _ secret: String?, _ error: String?) -> Void = { _, _, _  in }

    var clientID: String?

    private let defaultReadPermissions = ["email"]

    lazy var fbLogin: FBSDKLoginManager = {
        return FBSDKLoginManager()
    }()

    func login(params: [String: Any]?, viewController: UIViewController?,
               completion: @escaping (_ token: String?, _ secret: String?, _ error: String?) -> Void) {
        completionHandler = completion

        if let loginBehavior = params?["facebookLoginBehavior"] as? FBSDKLoginBehavior {
            fbLogin.loginBehavior = loginBehavior
        }

        fbLogin.logIn(withReadPermissions: defaultReadPermissions, from: viewController) { (result, error) in
            if result?.isCancelled != false {
                completion(nil, nil, "sign in cancelled")
                return
            }

            if let error = error {
                completion(nil, nil, error.localizedDescription)
            }

            completion(result?.token.tokenString, nil, nil)

        }
    }

    func logout() {
        fbLogin.logOut()
    }

    deinit {
        print("[FacebookWrapper deinit]")
    }
}
