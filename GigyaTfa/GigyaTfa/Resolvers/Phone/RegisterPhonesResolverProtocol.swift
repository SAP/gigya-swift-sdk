//
//  RegisterPhonesResolverProtocol.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 24/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Gigya

public protocol RegisterPhonesResolverProtocol {
    func registerPhone(phone: String, method: TFAPhoneMethod, completion: @escaping (RegisterPhonesResult) -> Void )
}
