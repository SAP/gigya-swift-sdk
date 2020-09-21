# Swift Two Factor Authentication Library
​
## Description
​
The Gigya Swift TFA package provides the ability to integrate native Two Factor Authentication flows within your Swift application without using the ScreenSets feature.
​
Current supported TFA providers are: **Email, Phone, TOTP & Push**.
​
## Integration using binary file.
​
In order to integrate the Gigya Swift TFA package you will need to download the latest library from our download site and add the file to your Embedded Binaries section.
​
## Integration using Cocoapods
For the Tfa SDK, open your Podfile and add this follow line:
```
pod 'GigyaTfa'
```
Once you have completed the changes above, run the following:
```
pod install
```
​
## Two Factor Authentication interruptions
​
When using login/register flows, you are able to override two additional callback methods within the GigyaLoginResult class:
​
```
switch result {
   case .success(let data):
    // Success
   case .failure(let error):
     guard let interruption = error.interruption else { return }
    // Evaluage interruption.
     switch interruption {
       case .pendingTwoFactorRegistration(let response, let inactiveProviders, let factory):
       // The login/register flow was interrupted with error 403102 (Account Pending TFA Registration)
       case .pendingTwoFactorVerification(let response, let activeProviders, let factory):
      // The login/register flow was interrupted with error 403101 (Account Pending TFA Verification)
    default:
       break
   }
}
```
These callbacks are called interruption callbacks. Their main purpose is to inform the client that a Two Factor Authentication interruption has happened. In addition they provide the user with the relevant data needed to resolve the interruption in the same context they were initiated.
​
```
In order to use Two Factor Authentication for your site please please read:
Risk Based Authentication
```
```
The Swift TFA package is not a stand alone library. Please make sure you have have already integrated our Swift SDK.
```
​
### Initial interruption data
​
response: GigyaResponseModel - The initial interruption response received by the login/register attempt.
inactiveProviders: **[TFAProviderModel]** - A list containing the Two Factor Authentication providers available for registration.
activeProviders: **[TFAProviderModel]** - A list containing the registered Two Factor Authentication providers for this account.
resolverFactory: **TFAResolverFactory** - A provided factory class which allows you to fetch the appropriate resolver class in order to continue
the login/register flow.
​
## Email Verification
​
Resolving email verification Two Factor Authentication is done using the RegisteredEmailsResolver class.
​
Email verification requires you to have a valid registered email account.
​
Code example for email verification flow. Note that this is just a partial representation of the flow and will require additional UI intervention.
​
```
let registeredEmailsResolver = resolverFactory.getResolver(for: RegisteredEmailsResolver.self)
registeredEmailsResolver?.getRegisteredEmails(completion: registeredEmailsResult(result:))
```
```
func registeredEmailsResult(result: TFARegisteredEmailsResult) {
   switch result {
   case .registeredEmails(let emails):
     registeredEmailsResolver?.sendEmailCode(with: selectedEmail, registeredEmailsResult(result:))
   case .emailVerificationCodeSent(let resolver):
     resolver.verifyCode(provider: .email, verificationCode: code, completion: { result in
       switch result {
       case .resolved:
        // Flow completed.
       case .invalidCode:
       // Invalid code inserted. Try again.
       case .failed(let error):
       // handle error.
     }
   })
   case .error(let error):
    // handle error.
   }
}
```
```
All resolver flows will end with redirecting the finalized logged in/registered account to the original "success" case.
In addition, at the end of each successful flow a "resolved" case will be called in order to give an optional logic check point if any other
application tasks are needed to be performed.
```
​
## Phone Registration
​
Resolving phone Two Factor Authentication registration is done using the RegisterPhoneResolver class.
​
Code example for phone registration flow. Note that this is just a partial representation of the flow and will require additional UI intervention.
​
```
let registerPhoneResolver = resolverFactory.getResolver(for: RegisterPhoneResolver.self)
registerPhoneResolver.registerPhone(phone: number, completion: registerPhoneResult(result:))
```
```
func registerPhoneResult(result: TFARegisterPhonesResult) {
   switch result {
   case .verificationCodeSent(let resolver):
      // Verification code was sent to registered phone number. At this point you should update your UI to support verification input.
     // After UI has been updated and the verification code is available, you are able to use:
      resolver.verifyCode(provider: .phone, verificationCode: code, completion: { result in
        switch result {
        case .resolved:
        // Flow completed.
       case .invalidCode:
       // Invalid code inserted. Try again.
       case .failed(let error):
       // handle error.
    }
  })
  case .error(let error):
   // handle error.
  }
}
```
​
## Phone Verification
​
Resolving phone Two Factor Authentication verification is done using the *RegisteredPhonesResolver* class.
​
Code example for phone verification flow. Note that this is just a partial representation of the flow and will require additional UI intervention.
​
```
let registeredPhonesResolver = resolverFactory.getResolver(for: RegisteredPhonesResolver.self)
registeredPhonesResolver.getRegisteredPhones(completion: registeredPhonesResult(result:))
```
```
func registeredPhonesResult(result: TFARegisteredPhonesResult) {
   switch result {
   case .registeredPhones(let phones):
   // Display list of registered phones to the user so he will be able to choose where to send verification code sms/voice call.
   // After user chooses call: 
    registeredPhonesResolver.sendVerificationCode(with: phone, method: .sms /* can be use .sms or .voice */, completion: registeredPhonesResult(result:))
     case .verificationCodeSent(let resolver):
       // Verification code successfully sent.
       // You are now able to verify the code received calling:
       resolver.verifyCode(provider: .phone, verificationCode: code, rememberDevice: false /* set true to remember device */, completion: { result in
         switch result {
         case .resolved:
           // Flow completed.
         case .invalidCode:
          // Invalid code inserted. Try again.
         case .failed(let error):
         // handle error.
       }
    })
    case .error(let error):
      // handle error.
   }
}
```
​
## TOTP Registration
​
Resolving TOTP Two Factor Authentication registration is done using the *RegisterTotpResolver* class.
​
Code example for TOTP registration flow. Note that this is just a partial representation of the flow and will require additional UI intervention.
​
```
let registerTOTPResolver = resolverFactory.getResolver(for: RegisterTotpResolver.self)
registerTOTPResolver.registerTotp(completion: registerTotpResult(result:))
```
```
func registerTotpResult(result: TFARegisterTotpResult) {
   switch result {
   case .QRCodeAvilabe(let image, let resolver):
    // UIImage object QR code is available. Display for the user to scan.
    // Once the user scans the code and a verification code is available via the authenticator application you are able to call: 
     verifyTotpResolver.verifyTOTPCode(verificationCode: code, rememberDevice: false /* set true to save device */, completion: { (result) in
       switch result {
       case .resolved:
       // Flow completed.
       case .invalidCode:
       // Verification code invalid. Display error and try again.
      case .failed(let error):
      // Handle error.
    }
  })
  case .error(let error):
   // Handle error.
  }
}
```
​
## TOTP Verification
​
Resolving TOTP Two Factor Authentication verification is done using the *VerifyTotpResolver* class.
​
Code example for TOTP verification flow. Note that this is just a partial representation of the flow and will require additional UI intervention.
​
​
```
let verifyTOTPResolver = resolverFactory.getResolver(for: VerifyTotpResolver.self)
```
```
// At this point the code is already available to the user using his preferred authenticator application.
verifyTotpResolver.verifyTOTPCode(verificationCode: code, rememberDevice: false /* set true to save device */, completion: { (result) in
   switch result {
   case .resolved:
    // Flow completed.
   case .invalidCode:
    // Verification code invalid. Display error and try again.
   case .failed(let error):
    // Handle error.
   }
})
```
## Push TFA
​
The push TFA feature allows you to secure your login using push notifications to any registered devices.
​
### Enable Push TFA
​
In order to use push TFA you need to add the following line to your *AppDelegate.swift*:
​
```
GigyaTfa.shared.registerForRemoteNotifications()
```
## The Push TFA Flow
​
### Opt-In process
​
In order for a client to opt-in to use the push TFA feature you will need to add the option to opt-in after the user have successfully logged in.
​
```
GigyaTfa.shared.OptiInPushTfa { (result) in
   switch result {
   case .success:
     // Step one of the opt-in process has been completed.
    // Wait for approval push notification and to complete flow.
  case .failure(let error):
   // Handle error.
  }
}
```
​
```
This feature currently uses all registered mobile devices to verify any login process made from a website for a specific account.
*Mobile login with push TFA is not currently implemented.
```
​
Tap on the push -> Approve in order to finalize the opt-in process.
​
You should receive another notification to indicate the flow has been successfully completed.
​
### Verification process
​
Once you are opt-in to use the Push TFA service, once your client will login to his account on the website an approval notification will be sent to
all registered devices (which have completed the opt-in process).
​
**Once you choose to Approve your client will be logged into the system.**
​
### Important Information
Methods that are no longer available in version 1.0.6 and above:
```
GigyaTfa.shared.foregroundNotification
GigyaTfa.shared.receivePush
GigyaTfa.shared.verifyPush
```
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
