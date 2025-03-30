//
//  ProfileViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 03/03/2024.
//
import UIKit
import Foundation
import SafariServices

@Observable
final class ProfileViewModel: BaseViewModel {
    var name: String = ""
    var image: String = ""
            
    enum Screen: String {
        case login = "Default-RegistrationLogin"
        case profile = "Default-ProfileUpdate"
    }
    
    enum StartScreen: String {
        case register = "gigya-register-screen"
        case changePassword = "gigya-change-password-screen"
    }
    
    override init(gigya: GigyaService) {
        super.init(gigya: gigya)
        
        getAccount()
    }
    
    func getAccount() {
        gigya?.shared.getAccount(){ result in
            switch result {
            case .success(data: let data):
                self.name = "\(data.profile?.firstName ?? "") \(data.profile?.lastName ?? "")"
                self.image = data.profile?.photoURL ?? "logo"
            case .failure(_):
                break
            }
        }
    }
    
    func logout(closure: @escaping ()-> Void) {
        gigya?.shared.logout() { res in
         closure()
        }
    }
    
    func loginWebView(screen: Screen, startScreen: StartScreen? = nil, closure: @escaping ()-> Void) {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first
                  as? UIWindowScene)?.windows.first?.rootViewController
              else { return }
        
        var params: [String: String] = [:]
        
        if let startScreen = startScreen {
            params["startScreen"] = startScreen.rawValue
        }

        gigya?.shared.showScreenSet(with: screen.rawValue, viewController: presentingViewController, params: params) { event in
            switch event {
    
            case .onLogin(_):
                closure()
            default:
                break
            }
        }
    }
    
    func getAuthcode() async {
        let code = try! await gigya?.shared.getAuthCode()
        
        let vc = await SFSafariViewController(url: URL(string: "https://944188250303.us1.my.gigya-ext.com/pages/profile?authCode=\(code ?? "")&gig_actions=sso.login")!)
        
        guard let presentingViewController = await (UIApplication.shared.connectedScenes.first
                                              as? UIWindowScene)?.windows.first?.rootViewController
        else { return }
        
        await presentingViewController.present(vc, animated: true)
    }
}
