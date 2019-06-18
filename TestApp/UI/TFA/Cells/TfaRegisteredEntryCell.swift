//
//  TfaRegisteredEntryCell.swift
//  TestApp
//
//  Created by Tal Mirmelshtein on 20/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSwift
import GigyaTfa

class TfaRegisteredEntryCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate: SubmitionProtocl?
    
    var phones: [TFARegisteredPhone]?
    var emails: [TFAEmail]?

    var provider: TFAProvider?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var entriesPickerView: UIPickerView!
    
    @IBOutlet weak var authCodeTextField: UITextField!
    
    @IBAction func onSendCode(_ sender: Any) {
        guard let provider = provider else { return }
        let index = entriesPickerView.selectedRow(inComponent: 0)
        if provider == .phone {
            if let phones = self.phones {
                let phone = phones[index]
                print("Sending SMS code to: \(phone.obfuscated ?? "")")
                delegate?.onSubmitRegistered(phone: phone)
            }
        } else if provider == .email {
            if let emails = self.emails {
                let email = emails[index]
                print("Sending EMAIL code to: \(email.obfuscated ?? "")")
                delegate?.onSubmitRegistered(email: email)
            }
        }
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        guard let authCode = authCodeTextField.text else { return }
        guard let provider = provider else { return }
        print("Submit auth verification code: \(authCode) for provider: \(provider.rawValue)")
        
        if provider == .phone {
            delegate?.onSubmitAuthCode(mode: .verification, provider: .phone, code: authCode)
        } else if provider == .email {
            delegate?.onSubmitAuthCode(mode: .verification, provider: .email, code: authCode)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.entriesPickerView.delegate = self
        self.entriesPickerView.dataSource = self
        
        entriesPickerView.reloadAllComponents()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let provider = provider else { return 0 }
        if provider == .phone {
            if let phones = self.phones {
                return phones.count
            }
        } else if provider == .email {
            if let emails = self.emails {
                return emails.count
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let provider = provider else { return ""}
        if provider == .phone {
            if let phones = self.phones {
                return phones[row].obfuscated
            }
        } else if provider == .email {
            if let emails = self.emails {
                return emails[row].obfuscated
            }
        }
        return ""
    }
    
}
