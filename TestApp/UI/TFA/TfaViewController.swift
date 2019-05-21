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

public enum TFAMode: String {
    case registration = "registration"
    case verification = "verification"
}

// Cell submission delegate protocol.
protocol SubmitionProtocl {
    func onSubmitPhone(number: String, andMethod: String)
    func onSubmitAuthCode(mode: TFAMode, provider: TFAProvider, code: String)
    func onSubmitRegistered(phone: TFARegisteredPhone)
    func onSubmitRegistered(email: TFAEmail)
}

class TfaViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, SubmitionProtocl {
    
    @IBOutlet weak var providerPickerView: UIPickerView!
    @IBOutlet weak var contentTable: UITableView!
    
    var content = [String]()
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

    
    // MARK: - Providers UIPickerView Delegations
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
         return tfaProviders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tfaProviders[row].name.rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedProvider = tfaProviders[row]
        switch selectedProvider.name  {
        case .gigyaPhone, .liveLink:
            onTfaPhoneProviderSelection()
        case .totp:
            onTfaTotpProviderSelection()
        case .email:
            onTfaEmailProviderSelection()
        }
    }
    
    // MARK: - Content UITableView Delegations
    
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
            let provider = tfaProviders[providerPickerView.selectedRow(inComponent: 0)].name
            cell.provider = provider
            return cell
        } else if(content[indexPath.row] == "qrCode") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TfaQrCodeCell", for: indexPath) as! TfaQrCodeCell
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
    
    // MARK: - Provider Specific Initialization
    
    /*
     Phone TFA provider selected.
    */
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
    
    /*
     Totp TFA provider selected.
     */
    func onTfaTotpProviderSelection() {
        switch tfaMode {
        case .registration:
            reloadTableWith(content:  [""])
            registrationResolverDelegate?.startRegistrationWithTotp()
        case .verification:
            reloadTableWith(content: ["authCode"])
        }
    }
    
    /*
     Email TFA provider selected.
     */
    func onTfaEmailProviderSelection() {
        switch tfaMode {
        case .verification:
            verificationResolverDelegate?.startVerificationWithEmail()
        default:
            break
        }
    }
    
    // MARK: - Submittion Protocol Implementation
    
    func onSubmitRegistered(email: TFAEmail) {
        verificationResolverDelegate?.sendEmailVerificationCode(registeredEmail: email)
    }
    
    func onSubmitRegistered(phone: TFARegisteredPhone) {
        verificationResolverDelegate?.sendPhoneVerificationCode(registeredPhone: phone)
    }
    
    func onSubmitPhone(number: String, andMethod: String) {
        registrationResolverDelegate?.startRegistrationWithPhone(phoneNumber: number, method: andMethod)
        reloadTableWith(content:  ["phoneInput", "authCode"])
    }
    
    /*
     Injecting registered phone numbers.
    */
    func onRegisteredPhone(numbers: [TFARegisteredPhone]) {
        reloadTableWith(content: ["entries"])
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = contentTable.cellForRow(at: indexPath) as? TfaRegisteredEntryCell {
            cell.provider = .gigyaPhone
            cell.phones = numbers
            cell.layoutSubviews()
        }
    }
    
    /*
     Injecting registered email addresses.
     */
    func onRegisteredEmail(addresses: [TFAEmail]) {
        reloadTableWith(content: ["entries"])
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = contentTable.cellForRow(at: indexPath) as? TfaRegisteredEntryCell {
            cell.provider = .email
            cell.emails = addresses
            cell.layoutSubviews()
        }
    }
    
    /*
     Injecting the QR code data.
    */
    func onQRCodeAvailable(code: String) {
        reloadTableWith(content:  ["qrCode"])
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = contentTable.cellForRow(at: indexPath) as? TfaQrCodeCell {
            cell.qrData = code
            cell.layoutSubviews()
        }
    }
    
    /*
     Submit auth code.
     */
    func onSubmitAuthCode(mode: TFAMode, provider: TFAProvider, code: String) {
         switch mode {
         case .registration:
            registrationResolverDelegate?.verifyCode(provider: provider, authenticationCode: code)
         case .verification:
            if (provider == .totp) {
                // TOTP verification flow starts. Will need to initialize TFA first with "verify" parameter for flow to continue.
                verificationResolverDelegate?.startVerificationWithTotp(authorizationCode: code)
                return
            }
            verificationResolverDelegate?.verifyCode(provider: provider, authenticationCode: code)
        }
    }
}


