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

class TFAUIAlertViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var dataPickerView: UIPickerView!
    @IBOutlet weak var providerPickerView: UIPickerView!
    @IBOutlet weak var countryCodePickerView: UIPickerView!
    
    @IBOutlet weak var dataPickerTitleLabel: UILabel!
    
    var countryCodeData = [[String: Any]]()
    var tfaProviders = [TFAProviderModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.providerPickerView.delegate = self
        self.providerPickerView.dataSource = self
        
        self.countryCodePickerView.delegate = self
        self.countryCodePickerView.dataSource = self
        
        loadCountryCodes()
    }
    
    func loadCountryCodes() {
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
    
    // MARK: - UIPickerView delegations.
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == countryCodePickerView {
            return countryCodeData.count
        } else if pickerView == providerPickerView {
            return tfaProviders.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == countryCodePickerView {
            return countryCodeData[row]["name"] as? String
        }
        else if pickerView == providerPickerView {
            return tfaProviders[row].name
        }
        return ""
    }
    
}


