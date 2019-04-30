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

    private var completionHandler: (String?, Error?) -> Void = { _, _  in }

    var clientID: String?

    private let defaultReadPermissions = ["email"]

    lazy var fbLogin: FBSDKLoginManager = {
        return FBSDKLoginManager()
    }()

    override init() {
        super.init()
    }

    func login(params: [String: Any]?, viewController: UIViewController?, completion: @escaping (String?, Error?) -> Void) {
        completionHandler = completion

        if let loginBehavior = params?["facebookLoginBehavior"] as? FBSDKLoginBehavior {
            fbLogin.loginBehavior = loginBehavior
        }

        fbLogin.logIn(withReadPermissions: defaultReadPermissions, from: viewController) { (result, error) in
            if result?.isCancelled != false {
                let error = NSError(domain: "gigya", code: 123, userInfo: ["isCancelled": true]) as Error
                completion(nil, error)
                return
            }
            completion(result?.token.tokenString, error)
        }
    }

    func logout() {
        fbLogin.logOut()
    }
}
