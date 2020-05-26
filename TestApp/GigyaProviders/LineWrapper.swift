//
//  LineWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 02/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import LineSDK
import Gigya

class LineWrapper: ProviderWrapperProtocol {
    var clientID: String?

    private lazy var lineLogin: LoginManager = LoginManager.shared

    required init() { }

    func login(params: [String: Any]? = nil, viewController: UIViewController? = nil,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void) {
        lineLogin.login(permissions: [.profile], in: viewController) { result in
            switch result {
            case .success(let loginResult):
                let jsonData = ["accessToken": loginResult.accessToken.value, "uid" : loginResult.userProfile?.userID ?? ""]

                completion(jsonData, nil)
            case .failure(let error):
                completion(nil, error.localizedDescription)
            }
        }
    }
}

