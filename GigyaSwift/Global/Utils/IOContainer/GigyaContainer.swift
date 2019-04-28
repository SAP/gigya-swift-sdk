//
//  GigyaContainer.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 31/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

typealias GigyaResolverHandling<T> = (GigyaResolverProtocol) -> T

class IOCContainer {
    private var services: [String: ServiceMaker<Any>] = [:]

    func register<Service>(service: Service.Type, isSingleton: Bool = false, factory: @escaping GigyaResolverHandling<Service>) {
        let serviceName = String(describing: Service.self)

        services[serviceName] = ServiceMaker<Any>(method: factory, isSingleton: isSingleton, resolver: self)
    }
}

extension IOCContainer: GigyaResolverProtocol {
    func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        let instanceName = String(describing: Service.self)
        let instance = services[instanceName]?.method(self)

        return instance as? Service
    }
}
