//
//  TFAResolver.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 23/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

open class TFAResolver<T: GigyaAccountProtocol>: Resolver<T> {
    public var gigyaAssertion: String?
}
