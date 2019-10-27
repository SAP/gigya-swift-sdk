//
//  IOCInterruptionResolverFactory.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 23/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol InterruptionResolverFactoryProtocol {

    var isEnabled: Bool { get }

    func setEnabled(_ sdkHandles: Bool)

    func resolve<T: GigyaAccountProtocol>(error: NetworkError, businessDelegate: BusinessApiDelegate, completion: @escaping (GigyaLoginResult<T>) -> Void)
}
