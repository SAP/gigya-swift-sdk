//
//  TwoFactorAuthenticationPhoneInputCell.swift
//  TestApp
//
//  Created by Tal Mirmelshtein on 19/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import Gigya

class TfaPhoneInputCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var countryCodeData = [[String: Any]]()
    
    var delegate: SubmitionProtocl?
    
    @IBOutlet weak var ccPicker: UIPickerView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        ccPicker.dataSource = self
        ccPicker.delegate = self
        
        // Load country code entries.
        if let path = Bundle.main.path(forResource: "CountryCodes", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [[String: Any]] {
                    self.countryCodeData = jsonResult
                }
            } catch {
                // Irrelevant.
            }
        }
    }
    
    @IBAction func submitClick(_ sender: Any) {
        guard let input = phoneNumberTextField.text else { return }
        let index = ccPicker.selectedRow(inComponent: 0)
        var ccCode = countryCodeData[index]["dial_code"] as! String
        ccCode.remove(at: ccCode.startIndex)
        let submition = ccCode + input
        print("Phone registration submition number: \(submition)")
        
        delegate?.onSubmitPhone(number: submition, andMethod: "sms")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryCodeData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryCodeData[row]["name"] as? String
    }
    
}
