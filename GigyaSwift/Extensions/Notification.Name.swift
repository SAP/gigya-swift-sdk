//
//  Notification.Name.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 06/08/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import NotificationCenter

extension Notification.Name {
    static var didGigyaSessionExpire = Notification.Name(rawValue: "didGigyaSessionExpire")

    static var didInvalidateSession = Notification.Name(rawValue: "didInvalidateSession")
}
