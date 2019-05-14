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
    
    func toJson() -> String {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(self)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString ?? ""
        } catch {
            print(error)
        }
        return ""
    }
}

struct ValidateLoginData: Codable {
    let errorCode: Int
    let callId: String
}

class ViewController: UIViewController {

    let gigya = GigyaSwift.sharedInstance(UserHost.self)
    
    var isLoggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkLoginState()
    }
    
    @IBOutlet weak var resultTextView: UITextView?
    
    @IBAction func showScreenSet(_ sender: Any) {
        gigya.showScreenSet(name: "Default-RegistrationLogin", viewController: self) { [weak self] (result) in
            switch result {
            case .onLogin(let account):
                self?.resultTextView!.text = account.toJson()
            default:
                break
            }
        }
    }

    @IBAction func login(_ sender: Any) {
        
    }
    
    @IBAction func register(_ sender: Any) {
        
    }
    
    @IBAction func addConnection(_ sender: Any) {
        if !checkLogin() {
            print("Need to be logged in to perform action")
            return
        }
        let alert = UIAlertController(title: "Add social connection", message: "Enter provider Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
            textField.accessibilityIdentifier = "TextField"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: nil)
            }))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert, weak self] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            guard let providerName = textField?.text else { return }
            guard let self = self else { return }
            if let provider = GigyaSocielProviders.byName(name: providerName) {
                self.gigya.addConnection(provider: provider, viewController: self, params: [:]) { result in
                    switch result {
                    case .success(let data):
                        self.resultTextView?.text = data.toJson()
                        break
                    case .failure(_):
                        self.resultTextView?.text = "Failed operation"
                        break
                    }
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func removeConnection(_ sender: Any) {
        if !checkLogin() {
            print("Need to be logged in to perform action")
            return
        }
        let alert = UIAlertController(title: "Remove social connection", message: "Enter provider Name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
            textField.accessibilityIdentifier = "TextField"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Remove", style: .default, handler: { [weak alert, weak self] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            guard let providerName = textField?.text else { return }
            guard let self = self else { return }
            self.gigya.removeConnection(provider: providerName) { result in
                switch result {
                case .success(let data):
                    self.resultTextView?.text = "Connection removed"
                    break
                case .failure(_):
                    break
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkLogin() -> Bool {
        return gigya.isLoggedIn()
    }
    
    func checkLoginState() {
        isLoggedIn = gigya.isLoggedIn()
        if (isLoggedIn) {
            gigya.getAccount() { [weak self] result in
                switch result {
                case .success(let data):
                    self?.resultTextView?.text = data.toJson()
                case .failure(_):
                    break
                }
            }
        } else {
            self.resultTextView?.text = "Logged out"
        }
    }
    
    
    @IBAction func getAccount(_ sender: Any) {
        gigya.register(params: ["email": "dasdsad@testss.com", "password": "121233"]) { (result) in
            switch result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func loginWithProvider(_ sender: Any) {
        gigya.login(with: GigyaSocielProviders.google, viewController: self ) { result in
            switch result {
            case .success(let data):
                print(data)
                self.resultTextView?.text = data.toJson()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        gigya.logout() { result in
            switch result {
            case .success(let data):
                print(data)
                self.resultTextView?.text = "Logged out"
            case .failure(let error):
                print(error)
            }
        }
    }



//extension ViewController: PluginEventDelegate {
//
//    func onError(error: GigyaResponseModel) {
//
//    }
//
//    func onEvent(event: PluginEvent) {
//        switch event {
//        case .onLogin(let account):
//            print(account)
//            resultTextView?.text = (account as! UserHost).toJson()
//        default:
//            break
//        }
//    }
//}

        
//        GigyaSwift.sharedInstance().login(loginId: "sagi.shmuel@sap.com", password: "151515") { res in
//            switch res {
//            case .success(let data):
//                print(data)
//            case .failure:
//                break
//            }
   
//
//        GigyaSwift.sharedInstance().send(api: "accounts.isAvailableLoginID", params: ["loginID": "sagi.shmuel@sap.com"]) { (res) in
//            switch res {
//            case .success(let data):
//                print(data)
//            case .failure:
//                break
//            }
//        }
        

//        gigya.getAccount { [weak self] res in
//            switch res {
//            case .success(let account):
//                print(account)
//            case .failure:
//                break
//            }
//        }
    @IBAction func getAccount(_sender: Any) {
//        gigya.register(params: ["email": "dasdsad@testss.com", "password": "121233"]) { (result) in
//            switch result {
//            case .success(let data):
//                print(data)
//            case .failure(let error):
//                print(error)
//            }
//        }

        gigya.getAccount { [weak self] res in
            switch res {
            case .success(let account):
                var account = account
                account.profile?.firstName = "test"
                self?.gigya.setAccount(account: account, completion: { (rrr) in

                })
            case .failure:
                break
            }
        }
    }
}
//        GigyaSwift.sharedInstance().send(dataType: ValidateLoginData.self, api: "accounts.isAvailableLoginID", params: ["loginID": "sagi.shmuel@sap.com"]) { (res) in
//            switch res {
//            case .success(let data):
//                print(data)
//            case .failure:
//                break
//            }
//        }

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
    



