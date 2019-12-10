//
//  AppDelegate.swift
//  GigyaE2ETestsApp
//
//  Created by Shmuel, Sagi on 11/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import LineSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return LineSDKLogin.sharedInstance().handleOpen(url)
    }

}

