//
//  SearchScreenView.swift
//  
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import SwiftUI

struct SearchScreenView: View {
    @State var coordinator: Coordinator
    
    var body: some View {
        VStack {
            
        }
        .modifier(NavBar(Text("Search")))
        .environment(coordinator)
    }
}

#Preview {
    SearchScreenView(coordinator: Coordinator(parent: AppCoordinator(), routing: RoutingManager(), id: Screens.search))
}
