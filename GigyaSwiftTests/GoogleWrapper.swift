//
//  GoogleWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 15/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import Gigya

class GoogleWrapper: NSObject, ProviderWrapperProtocol {

    var clientID: String? = {
        return Bundle.main.infoDictionary?["GoogleClientID"] as? String
    }()

    var googleServerClientID: String? {
        return Bundle.main.infoDictionary?["GoogleServerClientID"] as? String
    }

    let defaultScopes = ["https://www.googleapis.com/auth/plus.login", "email"]


    private var completionHandler: (_ jsonData: [String: Any]?, _ error: String?) -> Void = { _, _  in }

    required override init() {
        super.init()

    }

    func login(params: [String: Any]? = nil, viewController: UIViewController? = nil,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void) {
        completionHandler = completion

        completionHandler(nil, nil)
    }

    func logout() {
    }
}

