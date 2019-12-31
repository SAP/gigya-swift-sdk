//
//  Coordinator.swift
//  GigyaUITestsApp
//
//  Created by Shmuel, Sagi on 03/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import SwiftUI

protocol Coordinator {
    func start()
}

class CoordinatorsContainer: NSObject {
    private(set) var container: [CoordinatorKeys: Coordinator] = [:]

    var window: UIWindow?

    func add(_ key: CoordinatorKeys, with coordinator: Coordinator) {
        container[key] = coordinator
    }

    func remove(_ key: CoordinatorKeys) {
        container.removeValue(forKey: key)
    }


    func setCoordinator<T>(hostController: UIHostingController<T>) {
        window?.rootViewController = hostController

        window?.makeKeyAndVisible()
    }
}

enum CoordinatorKeys {
    case login
    case main
}
