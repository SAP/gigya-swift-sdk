//
//  InterruptionEnum.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 13/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public enum Interruption: Int, CaseIterable {
    case pendingRegistration = 206001
    case pendingVerification = 206002
    case conflictingAccounts = 409003
    case pendingTwoFactorRegistration = 403102
    case pendingTwoFactorVerification = 403101
    case accountLinked = 200009
    case pendingPasswordChange = 403100
    case captchaRequired = 401020
}
