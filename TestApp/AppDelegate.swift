//
//  AppDelegate.swift
//  TestApp
//
//  Created by Shmuel, Sagi on 25/02/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import Gigya
import LineSDK
import Firebase
import GoogleUtilities
import GigyaTfa
import GigyaAuth
import FBSDKCoreKit
import FBSDKShareKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    let gigya = Gigya.sharedInstance(UserHost.self)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self

        WXApi.registerApp("wx222c4ccaa989aa00", universalLink: "https://")

        UNUserNotificationCenter.current().delegate = self

        Messaging.messaging().shouldEstablishDirectChannel = true

        GigyaLogger.setDebugMode(to: true)
        GigyaAuth.shared.registerForRemoteNotifications()
        GigyaTfa.shared.registerForRemoteNotifications()

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        if #available(iOS 13.0, *) {
            gigya.registerSocialProvider(of: .apple, wrapper: AppleSignInWrapper())
        } else {
            // Fallback on earlier versions
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")

        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken]

        gigya.updatePushToken(key: fcmToken)
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        gigya.foregroundNotification(with: remoteMessage.appData)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        gigya.receivePush(userInfo: userInfo, completion: completionHandler)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let _ = LineSDKLogin.sharedInstance().handleOpen(url)
        let _ = WXApi.handleOpen(url, delegate: self)

        let handled = ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation])

        return handled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

// MARK: Menagment notifications
@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // tap on notification
        gigya.verifyPush(with: response)

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .alert])
    }
}
