//
//  ContentView.swift
//  
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import SwiftUI

struct AppCoordinatorView: View {
    @State var coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        if self.coordinator.isAppActive {
            ZStack{
                VStack {
                    TabView(selection: coordinator.selectionBinding){
                        
                        NavigationWrapperView(coordinator: coordinator.coordinatorStack[.home]!).tag(Screens.home)
                        
                        SearchScreenView(coordinator: coordinator.coordinatorStack[.search]! as! HomeCoordinator).tag(Screens.search)
                        
                        FavScreenView(coordinator: coordinator.coordinatorStack[.fav]!  as! HomeCoordinator).tag(Screens.fav)
                        
                        CartScreenView(coordinator: coordinator.coordinatorStack[.cart]! as! HomeCoordinator).tag(Screens.cart)
                        
                        NavigationWrapperView<ProfileCoordinator>(coordinator: coordinator.coordinatorStack[.profile]! as! ProfileCoordinator).tag(Screens.profile)

                    }
                }
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: coordinator.selectionBinding)
                }
            }
            .environment(coordinator)
            .ignoresSafeArea()
        } else {
            SplashScreenView(isActive: $coordinator.isAppActive)
        }

    }
}

#Preview {
    AppCoordinatorView(coordinator: AppCoordinator())
}
