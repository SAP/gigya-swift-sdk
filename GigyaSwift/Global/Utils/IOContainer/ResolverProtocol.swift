//
//  GigyaResolverProtocol.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 01/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

// TODO: how to make protocol with generic
public protocol ResolverProtocol {
    func resolve<Service>(_ serviceType: Service.Type) -> Service?
}
