//
//  ViewController.swift
//  TestApp
//
//  Created by Shmuel, Sagi on 25/02/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import Gigya
import GigyaTfa
import GigyaAuth

class ViewController: UIViewController {

    let gigya = Gigya.sharedInstance(UserHost.self)
    
    var isLoggedIn = false

    @IBOutlet weak var resultTextView: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let not = NotificationCenter.default
        not.addObserver(self, selector: #selector(gigyaSessionExpire(_:)), name: Notification.Name("didGigyaSessionExpire"), object: nil)

        not.addObserver(self, selector: #selector(gigyaSessionExpire(_:)), name: Notification.Name("didInvalidateSession"), object: nil)

    }

    override func viewDidAppear(_ animated: Bool) {
        checkLoginState()
    }

    @objc func gigyaSessionExpire(_ notification: Notification) {
        checkLoginState()

        UIFactory.showAlert(vc: self, msg: "Session is expire!")
    }


    @IBAction func changeSetttings(_ sender: Any) {
        let alert = UIFactory.getChangeSettingAlert(dc: gigya.config.apiDomain, api: gigya.config.apiKey!) { [weak self] dc, api in
            UserDefaults.standard.removeObject(forKey: "com.gigya.GigyaSDK:ucid")
            UserDefaults.standard.removeObject(forKey: "com.gigya.GigyaSDK:gmid")

            self?.gigya.initFor(apiKey: api!, apiDomain: dc!)

            UIFactory.showAlert(vc: self, msg: "your new dc: \(dc!), api: \(api!)")
        }
        self.present(alert, animated: true, completion: nil)

    }

    @IBAction func showScreenSet(_ sender: Any) {
        

//        let container = Gigya.getContainer()
//        let sessionService = container.resolve(SessionServiceProtocol.self)
//        let session = sessionService?.session=

//        let parameters: [String : Any] =
//                        ["lang": "ru",
//                         "regSource": "MOBILE_APP",
//                         "startScreen": "gigya-view-profile-screen"]


        //Default-ProfileUpdate


        var currentScreen: String = ""
        gigya.showScreenSet(with: "Default-RegistrationLogin", viewController: self) { [weak self] (result) in
            switch result {
            case .onLogin(let account):
                self?.resultTextView!.text = account.toJson()
            case .onAfterScreenLoad(let event):
                currentScreen = event["currentScreen"] as? String ?? ""
            case .error(let event):
                print(event)
            case .onHide(let event):
                print(event)
            case .onLogout:
                break
            default:
                break
            }
        }
    }

    @IBAction func login(_ sender: Any) {
        let alert = UIFactory.getLoginAlert { email, password in
            self.gigya.login(loginId: email!, password: password!, params: ["sessionExpiration": "10000"]) { [weak self] result in
                switch result {
                case .success(let data):
                    self?.resultTextView?.text = data.toJson()
                case .failure(let error):
                    
                    switch error.error {
                    case .gigyaError(let data):
                        let errorData = data.toDictionary()
                    default:
                        break
                    }


                    guard let interruption = error.interruption else { return }
                    // Evaluage interruption.
                    switch interruption {
                    case .conflitingAccount(let resolver):
                        resolver.linkToSite(loginId: resolver.conflictingAccount?.loginID ?? "", password: "123123")
                    case .pendingTwoFactorVerification(let interruption, let activeProviders, let factory):
                        self?.presentTFAController(tfaProviders: activeProviders!, mode: .verification, factoryResolver: factory)

                    case .pendingTwoFactorRegistration(let interruption, let inactiveProviders, let factory):
                        self?.presentTFAController(tfaProviders: inactiveProviders!, mode: .registration, factoryResolver: factory)
                    default:
                        break
                    }
                }
            }
        }

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func register(_ sender: Any) {
        let alert = UIFactory.getRegistrationAlert { email, password, expiration in
            let params = ["sessionExpiration": expiration!] as [String : Any]
            self.gigya.register(email: email!, password: password!, params: params) { [weak self] result in
                switch result {
                case .success(let data):
                    self?.resultTextView?.text = data.toJson()
                case .failure(let error):
                    print(error) // general error

                    switch error.error {
                    case .gigyaError(let data):
                        print(data)
                    default:
                        break
                    }
                    guard let interruption = error.interruption else { return }
                    // Evaluage interruption.
                    switch interruption {
                    case .pendingRegistration(let resolver):
                        let params = ["preferences": ["Visitor": ["isConsentGranted": "true"]]]
                        resolver.setAccount(params: params)

                    case .conflitingAccount(let resolver):
                        resolver.linkToSite(loginId: resolver.conflictingAccount?.loginID ?? "", password: "123123")
                    case .pendingTwoFactorVerification(let interruption, let activeProviders, let factory):
                        self?.presentTFAController(tfaProviders: activeProviders!, mode: .verification, factoryResolver: factory)

                    case .pendingTwoFactorRegistration(let interruption, let inactiveProviders, let factory):
                        self?.presentTFAController(tfaProviders: inactiveProviders!, mode: .registration, factoryResolver: factory)
                    default:
                        break
                    }
                }
            }
        }
    
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addConnection(_ sender: Any) {
        if !checkLogin() {
            print("Need to be logged in to perform action")
            return
        }

        let alert = UIFactory.getConnectionAlert(title: "Add social connection") { [weak self] providerName in

           if let provider = GigyaSocialProviders(rawValue: providerName) {
            guard let self = self else { return }
                self.gigya.addConnection(provider: provider, viewController: self, params: [:]) { result in
                    switch result {
                    case .success(let data):
                        self.resultTextView?.text = data.toJson()
                    case .failure(_):
                        self.resultTextView?.text = "Failed operation"
                    }
                }
            }
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func removeConnection(_ sender: Any) {
        if !checkLogin() {
            print("Need to be logged in to perform action")
            return
        }
        let alert = UIFactory.getConnectionAlert(title: "Remove social connection") { [weak self] providerName in
            self?.gigya.removeConnection(provider: GigyaSocialProviders(rawValue: providerName) ?? .google) { result in
                switch result {
                case .success(_):
                    self?.resultTextView?.text = "Connection removed"
                case .failure(_):
                    self?.resultTextView?.text = "Failed operation"
                }
            }
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkLogin() -> Bool {
        return gigya.isLoggedIn()
    }
    
    func checkLoginState() {
        if gigya.biometric.isOptIn {
            self.resultTextView?.text = "Session Opt-in, need to unlock"
        }

        else if gigya.biometric.isLocked {
            self.resultTextView?.text = "Session Locked"
        } else {

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
    }

    @IBAction func loginWithProvider(_ sender: Any) {
        gigya.login(with: .line, viewController: self, params: ["dataCenter": "ru1"]) { [weak self] (result) in
            switch result {
            case .success(let data):
                print(data)
                self?.resultTextView?.text = data.toJson()
            case .failure(let error):
                print(error)
                
                guard let interruption = error.interruption else { return }
                // Evaluage interruption.
                switch interruption {
                case .pendingRegistration(let resolver):
                    resolver.setAccount(params: ["profile":["zip": "121673"]])
                    break
//                    resolver.setAccount(params: ["profile": ["zip": "1234"]])
                case .pendingVerification(let resolver):
                    print("regToken: \(resolver)")
                case .conflitingAccount(let resolver):
                    resolver.linkToSite(loginId: resolver.conflictingAccount?.loginID ?? "", password: "123123")
                default:
                    break
                }
            }
        }
    }

    @IBAction func loginWithProviders(_ sender: Any) {
        gigya.socialLoginWith(providers: [.facebook, .google, .line], viewController: self, params: [:]) { [weak self] (result) in
            switch result {
            case .success(let data):
                print(data)
                self?.resultTextView?.text = data.toJson()
            case .failure(let error):
                print(error)

                guard let interruption = error.interruption else { return }
                // Evaluage interruption.
                switch interruption {
                case .pendingRegistration(let resolver):
                    resolver.setAccount(params: ["data": ["specialCode": "20"]])
                case .pendingVerification(let regToken):
                    print("regToken: \(regToken)")
                case .conflitingAccount(let resolver):
                    resolver.linkToSite(loginId: resolver.conflictingAccount?.loginID ?? "", password: "123123")
                default:
                    break
                }

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

    @IBAction func getAccount(_sender: Any) {
        gigya.getAccount { [weak self] res in
            switch res {
            case .success(let account):
                var account = account
                account.profile?.firstName = "test"
                account.data?["phone"] = [["pref":"","type":"Mobile","number":"(360) 555-4515"],["type":"Work","number":"(360) 545-5467"],["type":"Home","number":"(360) 514-2548"]]

                account.data?["address"] = [["street2":"test 9622121","state":"NY","street":"886365 Something Really Long Ave..","zip":"11012","city":"New York","type":"Mailing"]]
                account.data?["genderIdentity"] = "Male"
                account.data?["preferredMiddleName"] = "PreferredMid23"
                account.data?["middleName"] = "John"
                account.data?["administrativeGender"] = "F"
                account.data?["preferredLastName"] = "PreferredLst23"
                account.data?["preferredFirstName"] = "PreferredFirstName12"
                account.data?["preferredLanguage"] = "English"
                account.data?["preferredPronoun"] = "Her/She"

                self?.gigya.setAccount(with: account, completion: { (result) in
                    switch result {
                    case .success:
                        // Success
                        break
                    case .failure:
                        // Fail
                        break
                    }
                })
            case .failure:
                
                break
            }
        }
    }

    func ValidateLoginID() {
        gigya.send(dataType: ValidateLoginData.self, api: "accounts.isAvailableLoginID", params: ["loginID": "sagi.shmuel@sap.com"]) { (res) in
            switch res {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
                break
            }
        }
    }

    @IBAction func OptIn(_ sender: Any) {
        GigyaAuth.shared.registerForAuthPush { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }

//        GigyaTfa.shared.OptiInPushTfa { (result) in
//            switch result {
//            case .success:
//                break
//            case .failure(let error):
//                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//            }
//        }
    }

    func presentTFAController(tfaProviders: [TFAProviderModel], mode: TFAMode, factoryResolver: TFAResolverFactory<UserHost>) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tfaViewController = storyboard.instantiateViewController(withIdentifier: "TFAUIAlertViewController") as? TfaViewController
        tfaViewController?.tfaProviders = tfaProviders
        tfaViewController?.tfaMode = mode
        tfaViewController?.factoryResolver = factoryResolver
        self.navigationController?.pushViewController(tfaViewController!, animated: true)

    }

    @IBAction func OptiInBiometric(_ sender: Any) {
        gigya.biometric.optIn { (result) in
            switch result {
            case .success:
                // success
                UIFactory.showAlert(vc: self, msg: "Opt-in success")
            case .failure:
                //error
                UIFactory.showAlert(vc: self, msg: "error in opt in")
            }
        }
    }

    @IBAction func OptOutBiometric(_ sender: Any) {
        gigya.biometric.optOut { (result) in
            switch result {
            case .success:
                // soccess
                UIFactory.showAlert(vc: self, msg: "Opt-out success")
            case .failure:
                //error
                UIFactory.showAlert(vc: self, msg: "error in opt out")
            }
        }
    }

    @IBAction func UnlockSessionBiometric(_ sender: Any) {
        gigya.biometric.unlockSession { [weak self] (result) in
            switch result {
            case .success:
                // soccess
                self?.gigya.getAccount() { [weak self] result in
                    switch result {
                    case .success(let data):
                        self?.resultTextView?.text = data.toJson()
                        UIFactory.showAlert(vc: self, msg: "unlock success")
                    case .failure(let error):
                        UIFactory.showAlert(vc: self, msg: error.localizedDescription)
                    }
                }
            case .failure:
                //error
                UIFactory.showAlert(vc: self, msg: "error")
            }
        }
    }
    
    @IBAction func LockSessionBiometric(_ sender: Any) {
        gigya.biometric.lockSession { [weak self] (result) in
            switch result {
            case .success:
                self?.resultTextView?.text = "Session Locked"
                UIFactory.showAlert(vc: self, msg: "lock success")
            case .failure:
                UIFactory.showAlert(vc: self, msg: "error in lock session")
            }
        }
    }
}
