//
//  SocialLoginViewModel.swift
//  GigyaUITestsApp
//
//  Created by Shmuel, Sagi on 04/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import SwiftUI
import Gigya

class SocialLoginViewModel: ObservableObject {
    @Published var message = ""

    func loginWith(_ provider: String) {
        guard let providerA = GigyaSocialProviders(rawValue: provider) else {
            return
        }
        
        Gigya.sharedInstance().login(with: providerA, viewController: UIApplication.shared.windows.first!.rootViewController!) { (result) in
            switch result {
                case .success(let data):
                break
                case .failure(_):
                    break
            }
        }


    }
}
