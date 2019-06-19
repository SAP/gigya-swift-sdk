//
//  GoogleWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 15/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GoogleSignIn
import Gigya

class GoogleWrapper: NSObject, ProviderWrapperProtocol {

    var clientID: String? = {
        return Bundle.main.infoDictionary?["GoogleClientID"] as? String
    }()

    var googleServerClientID: String? {
        return Bundle.main.infoDictionary?["GoogleServerClientID"] as? String
    }

    let defaultScopes = ["https://www.googleapis.com/auth/plus.login", "email"]

    lazy var googleLogin: GIDSignIn = {
        return GIDSignIn.sharedInstance()
    }()

    private var completionHandler: (_ jsonData: [String: Any]?, _ error: String?) -> Void = { _, _  in }

    required override init() {
        super.init()

        googleLogin.clientID = clientID
        googleLogin.serverClientID = googleServerClientID
        googleLogin.scopes = defaultScopes
        googleLogin.uiDelegate = self
        googleLogin.delegate = self
    }

    func login(params: [String: Any]? = nil, viewController: UIViewController? = nil,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void) {
        completionHandler = completion

        googleLogin.signIn()
    }

    func logout() {
        googleLogin.signOut()
    }
}

extension GoogleWrapper: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            completionHandler(nil, error.localizedDescription)
            return
        }
        let jsonData = ["accessToken": user.serverAuthCode ?? ""]
        completionHandler(jsonData, nil)
    }

    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {

    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        viewController.present(viewController, animated: true, completion: nil)
    }

    // Dismiss the "Sign in with Google" view
    func sign(_: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
