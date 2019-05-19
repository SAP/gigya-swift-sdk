//
//  TwoFactorAuthenticationAuthCodeCell.swift
//  TestApp
//
//  Created by Tal Mirmelshtein on 19/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSwift

class TfaAuthCodeCell: UITableViewCell {
    
    var registrationDelegate: TFARegistrationResolverProtocol?
    var verificationDelegate: TFAVerificationResolverProtocol?
    
    var mode: TFAMode = .registration
    var provider: TFAProvider = .gigyaPhone
    
    @IBOutlet weak var authCodeTextField: UITextField!
    
    @IBAction func authCodeSubmit(_ sender: Any) {
        guard let authCode = authCodeTextField.text else { return }
        switch mode {
        case .registration:
            registrationDelegate?.verifyCode(provider: provider, authenticationCode: authCode)
            break
        case .verification:
            verificationDelegate?.verifyCode(provider: provider, authenticationCode: authCode)
            break
        }
    }
}
