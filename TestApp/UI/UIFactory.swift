//
//  UiFactory.swift
//  TestApp
//
//  Created by Tal Mirmelshtein on 16/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import UIKit

class UIFactory {
    
    static func getLoginAlert(onSubmit: @escaping (_ email: String?, _ password: String?) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Login with registered user", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
            textField.accessibilityIdentifier = "Email"
            textField.placeholder = "Email"
        }
        alert.addTextField { (textField) in
            textField.text = ""
            textField.accessibilityIdentifier = "Password"
            textField.placeholder = "Password"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            let emailTextField = alert?.textFields![0]
            let passwordTextField = alert?.textFields![1]
            
            onSubmit(emailTextField?.text, passwordTextField?.text)
        }))
        
        return alert
    }
    
    
    static func getRegistrationAlert(onSubmit: @escaping (_ email: String?, _ password: String?, _ expiration: Int?) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Register a new user", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
            textField.accessibilityIdentifier = "Email"
            textField.placeholder = "Email"
        }
        alert.addTextField { (textField) in
            textField.text = ""
            textField.accessibilityIdentifier = "Password"
            textField.placeholder = "Password"
        }
        alert.addTextField { (textField) in
            textField.text = ""
            textField.accessibilityIdentifier = "Expiration"
            textField.placeholder = "Expiration"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
            let emailTextField = alert?.textFields![0]
            let passwordTextField = alert?.textFields![1]
            let expirationTextField = alert?.textFields![2]
            
            onSubmit(emailTextField?.text, passwordTextField?.text, Int(expirationTextField?.text ?? "0"))
        }))
        
        return alert
    }
    
    static func getConnectionAlert(title: String, onAdd: @escaping (_ name: String) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = ""
            textField.accessibilityIdentifier = "Provider"
            textField.placeholder = "Provider name"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { [weak alert] (_) in
            alert?.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            guard let providerName = textField?.text else { return }
            
            onAdd(providerName)
        }))
        
        return alert
    }

    static func showAlert(vc: UIViewController?, msg: String) {
        let alertController = UIAlertController(title: "Gigya", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        vc?.present(alertController, animated: true, completion: nil)
    }
}
