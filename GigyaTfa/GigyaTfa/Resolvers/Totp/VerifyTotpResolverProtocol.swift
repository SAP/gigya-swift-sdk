//
//  VerifyTotpResolverProtocol.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 24/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public protocol VerifyTotpResolverProtocol {
    func verifyTOTPCode(verificationCode: String, rememberDevice: Bool, completion: @escaping (VerifyCodeResultCallback) -> Void )
}
