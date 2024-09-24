//
//  BitsBytesApp.swift
//
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import SwiftUI

@main
struct BitsBytesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: AppCoordinator())
        }
    }
}
