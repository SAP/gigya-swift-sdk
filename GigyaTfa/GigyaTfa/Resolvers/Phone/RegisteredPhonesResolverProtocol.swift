//
//  RegisteredPhonesResolverProtocol.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 24/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import Gigya

public protocol RegisteredPhonesResolverProtocol {
    func provider(_ provider: TFAProvider)

    func getRegisteredPhones(completion: @escaping (RegisteredPhonesResult) -> Void)

    func sendVerificationCode(with phone: TFARegisteredPhone, method: TFAPhoneMethod, lang: String, completion: @escaping (RegisteredPhonesResult) -> Void)
}
