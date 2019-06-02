//
//  GigyaApi.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 05/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSDK

// Alias to GSSession from objc sdk
typealias GigyaSession = GigyaSessionA

@objc class GigyaSessionA: NSObject, NSCoding {
    var token: String = ""

    var secret: String = ""

    var lastLoginProvider = ""

    init?(sessionToken token: String, secret: String) {
        self.token = token
        self.secret = secret
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: "authToken")
        aCoder.encode(self.secret, forKey: "secret")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init()

        guard let token = aDecoder.decodeObject(forKey: "authToken") as? String,
            let secret = aDecoder.decodeObject(forKey: "secret") as? String else { return }

        self.token = token
        self.secret = secret
    }

    func isValid() -> Bool {
        return !token.isEmpty && !secret.isEmpty
    }

    
}

protocol GigyaApiProtocol {
    var gigyaApi: GigyaWrapper { get }
}

/**
* GigyaWrapper
* it's a wrapper to Objective C Sdk
* TODO: need to make it with swift step by step
**/

protocol IOCGigyaWrapperProtocol: class {

    func initGigyaSDK(apiKey: String, apiDomain: String?, application: UIApplication?, launchOptions: [AnyHashable: Any]?)

    func isValidSession() -> Bool

    func getSession(_ result: @escaping (GigyaSession?) -> Void)

    func setSession(_ session: GigyaSession)

    func logout()

    func send<T>(model: ApiRequestModel, responseType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void) where T: Codable

}

class GigyaWrapper: IOCGigyaWrapperProtocol {

    // init objc sdk
    func initGigyaSDK(apiKey: String, apiDomain: String? = nil, application: UIApplication? = nil, launchOptions: [AnyHashable: Any]? = nil) {
        Gigya.initWithAPIKey(apiKey, application: application, launchOptions: launchOptions, apiDomain: apiDomain)

        // TODO: need to move
        GSLogger.sharedInstance()?.enabled = true
    }

    // MARK: - Session manager
    func isValidSession() -> Bool {
        return Gigya.isSessionValid()
    }

    func getSession(_ result: @escaping (GigyaSession?) -> Void) {
        Gigya.getSessionWithCompletionHandler { session in
//            return result(session)
        }
    }

    func setSession(_ session: GigyaSession) {
//        Gigya.setSession(session)
    }

    func logout() {
        Gigya.logout { (res, error) in

        }
    }

    func send<T>(model: ApiRequestModel, responseType: T.Type, completion: @escaping (GigyaApiResult<T>) -> Void) where T: Codable {
    }
}
