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
import GigyaSwift

class FacebookWrapper: NSObject, ProviderWrapperProtocol {

<<<<<<< HEAD:GigyaSwift/Global/Providers/Facebook/FacebookWrapper.swift
    private var completionHandler: (_ token: String?, _ secret: String?, _ error: String?) -> Void = { _, _, _  in }
=======
    private var completionHandler: (_ jsonData: [String: Any]?, _ error: String?) -> Void = { _, _  in }
>>>>>>> 85068-setAccount:TestApp/GigyaProviders/FacebookWrapper.swift

    var clientID: String?

    private let defaultReadPermissions = ["email"]

    lazy var fbLogin: FBSDKLoginManager = {
        return FBSDKLoginManager()
    }()

<<<<<<< HEAD:GigyaSwift/Global/Providers/Facebook/FacebookWrapper.swift
    func login(params: [String: Any]?, viewController: UIViewController?,
               completion: @escaping (_ token: String?, _ secret: String?, _ error: String?) -> Void) {
=======
    required override init() {
        super.init()
    }

    func login(params: [String: Any]?, viewController: UIViewController?,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void) {
>>>>>>> 85068-setAccount:TestApp/GigyaProviders/FacebookWrapper.swift
        completionHandler = completion

        if let loginBehavior = params?["facebookLoginBehavior"] as? FBSDKLoginBehavior {
            fbLogin.loginBehavior = loginBehavior
        }

        fbLogin.logIn(withReadPermissions: defaultReadPermissions, from: viewController) { (result, error) in
            if result?.isCancelled != false {
<<<<<<< HEAD:GigyaSwift/Global/Providers/Facebook/FacebookWrapper.swift
                completion(nil, nil, "sign in cancelled")
=======
                completion(nil, "sign in cancelled")
>>>>>>> 85068-setAccount:TestApp/GigyaProviders/FacebookWrapper.swift
                return
            }

            if let error = error {
<<<<<<< HEAD:GigyaSwift/Global/Providers/Facebook/FacebookWrapper.swift
                completion(nil, nil, error.localizedDescription)
            }

            completion(result?.token.tokenString, nil, nil)
=======
                completion(nil, error.localizedDescription)
            }

            let jsonData: [String: Any] = ["accessToken": result?.token.tokenString ?? "", "tokenExpiration": result?.token.expirationDate.timeIntervalSince1970 ?? 0]

            completion(jsonData, nil)
>>>>>>> 85068-setAccount:TestApp/GigyaProviders/FacebookWrapper.swift

        }
    }

    func logout() {
        fbLogin.logOut()
    }
}
