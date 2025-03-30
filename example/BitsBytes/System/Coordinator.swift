//
//  Coordinator.swift
//  
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import Foundation
import SwiftUI

protocol CoordinatorProtocol: AnyObject, ObservableObject {
    var parent: AppCoordinator { get set }
    var routing: RoutingManager { get set }
    var id: Screens { get set }
    
    func start()
}

@Observable
open class Coordinator: CoordinatorProtocol {
    var parent: AppCoordinator
    var routing: RoutingManager
    var id: Screens

    init(parent: AppCoordinator, routing: RoutingManager, id: Screens) {
        self.parent = parent
        self.routing = routing
        self.id = id
    }
    
    func start() {
        
    }
    
    
}

enum Screens: String, CaseIterable {
    case home
    case search
    case cart
    case fav
    case profile
    case configuration
    case signin
    case register
    case signinemail
    case aboutme
    case passwordless
    case otpLogin
    case changePass
    case resetPassword
    case linkAccount
    case penddingRegistration
    case addPhone
    case tfaMethods
    case sfSafari
    case deviceFlow

    static func onlyTabs() -> [Screens] {
        return [.home, .search, .cart, .fav, .profile]
    }
    
}

