//
//  AppCoordinator.swift
//  GigyaUITestsApp
//
//  Created by Shmuel, Sagi on 03/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import SwiftUI

class AppCoordinator: CoordinatorsContainer, Coordinator {
    init(window: UIWindow) {
        super.init()
        
        self.window = window
    }

    func start() {
        showMain()
    }

    func showMain() {
        let mainCoordinator = MainCoordinator()
        add(.main, with: mainCoordinator)
        mainCoordinator.start()

        setCoordinator(hostController: mainCoordinator.getView())
    }

    func showLogin() {

    }

}

