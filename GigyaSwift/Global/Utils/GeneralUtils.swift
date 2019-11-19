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
}

