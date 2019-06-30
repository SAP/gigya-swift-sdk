//
//  IOCVerifyCodeResolver.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 24/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import Gigya

public protocol VerifyCodeResolverProtocol {
    func verifyCode(provider: TFAProvider, verificationCode: String, rememberDevice: Bool, completion: @escaping (VerifyCodeResultCallback) -> Void)
}
