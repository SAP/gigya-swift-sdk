//
//  ProfileCoordinator.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 26/02/2024.
//

import Foundation

class ProfileCoordinator: Coordinator, Identifiable {
    override init(parent: AppCoordinator, routing: RoutingManager, id: Screens) {
        super.init(parent: parent, routing: routing, id: id)
        
        routing.flowManager?.currentCordinator = self
    }
    
    override func start() {
        
    }

    func popToRoot() {
        routing.popToRoot()
    }

}
