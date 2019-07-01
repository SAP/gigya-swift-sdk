//
//  GeneralUtils.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 17/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UserNotifications
import Gigya

class GeneralUtils {
    static func iosVersion() -> String {
        return UIDevice.current.systemVersion
    }

    static func showNotification(title: String, body: String, id: String) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString(title, comment: "")
        content.body = NSLocalizedString(body, comment: "")


        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
