//
//  TfaRegisteredEntryCell.swift
//  TestApp
//
//  Created by Tal Mirmelshtein on 20/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSwift

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
        if provider == .gigyaPhone {
            if let phones = self.phones {
                let index = entriesPickerView.selectedRow(inComponent: 0)
                let phone = phones[index]
                delegate?.onSubmittedRegistered(phone: phone)
            }
        } else if provider == .email {
            if let emails = self.emails {
                
            }
        }
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        guard let authCode = authCodeTextField.text else { return }
        guard let provider = provider else { return }
        if provider == .gigyaPhone {
            delegate?.onSubmittedAuthCode(mode: .verification, provider: .gigyaPhone, code: authCode)
        } else if provider == .email {
            delegate?.onSubmittedAuthCode(mode: .verification, provider: .email, code: authCode)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.entriesPickerView.delegate = self
        self.entriesPickerView.dataSource = self
    }
    
    func reload() {
        entriesPickerView.reloadAllComponents()
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let provider = provider else { return 0 }
        if provider == .gigyaPhone {
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
        if provider == .gigyaPhone {
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
