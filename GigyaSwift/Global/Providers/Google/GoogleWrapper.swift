////
////  GoogleWrapper.swift
////  GigyaSwift
////
////  Created by Shmuel, Sagi on 15/04/2019.
////  Copyright © 2019 Gigya. All rights reserved.
////
//
//import Foundation
//#if canImport(GoogleSignIn)
//import GoogleSignIn
//#endif
//
//class GoogleWrapper: NSObject, ProviderWrapperProtocol {
//
//    var clientID: String? = {
//        return Bundle.main.infoDictionary?["GoogleClientID"] as? String
//    }()
//
//    var googleServerClientID: String? {
//        return Bundle.main.infoDictionary?["GoogleServerClientID"] as? String
//    }
//
//    let defaultScopes = ["https://www.googleapis.com/auth/plus.login", "email"]
//
//    lazy var googleLogin: GIDSignIn = {
//        return GIDSignIn.sharedInstance()
//    }()
//
//    private var completionHandler: (_ token: String?, _ secret: String?, _ error: String?) -> Void = { _, _, _  in }
//
//    override init() {
//        super.init()
//        
//        googleLogin.clientID = clientID
//        googleLogin.serverClientID = googleServerClientID
//        googleLogin.scopes = defaultScopes
//        googleLogin.uiDelegate = self
//        googleLogin.delegate = self
//    }
//
//    func login(params: [String: Any]? = nil, viewController: UIViewController? = nil,
//               completion: @escaping (_ token: String?, _ secret: String?, _ error: String?) -> Void) {
//        completionHandler = completion
//
//        googleLogin.signIn()
//    }
//
//    func logout() {
//        googleLogin.signOut()
//    }
//
//    deinit {
//        print("[GoogleWrapper deinit]")
//    }
//}
//
//extension GoogleWrapper: GIDSignInDelegate, GIDSignInUIDelegate {
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        guard error == nil else {
//            completionHandler(nil, nil, error.localizedDescription)
//            return
//        }
//        completionHandler(user.serverAuthCode, nil, nil)
//    }
//
//    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
//        
//    }
//    // Present a view that prompts the user to sign in with Google
//    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
//        viewController.present(viewController, animated: true, completion: nil)
//    }
//
//    // Dismiss the "Sign in with Google" view
//    func sign(_: GIDSignIn!, dismiss viewController: UIViewController!) {
//        viewController.dismiss(animated: true, completion: nil)
//    }
//}
