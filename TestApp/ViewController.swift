//
//  ViewController.swift
//  TestApp
//
//  Created by Shmuel, Sagi on 25/02/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import GigyaSwift
import GigyaSDK
import GoogleSignIn

struct UserHost: GigyaAccountProtocol {
    var UID: String?

    var UIDSignature: String?

    var apiVersion: Int?

    var created: String?

    var createdTimestamp: Double?

    var isActive: Bool?

    var isRegistered: Bool?

    var isVerified: Bool?

    var lastLogin: String?

    var lastLoginTimestamp: Double?

    var lastUpdated: String?

    var lastUpdatedTimestamp: Double?

    var loginProvider: String?

    var oldestDataUpdated: String?

    var oldestDataUpdatedTimestamp: Double?

    var registered: String?

    var registeredTimestamp: Double?

    var signatureTimestamp: String?

    var socialProviders: String?

    var verified: String?

    var verifiedTimestamp: Double?

    var regToken: String?

    var profile: GigyaProfile?

    let data: [String: AnyCodable]?
}

struct ValidateLoginData: Codable {
    let errorCode: Int
    let callId: String
}

class ViewController: UIViewController {

    let gigya = GigyaSwift.sharedInstance(UserHost.self)
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let loginin = gigya.isLoggedIn()

        
    }

    @IBAction func checkValidateLogin(_ sender: Any) {
        gigya.login(with: .facebook, viewController: self) { (res) in
            switch res {
            case .success(let data):
                print(data)
            case .failure(_):
                break
            }
        }
        
//        GigyaSwift.sharedInstance().login(loginId: "sagi.shmuel@sap.com", password: "151515") { res in
//            switch res {
//            case .success(let data):
//                print(data)
//            case .failure:
//                break
//            }
        }
//
//        GigyaSwift.sharedInstance().send(api: "accounts.isAvailableLoginID", params: ["loginID": "sagi.shmuel@sap.com"]) { (res) in
//            switch res {
//            case .success(let data):
//                print(data)
//            case .failure:
//                break
//            }
//        }

    @IBAction func getAccount(_ sender: Any) {
        gigya.register(params: ["email": "dasdsad@testss.com", "password": "121233"]) { (result) in
            switch result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }

//        gigya.getAccount { [weak self] res in
//            switch res {
//            case .success(let account):
//                print(account)
//            case .failure:
//                break
//            }
//        }
//        GigyaSwift.sharedInstance().send(dataType: ValidateLoginData.self, api: "accounts.isAvailableLoginID", params: ["loginID": "sagi.shmuel@sap.com"]) { (res) in
//            switch res {
//            case .success(let data):
//                print(data)
//            case .failure:
//                break
//            }
//        }
    }
    //
//
//    @IBAction func loading(_ sender: Any) {
//        login()
//    }
//
//    func login() {
//        Gigya.showPluginDialogOver(self, plugin: "accounts.screenSet", parameters: ["screenSet": "Default-RegistrationLogin"],
//                                   completionHandler: { (wasClosed, error) in
//
//        })
//    }

//    func load() {
//
//        DispatchQueue.global().asyncAfter(deadline: .now()) {
//            let model = GigyaApiReguestModel(method: "socialize.getSDKConfig")
//
//            print("sent now")
//            aaa.send(responseType: [String: AnyCodable].self) { (res) in
//                switch res {
//                case .success(let data):
//                    let newdata = data as [String: Any]
//
//                    break
//                case .failure(_):
//                    break
//                }
//            }
//        }

//    }
}

