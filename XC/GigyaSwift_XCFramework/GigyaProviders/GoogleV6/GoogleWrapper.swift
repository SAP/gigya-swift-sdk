//
//  GoogleWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 15/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import GoogleSignIn
import Gigya


// MARK: - Google Sign In V6 wrapper

class GoogleWrapper: ProviderWrapperProtocol {
    var clientID: String? = {
        return Bundle.main.infoDictionary?["GoogleClientID"] as? String
    }()

    var googleServerClientID: String? {
        return Bundle.main.infoDictionary?["GoogleServerClientID"] as? String
    }
    
    required init() {
    }

    func login(params: [String: Any]? = nil, viewController: UIViewController? = nil,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void) {
        guard let clientID = self.clientID, let viewController = viewController else {
            GigyaLogger.log(with: self, message: "clientID not found.")
            return
        }

        let signInConfig = GIDConfiguration.init(clientID: clientID, serverClientID: googleServerClientID)

        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: viewController) { user, error in
            guard error == nil else {
                completion(nil, error?.localizedDescription)
                return
            }

            let jsonData = ["accessToken": user?.serverAuthCode ?? ""]
            completion(jsonData, nil)

        }
    }

    func logout() {
        GIDSignIn.sharedInstance.signOut()
    }
}
