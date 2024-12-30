//
//  AppDelegate.swift
//  
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import Foundation
import UIKit
import Firebase
import FirebaseMessaging
import Gigya
import GigyaTfa
import GigyaAuth
import FBSDKCoreKit
import AppTrackingTransparency
import AdSupport
import LineSDK


class AppDelegate: NSObject, UIApplicationDelegate {
    var gigya: GigyaCore<AccountModel>?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {        
        LoginManager.shared.setup(channelID: "2004690310", universalLinkURL: nil)

        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        // Gigya dependencies
        gigya = Gigya.sharedInstance(AccountModel.self)

        GigyaLogger.setDebugMode(to: true)

        GigyaAuth.shared.registerForRemoteNotifications()
        GigyaTfa.shared.registerForRemoteNotifications()
        GigyaAuth.shared.register(scheme: AccountModel.self)
        
        GigyaAuth.shared.registerForAuthPush { res in
            
        }
        
        UNUserNotificationCenter.current().delegate = self

        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Request permissions for tracking ( for Facebook limited login )
        requestPermission()
        
        return true
    }
    
    func requestPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")
                    
                    // Now that we are authorized we can get the IDFA
                    print(ASIdentifierManager.shared().advertisingIdentifier)
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
        }
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let _ = LoginManager.shared.application(app, open: url)
        let handled = ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation])

        return handled
    }
}

// MARK: Firebase Messaging
extension AppDelegate: MessagingDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")

        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken!)")
        let dataDict:[String: String] = ["token": fcmToken!]

        gigya?.updatePushToken(key: fcmToken!)
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}

// MARK: Menagment notifications
@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        gigya?.receivePush(userInfo: userInfo, completion: completionHandler)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // tap on notification
        gigya?.verifyPush(with: response)

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .banner, .list])
    }
}
