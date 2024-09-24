//
//  CartScreenView.swift
//  
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import SwiftUI

struct CartScreenView: View {
    @State var coordinator: Coordinator
    
    var body: some View {
        VStack {
            
        }
        .modifier(NavBar(Text("Cart")))
        .environment(coordinator)
    }
}

#Preview {
    CartScreenView(coordinator: HomeCoordinator(parent: AppCoordinator(), routing: RoutingManager(), id: .cart))
}
