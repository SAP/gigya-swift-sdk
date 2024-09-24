//
//  NavStyle.swift
//  
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import Foundation
import SwiftUI

struct NavBar<C: View>: ViewModifier {
    
    @State var showIcon: Bool = true
    @Environment(AppCoordinator.self) var appCordinator: AppCoordinator

    @ViewBuilder var title: C
    
    init(_ title: C, showIcon: Bool = true) {
        self.title = title
        self.showIcon = showIcon
    }
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    title
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                if showIcon {
                    Image("settings").onTapGesture {
                        appCordinator.pushToSettings()
                    }.accessibilityIdentifier("settingsButton")
                }
            }
    }
}

