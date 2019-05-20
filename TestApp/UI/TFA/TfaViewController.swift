//
//  TFAUIAlertViewController.swift
//  TestApp
//
//  Created by Tal Mirmelshtein on 16/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import UIKit
import GigyaSwift

public enum TFAMode {
    
    case registration
    case verification
}

protocol SubmitionProtocl {
    func onSubmittedPhoneNumber(phoneNumber: String, method: String)
    func onSubmittedAuthCode(mode: TFAMode, provider: TFAProvider, code: String)
    func onSubmittedRegistered(phone: TFARegisteredPhone)
    func onSubmittedRegistered(email: TFAEmail)
}


class TfaViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, SubmitionProtocl {
    
    @IBOutlet weak var providerPickerView: UIPickerView!
    @IBOutlet weak var contentTable: UITableView!
    
    var content = [String]()
    
    var qrData = ""
    
    var tfaProviders = [TFAProviderModel]()
    
    var tfaMode: TFAMode = .registration
    
    var registrationResolverDelegate: TFARegistrationResolverProtocol?
    var verificationResolverDelegate: TFAVerificationResolverProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentTable.delegate = self
        contentTable.dataSource = self
        
        contentTable.rowHeight = UITableView.automaticDimension
        contentTable.estimatedRowHeight = UITableView.automaticDimension
        
        self.providerPickerView.delegate = self
        self.providerPickerView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.providerPickerView.delegate?.pickerView?(self.providerPickerView, didSelectRow: 0, inComponent: 0)
        }
    }

    
    // MARK: - Providers UIPickerView delegations.
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return tfaProviders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tfaProviders[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedProvider = tfaProviders[row]
        switch selectedProvider.name  {
        case "gigyaPhone", "liveLink":
            onTfaPhoneProviderSelection()
        case "gigyaTotp":
            onTfaTotpProviderSelection()
        case "gigyaEmail":
            onTfaEmailProviderSelection()
            break
        default:
            break
        }
    }
    
    // MARK: - Content UITableView delegations.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (content[indexPath.row] == "phoneInput") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TfaPhoneInputCell", for: indexPath) as! TfaPhoneInputCell
            cell.delegate = self
            return cell
        } else if (content[indexPath.row] == "authCode") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TfaAuthCodeCell", for: indexPath) as! TfaAuthCodeCell
            cell.delegate = self
            cell.mode = self.tfaMode
            let provider = TFAProvider.byName(name: tfaProviders[providerPickerView.selectedRow(inComponent: 0)].name ?? "gigyaPhone")
            cell.provider = provider!
            return cell
        } else if(content[indexPath.row] == "qrCode") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TfaQrCodeCell", for: indexPath) as! TfaQrCodeCell
            cell.qrData = self.qrData
            cell.delegate = self
            return cell
        } else if (content[indexPath.row] == "entries") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TfaRegisteredEntryCell", for: indexPath) as! TfaRegisteredEntryCell
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    func reloadTableWith(content: [String]){
        self.content = content
        contentTable.reloadData()
    }
    
    // MARK: - Logic.
    
    func onTfaPhoneProviderSelection() {
        switch tfaMode {
        case .registration:
            reloadTableWith(content:  ["phoneInput"])
            break
        case .verification:
            verificationResolverDelegate?.startVerificationWithPhone()
            break
        }
    }
    
    func onTfaTotpProviderSelection() {
        switch tfaMode {
        case .registration:
            reloadTableWith(content:  [""])
            registrationResolverDelegate?.startRegistrationWithTotp()
            break
        case .verification:
            reloadTableWith(content: ["authCode"])
            break
        }
    }
    
    func onTfaEmailProviderSelection() {
        switch tfaMode {
        case .verification:
            verificationResolverDelegate?.startVerificationWithEmail()
        default:
            break
        }
    }
    
    func onSubmittedRegistered(email: TFAEmail) {
        verificationResolverDelegate?.sendEmailVerificationCode(registeredEmail: email)
    }
    
    func onSubmittedRegistered(phone: TFARegisteredPhone) {
        verificationResolverDelegate?.sendPhoneVerificationCode(registeredPhone: phone)
    }
    
    func onSubmittedPhoneNumber(phoneNumber: String, method: String) {
        registrationResolverDelegate?.startRegistrationWithPhone(phoneNumber: phoneNumber, method: method)
        reloadTableWith(content:  ["phoneInput", "authCode"])
    }
    
    func onRegisteredPhoneNumbers(numbers: [TFARegisteredPhone]) {
        reloadTableWith(content: ["entries"])
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = contentTable.cellForRow(at: indexPath) as? TfaRegisteredEntryCell {
            cell.provider = .gigyaPhone
            cell.phones = numbers
            cell.reload()
        }
    }
    
    func onQRCodeAvailable(code: String) {
        qrData = code
        reloadTableWith(content:  ["qrCode"])
    }
    
    func onSubmittedAuthCode(mode: TFAMode, provider: TFAProvider, code: String) {
         switch mode {
         case .registration:
            registrationResolverDelegate?.verifyCode(provider: provider, authenticationCode: code)
         case .verification:
            if (provider == .totp) {
                verificationResolverDelegate?.startVerificationWithTotp(authorizationCode: code)
                return
            }
            verificationResolverDelegate?.verifyCode(provider: provider, authenticationCode: code)
        }
    }
}


