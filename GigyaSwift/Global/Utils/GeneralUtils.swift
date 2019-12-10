//
//  GeneralUtils.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 19/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//
import UIKit
import UserNotifications

public class GeneralUtils {
    public func iosVersion() -> String {
        return UIDevice.current.systemVersion
    }

    public func showNotification(title: String, body: String, id: String, userInfo: [AnyHashable: Any] = [:]) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString(title, comment: "")
        content.body = NSLocalizedString(body, comment: "")
        content.userInfo = userInfo
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    public func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController
    }

    public func show(vc: UIViewController, title: String, message: String, result: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            // Create the alert controller
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

            // Create the actions
            let okAction = UIAlertAction(title: NSLocalizedString("Approve", comment: ""), style: .default) {
                UIAlertAction in
                result(true)
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("Deny", comment: ""), style: .cancel) {
                UIAlertAction in
                result(false)
            }

            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)

            // Present the controller
            vc.present(alertController, animated: true, completion: nil)
        }
    }
}

