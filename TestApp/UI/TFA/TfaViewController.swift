//
//  TFAUIAlertViewController.swift
//  TestApp
//
//  Created by Tal Mirmelshtein on 16/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import UIKit
import Gigya
import GigyaTfa

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

    lazy var registeredEmailsResolver = {
        return factoryResolver?.getResolver(for: RegisteredEmailsResolver.self)
    }()

    lazy var registerPhoneResolver = {
        return factoryResolver?.getResolver(for: RegisterPhoneResolver.self)
    }()

    lazy var registeredPhonesResolver = {
        return factoryResolver?.getResolver(for: RegisteredPhonesResolver.self)
    }()

    lazy var registerTotpsResolver = {
        return factoryResolver?.getResolver(for: RegisterTotpResolver.self)
    }()

    var verifyCodeResolver: VerifyCodeResolverProtocol?

    var verifyTotpResolver: VerifyTotpResolverProtocol?

    var factoryResolver: TFAResolverFactory<UserHost>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentTable.delegate = self
        contentTable.dataSource = self

        contentTable.rowHeight = UITableView.automaticDimension
        contentTable.estimatedRowHeight = UITableView.automaticDimension
        
        self.providerPickerView.delegate = self
        self.providerPickerView.dataSource = self

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)

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
        case .phone:
            onTfaPhoneProviderSelection()
        case .liveLink:
            onTfaLivelinkProviderSelection()
        case .totp:
            onTfaTotpProviderSelection()
        case .email:
            onTfaEmailProviderSelection()
        case .push:
            break
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
            registeredPhonesResolver?.getRegisteredPhones(completion: registeredPhonesResult(result:))
            break
        }
    }

    /*
     LiveLink TFA provider selected.
     */
    func onTfaLivelinkProviderSelection() {
        switch tfaMode {
        case .registration:
            registerPhoneResolver?.provider(.liveLink)
            reloadTableWith(content:  ["phoneInput"])
            break
        case .verification:
            registeredPhonesResolver?.provider(.liveLink)
            registeredPhonesResolver?.getRegisteredPhones(completion: registeredPhonesResult(result:))
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
            registerTotpsResolver?.registerTotp(completion: registerTotpResult(result:))
        case .verification:
            reloadTableWith(content: ["authCode"])
            verifyTotpResolver = factoryResolver?.getResolver(for: VerifyTotpResolver.self)
        }
    }
    
    /*
     Email TFA provider selected.
     */
    func onTfaEmailProviderSelection() {
        switch tfaMode {
        case .verification:
            registeredEmailsResolver = factoryResolver?.getResolver(for: RegisteredEmailsResolver.self)
            registeredEmailsResolver?.getRegisteredEmails(completion: registeredEmailsResult(result:))
        default:
            break
        }
    }
    
    // MARK: - Submittion Protocol Implementation
    
    func onSubmitRegistered(email: TFAEmail) {
        registeredEmailsResolver?.sendEmailCode(with: email, completion: registeredEmailsResult(result:))
    }
    
    func onSubmitRegistered(phone: TFARegisteredPhone) {
        registeredPhonesResolver?.sendVerificationCode(with: phone, method: .sms, completion: registeredPhonesResult(result:))
    }
    
    func onSubmitPhone(number: String, andMethod: String) {
        registerPhoneResolver?.registerPhone(phone: number, completion: registerPhoneResult(result:))

        reloadTableWith(content:  ["phoneInput", "authCode"])
    }

    // MARK: - Resolvers Closures
    func registeredEmailsResult(result: RegisteredEmailsResult) {
        switch result {
        case .registeredEmails(let emails):
            onRegisteredEmail(addresses: emails)
        case .emailVerificationCodeSent(let resolver):
            verifyCodeResolver = resolver
            break
        case .error(_):
            break

        }
    }

    func registerPhoneResult(result: RegisterPhonesResult) {
        switch result {
        case .verificationCodeSent(let resolver):
            verifyCodeResolver = resolver
        case .error(_):
            break
        }
    }

    func registeredPhonesResult(result: RegisteredPhonesResult) {
        switch result {
        case .registeredPhones(let phones):
            onRegisteredPhone(numbers: phones)
        case .verificationCodeSent(let resolver):
            verifyCodeResolver = resolver
        case .error(_):
            break

        }
    }

    func registerTotpResult(result: RegisterTotpResult) {
        switch result {
        case .QRCodeAvilabe(let image, let resolver):
            onQRCodeAvailable(qrImage: image)
            verifyTotpResolver = resolver
        case .error(_):
            break
        }
    }
    
    /*
     Injecting registered phone numbers.
    */
    func onRegisteredPhone(numbers: [TFARegisteredPhone]) {
        reloadTableWith(content: ["entries"])
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = contentTable.cellForRow(at: indexPath) as? TfaRegisteredEntryCell {
            cell.provider = .phone
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
    func onQRCodeAvailable(qrImage: UIImage?) {
        reloadTableWith(content:  ["qrCode"])
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = contentTable.cellForRow(at: indexPath) as? TfaQrCodeCell {
            cell.qrImage.image = qrImage
            cell.layoutSubviews()
        }
    }
    
    /*
     Submit auth code.
     */
    func onSubmitAuthCode(mode: TFAMode, provider: TFAProvider, code: String) {
        if (provider == .totp) {
            // TOTP verification flow starts. Will need to initialize TFA first with "verify" parameter for flow to continue.
            //                verificationResolverDelegate?.verificationWithTotp(authorizationCode: code)
            sendVerificationTotp(code: code)
            return
        }

        sendVerifyCode(mode: mode, provider: provider, code: code)

    }

    func sendVerifyCode(mode: TFAMode, provider: TFAProvider, code: String) {
        verifyCodeResolver?.verifyCode(provider: provider, verificationCode: code, rememberDevice: false, completion: { [weak self] (result) in
            guard let self = self else { return }

            switch result {
            case .resolved:
                print("Email verification sucess")

                self.navigationController?.popViewController(animated: true)
            case .invalidCode:
                let alertController = UIAlertController(title: "Error", message: "Invalid code", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                self.present(alertController, animated: true, completion: nil)

            case .failed(let error):
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                self.present(alertController, animated: true, completion: nil)
            }
        })
    }

    func sendVerificationTotp(code: String) {
        verifyTotpResolver?.verifyTOTPCode(verificationCode: code, rememberDevice: false, completion: { (result) in
            switch result {
            case .resolved:
                print("Email verification sucess")

                self.navigationController?.popViewController(animated: true)

            case .invalidCode:
                let alertController = UIAlertController(title: "Error", message: "Invalid code", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                self.present(alertController, animated: true, completion: nil)

            case .failed(let error):
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                self.present(alertController, animated: true, completion: nil)


            }
        })
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}


