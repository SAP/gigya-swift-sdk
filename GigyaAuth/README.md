# Swift Authentication Library
​
## Description
​
This library enables you to use additional authentication methods from the standard login flow.
​
```
This library can only be used with Customer Data Cloud Swift SDK version 1.0.6 or above.
```
​
## Integrating using Cocoapods
For the Auth SDK, open your Podfile and add this follow line:
```
pod 'GigyaAuth'
```
​
Once you have completed the changes above, run the following:
```
pod install
```
​
## Enabling Push Notifications
​
To integrate the authentication library within your application make sure that you have successfully integrated the Swift core library as it is a mandatory dependency for using the new authentication flows.
​
To use Push Authentication, add the following line to your *AppDelegate.swift*:
```
GigyaAuth.shared.registerForRemoteNotifications()
```
​
```
Before beginning your implementation, it is mandatory to implement the Push notification service inside the Swift Core SDK.
```
​
## Add the Gigya Messaging Service
​
Enable remote notifications: In your app project, go to your project target and open Capabilities > Background Modes. Make sure Remote notifications is enabled.
Allow Firebase to send foreground notifications: After you called *FirebaseApp.configure()* add the follow line:
```
FirebaseApp.configure()
// Add this line
Messaging.messaging().shouldEstablishDirectChannel = true
```
Add Firebase delegate: The Gigya server requires receiving the push token to send push notifications to your user's devices. To do so, add the following to your AppDelegate.swift:
```
// MessagingDelegate implementation as shown in Firebase documentation.
func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
  print("Firebase registration token: \(fcmToken)")
  let dataDict:[String: String] = ["token": fcmToken]
  NotificationCenter.default.post(name:
  Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
  Gigya.sharedInstance().updatePushToken(key: fcmToken)
}
​
// Foreground notification receive
func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
  Gigya.sharedInstance().foregroundNotification(with:
  remoteMessage.appData)
  }
```
Handling push notifications: to let the SDK handle incoming push notifications, add the following to your *AppDelegate.swift* file:
```
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
  // Enable Gigya's handling of the notification.
  Gigya.sharedInstance().receivePush(userInfo: userInfo, completion: completionHandler)
}
​
```
Notification interaction: Gigya's notifications require action confirmations (end-user approving or denying the push opt-in). To open the
actions alert confirmation, add the following to your *AppDelegate.swift* file.
```
@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    // tap on notification interaction
    Gigya.sharedInstance().verifyPush(with: response)
   }
}
```
​
### Authentication Flow
​
Before a user can authenticate with a push notification, they have to be registered on your app (with the standard SAP Customer Data Cloud registration flow) and must have an active session.
In addition, to start the Push Authentication flow for a user, their device needs to be registered
for this service. Device registration is done by calling the library **"registerForAuthPush"** method:
​
```
GigyaAuth.shared.registerForAuthPush { result in
  switch result {
  case .success:
     // Register to login by Push has been completed.
  case .failure(let error):
    // Handle error.
  }
}
```
​
Once the device is successfully registered, when the user starts a login process on a separate device (e.g. desktop), the registered mobile device will receive a push notification which they can approve or deny.
​
## Limitations
None
​
## Known Issues
None
​
## How to obtain support
Via SAP standard support.
https://developers.gigya.com/display/GD/Opening+A+Support+Incident
​
## Contributing
Via pull request to this repository.
​
## To-Do (upcoming changes)
None
​
