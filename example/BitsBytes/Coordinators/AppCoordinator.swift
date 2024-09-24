//
//  AppCoordinator.swift
//  
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import Foundation
import Combine
import SwiftUI
import Observation

@Observable
class AppCoordinator {
    let gigya = GigyaService()
    
    var selectedTab: Screens
    var coordinatorStack: [Screens: Coordinator]
    var isAppActive = false
    
    var isLoggedIn: Bool
    
    var webViewMode: Bool = false

    var selectionBinding: Binding<Screens> { Binding(
        get: {
            self.selectedTab
        },
        set: {
            // check if it the current tab and pop to the root
            if $0 == self.selectedTab {
                self.coordinatorStack[self.selectedTab]?.routing.popToRoot()
            }
            self.selectedTab = $0
        }
    )}

    
    init() {
        self.selectedTab = .home
        self.isLoggedIn = gigya.shared.isLoggedIn()

        self.coordinatorStack = [:]
        let homeRouting = RoutingManager()
        self.coordinatorStack[.home] = HomeCoordinator(parent: self, routing: homeRouting, id: .home)
        
        let searchRouting = RoutingManager()
        self.coordinatorStack[.search] = HomeCoordinator(parent: self, routing: searchRouting, id: .search)
        
        let favRouting = RoutingManager()
        self.coordinatorStack[.fav] = HomeCoordinator(parent: self, routing: favRouting, id: .fav)
        
        let cartRouting = RoutingManager()
        self.coordinatorStack[.cart] = HomeCoordinator(parent: self, routing: cartRouting, id: .cart)
        
        let profileRouting = RoutingManager()
        self.coordinatorStack[.profile] = ProfileCoordinator(parent: self, routing: profileRouting, id: .profile)
        

    }
    
    func pushToSettings() {
        self.coordinatorStack[selectedTab]?.routing.push(.configuration)
    }
}
