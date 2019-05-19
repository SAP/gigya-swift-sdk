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

class TfaViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, SubmitionProtocl {
    
    @IBOutlet weak var providerPickerView: UIPickerView!
    @IBOutlet weak var contentTable: UITableView!
    
    var content = ["phoenInput"]
    
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
            cell.delegate = registrationResolverDelegate
            cell.submitionDelegate = self
            return cell
        } else if (content[indexPath.row] == "authCode") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TfaAuthCodeCell", for: indexPath) as! TfaAuthCodeCell
            cell.registrationDelegate = registrationResolverDelegate
            cell.verificationDelegate = verificationResolverDelegate
            let provider = TFAProvider.byName(name: tfaProviders[providerPickerView.selectedRow(inComponent: 0)].name ?? "gigyaPhone")
            cell.provider = provider!
            return cell
        } else if(content[indexPath.row] == "qrCode") {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TfaQrCodeCell", for: indexPath) as! TfaQrCodeCell
            cell.qrData = self.qrData
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
        reloadTableWith(content:  ["phoneInput"])
        switch tfaMode {
        case .registration:
            break
        case .verification:
            verificationResolverDelegate?.startVerificationWithPhone()
            break
        }
    }
    
    func onTfaTotpProviderSelection() {
        reloadTableWith(content:  [""])
        switch tfaMode {
        case .registration:
            registrationResolverDelegate?.startRegistrationWithTotp()
            break
        case .verification:
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
    
    func onSubmittedPhoneNumber() {
        reloadTableWith(content:  ["phoneInput", "authCode"])
    }
    
    func onQRCodeAvailable(code: String) {
        qrData = code
        reloadTableWith(content:  ["qrCode"])
    }
    
}


