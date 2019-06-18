//
//  TwoFactorAuthenticationAuthCodeCell.swift
//  TestApp
//
//  Created by Tal Mirmelshtein on 19/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSwift
import GigyaTfa

class TfaAuthCodeCell: UITableViewCell {
    
    var delegate: SubmitionProtocl?
    
    var mode: TFAMode = .registration
    var provider: TFAProvider = .phone
    
    @IBOutlet weak var authCodeTextField: UITextField!
    
    @IBAction func authCodeSubmit(_ sender: Any) {
        guard let authCode = authCodeTextField.text else { return }
        print("Submit auth code: \(authCode) for provider: \(provider.rawValue) and mode: \(mode.rawValue)")
        
        switch mode {
        case .registration:
            delegate?.onSubmitAuthCode(mode: .registration, provider: self.provider, code: authCode)
        case .verification:
            delegate?.onSubmitAuthCode(mode: .verification, provider: self.provider, code: authCode)
        }
    }
}
