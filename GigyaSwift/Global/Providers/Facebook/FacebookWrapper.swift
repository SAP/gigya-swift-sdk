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

    private var completionHandler: (String?, String?, Error?) -> Void = { _, _, _  in }

    var clientID: String?

    private let defaultReadPermissions = ["email"]

    lazy var fbLogin: FBSDKLoginManager = {
        return FBSDKLoginManager()
    }()

    func login(params: [String: Any]?, viewController: UIViewController?, completion: @escaping (String?, String?, Error?) -> Void) {
        completionHandler = completion

        if let loginBehavior = params?["facebookLoginBehavior"] as? FBSDKLoginBehavior {
            fbLogin.loginBehavior = loginBehavior
        }

        fbLogin.logIn(withReadPermissions: defaultReadPermissions, from: viewController) { (result, error) in
            if result?.isCancelled != false {
                let error = NSError(domain: InternalConfig.General.sdkDomain, code: 200001, userInfo: ["isCancelled": true]) as Error
                completion(nil, nil, error)
                return
            }
            completion(result?.token.tokenString, nil, error)
            
        }
    }

    func logout() {
        fbLogin.logOut()
    }

    deinit {
        print("[FacebookWrapper deinit]")
    }
}
