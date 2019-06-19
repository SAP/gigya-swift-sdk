//
//  ValidateLoginModel.swift
//  TestApp
//
//  Created by Shmuel, Sagi on 18/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct ValidateLoginData: Codable {
    let errorCode: Int
    let callId: String
}
