//
//  FavScreenView.swift
//  
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import SwiftUI

struct FavScreenView: View {
    @State var coordinator: HomeCoordinator
    
    var body: some View {
        VStack {
            
        }
        .modifier(NavBar(Text("Favorites")))
        .environment(coordinator)
    }
}

#Preview {
    FavScreenView(coordinator: HomeCoordinator(parent: AppCoordinator(), routing: RoutingManager(), id: .fav))
}
