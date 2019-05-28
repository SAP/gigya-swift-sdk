//
//  TFAProvider.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 21/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public enum TFAProvider: String, Codable {
    case phone = "gigyaPhone"
    case liveLink = "liveLink"
    case email = "gigyaEmail"
    case totp = "gigyaTotp"
}
