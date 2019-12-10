//
//  PushNotificationModes.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 18/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

@frozen
public enum PushNotificationModes: String {
    case optin
    case verify
    case cancel
}
