//
//  NavigationWrapperView.swift
//
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import SwiftUI

struct NavigationWrapperView<T: Coordinator>: View {
    @State var coordinator: T
    
    var body: some View {
        NavigationStack(path: $coordinator.routing.screens) {
            coordinator.routing.navigate(to: coordinator.id)
                .navigationDestination(for: Screens.self) { screen in
                    coordinator.routing.navigate(to: screen)
                }

        }
        .environment(coordinator)
    }
}

