//
//  TFAProvider.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 21/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

@frozen
public enum TFAProvider: String, Codable {
    case phone = "gigyaPhone"
    case liveLink = "livelink"
    case email = "gigyaEmail"
    case totp = "gigyaTotp"
    case push = "gigyaPush"
}
