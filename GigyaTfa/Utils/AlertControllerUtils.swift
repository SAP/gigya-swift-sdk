//
//  AlertControllerUtils.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 16/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class AlertControllerUtils {
    static func show(title: String, message: String, result: @escaping (Bool) -> Void) {
        // Create the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Create the actions
        let okAction = UIAlertAction(title: NSLocalizedString("Approve", comment: ""), style: .default) {
            UIAlertAction in
            result(true)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Reject", comment: ""), style: .cancel) {
            UIAlertAction in
            result(false)
        }

        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        // Present the controller
        alertController.show()
    }
}
