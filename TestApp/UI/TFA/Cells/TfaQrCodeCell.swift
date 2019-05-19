//
//  TfaQrCodeCell.swift
//  TestApp
//
//  Created by Tal Mirmelshtein on 19/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSwift

class TfaQrCodeCell: UITableViewCell {
    
    var qrData: String?
    
    var delegate: TFARegistrationResolverProtocol?
    
    @IBOutlet weak var qrImage: UIImageView!
    
    @IBOutlet weak var authCodeTextField: UITextField!
    
    @IBAction func authCodeSubmit(_ sender: Any) {
        guard let authCode = authCodeTextField.text else { return }
        delegate?.verifyCode(provider: .totp, authenticationCode: authCode)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let data = qrData {
            let split = data.components(separatedBy: ",")
            let dataDecoded = Data(base64Encoded: split[1], options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
            qrImage.image = UIImage(data: dataDecoded)
        }
    }
}
