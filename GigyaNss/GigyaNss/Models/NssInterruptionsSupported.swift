//
//  NssInterruptionsSupported.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 30/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya

enum NssInterruptionsSupported: String {
    case pendingRegistration
    case pendingVerification
    case pendingPasswordChange
    case conflitingAccount
    case pendingTwoFactorRegistration
    case pendingTwoFactorVerification
    case unknown
}


extension GigyaInterruptions {
    var description: NssInterruptionsSupported {
        switch self {
        case .pendingRegistration:
            return .pendingRegistration
        default:
            return .unknown
        }
    }
}
