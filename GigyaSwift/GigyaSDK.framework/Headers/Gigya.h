#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __has_include(<WebKit/WebKit.h>)
#import <WebKit/WebKit.h>
#endif

// Gigya
#import "GSSession.h"
#import "GSObject.h"
#import "GSResponse.h"
#import "GSRequest.h"
#import "GSUser.h"
#import "GSAccount.h"
#import "GSSessionDelegate.h"
#import "GSSocializeDelegate.h"
#import "GSAccountsDelegate.h"
#import "GSWebBridge.h"
#import "GSPluginView.h"
#import "GSLogger.h"

// External SDKs
#if defined(__has_include)

#if __has_include(<Bolts/Bolts.h>) && __has_include(<FBSDKCoreKit/FBSDKCoreKit.h>) && __has_include(<FBSDKLoginKit/FBSDKLoginKit.h>)
#import <Bolts/Bolts.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#endif
#if __has_include(<GoogleSignIn/GoogleSignIn.h>)
#import <GoogleSignIn/GoogleSignIn.h>
#endif
#if __has_include(<Social/Social.h>) && __has_include(<Accounts/Accounts.h>)
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#endif

#endif

// Consts
static NSString * _Nonnull const GSGigyaSDKVersion = @"iOS_3.6.10";
static NSString * _Nonnull const GSDefaultAPIDomain = @"us1.gigya.com";
static NSString * _Nonnull const GSGigyaSDKDomain = @"com.gigya.GigyaSDK";
static NSString * _Nonnull const GSInvalidOperationException = @"com.gigya.GigyaSDK:InvalidOperationException";

/**
 This enum defines some of the error codes that can be returned from the SDK and REST API. 
 
 For a complete list, see <a target="_blank" href="http://developers.gigya.com/display/GD/Response+Codes+and+Errors+REST">Response Codes and Errors</a>.
 */
typedef NS_ENUM(NSInteger, GSErrorCode) {
    /** The user has canceled the login process. */
    GSErrorCanceledByUser = 200001,
    
    /** The user account is pending registration. */
    GSErrorAccountPendingRegistration = 206001,
    
    /** One of the required parameters for the method was not provided. */
	GSErrorMissingRequiredParameter = 400002,
    
    /** The difference between the request's timestamp and the server time is larger than 120 seconds. */
    GSErrorInvalidTime = 403002,
    
    /** The session is invalid. */
    GSErrorUnauthorizedUser = 403005,
    
    /** Permission denied. */
	GSErrorPermissionDenied = 403007,
    
    /** Requested user has no valid session. */
    GSErrorNoValidSession = 403012,
    
    /** This operation needs a user permission and it was not requested. */
   	GSErrorPermissionNotRequested = 403022,
    
    /** General server error during the login process. */
    GSErrorServerLoginFailure = 500002,
    
    /** General error from the provider. */
    GSErrorProviderError = 500023,
    
    /** Network error, for example no Internet connection. */
	GSErrorNetworkFailure = 500026,

    /** Failure to load gigya.js in GSPluginView. */
    GSErrorLoadFailed = 500032,
    
    /** Javascript error while loading plugin. Please make sure the plugin name is correct. */
    GSErrorJSException = 405001
};

// Block definitions

/*!
 User Info handler
 
 @param user User
 @param error Error
 */
typedef void(^_Nullable GSUserInfoHandler)(GSUser * _Nullable user, NSError * _Nullable error);

/*!
 Permission request result handler
 
 @param granted Retrieves whether requested permissions were granted
 @param error Error
 @param declinedPermissions Declined permissions list
 */
typedef void(^_Nullable GSPermissionRequestResultHandler)(BOOL granted, NSError * _Nullable error, NSArray * _Nullable declinedPermissions);

/*!
 Plugin completion handler
 
 @param closedByUser Retrieves whether plugin was closed by the user
 @param error Error
 */
typedef void(^GSPluginCompletionHandler)(BOOL closedByUser, NSError * _Nullable error);

/*!
 Session completion handler
 
 @param session The current gigya session
 */
typedef void(^GSGetSessionCompletionHandler)(GSSession * _Nullable session);

@protocol GSPluginViewDelegate;

/** GigyaSDK */
@interface Gigya : NSObject
NS_ASSUME_NONNULL_BEGIN

/** @name Setting Up GigyaSDK */

/*!
 Initializes the Gigya SDK and sets your partner API key.
 @param apiKey Your partner API key.
 @param application The application parameter provided by the AppDelegate.
 @param launchOptions The launchOptions parameter provided by the AppDelegate.
 */
+ (void)initWithAPIKey:(NSString * _Nullable)apiKey application:(UIApplication * _Nullable)application launchOptions:(NSDictionary * _Nullable)launchOptions;

/*!
 Initializes the Gigya SDK and sets your partner API key.
 @param apiKey Your partner API key.
 @param application The application parameter provided by the AppDelegate.
 @param launchOptions The launchOptions parameter provided by the AppDelegate.
 @param apiDomain Your partner API domain.
 */
+ (void)initWithAPIKey:(NSString * _Nullable)apiKey application:(UIApplication * _Nullable)application launchOptions:(NSDictionary * _Nullable)launchOptions APIDomain:(NSString * _Nullable)apiDomain;

/*!
 Your partner API key.
 */
+ (NSString * _Nonnull)APIKey;

/*!
 Your partner API domain. All Gigya requests will use this as base domain. Default value is `gigya.com`.
 */
+ (NSString * _Nullable)APIDomain;

/*!
 Retrieves the current Gigya session, or `nil` if not connected.
 */
+ (void)getSessionWithCompletionHandler:(GSGetSessionCompletionHandler _Nonnull)handler;

/*!
 Checks if the currently loaded Gigya session is valid.
 
 If this is used before a session is loaded, it is possible to that this will return false positives
 */
+ (BOOL)isSessionValid;

/*!
 Sets the active Gigya session.
 
 After setting the session manually, the SDK will retrieve the user information and invoke the relevant <sessionDelegate> methods.

 The session will persist between app launches, until cleared by <logout>.
 
 @param session A new Gigya session, with valid session token and session secret.
 */

+ (void)setSession:(GSSession * _Nullable)session;

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (id<GSSessionDelegate>)sessionDelegate;
+ (void)setSessionDelegate:(id<GSSessionDelegate>)delegate __attribute((deprecated("Use [Gigya setSocializeDelegate:] with a GSSocializeDelegate instead")));
#pragma GCC diagnostic warning "-Wdeprecated-declarations"

/** @name Registering for Session Events */

/*!
 Gets the delegate that receives Gigya Socialize events.
 @see GSSocializeDelegate
 */
+ (id<GSSocializeDelegate> _Nullable)socializeDelegate;

/*!
 Sets the delegate that receives Gigya Socialize events. This delegate will be called regardless of the handler blocks passed to the different methods.
 
 @param socializeDelegate Socialize events delegate
 @see GSSocializeDelegate
 */
+ (void)setSocializeDelegate:(id<GSSocializeDelegate> _Nullable)socializeDelegate;

/*!
 Gets the delegate that receives Gigya Accounts events.
 @see GSAccountsDelegate
 */
+ (id<GSAccountsDelegate> _Nullable)accountsDelegate;

/*!
 Sets the delegate that receives Gigya Accounts events. This delegate will be called regardless of the handler blocks passed to the different methods.
 
 @param accountsDelegate Accounts events delegate
 @see GSAccountsDelegate
 */
+ (void)setAccountsDelegate:(id<GSAccountsDelegate> _Nullable)accountsDelegate;

/** @name Logging In */

/*!
 Logs in the user with the specified provider.
 
 If the provider supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used instead of fast-app-switch.
 Calling this method when the user is already logged in will result in an exception.
 
 @param provider The provider's name.
 */
+ (void)loginToProvider:(NSString * _Nonnull)provider;
+ (void)showLoginDialogOver:(UIViewController *)viewController
                   provider:(NSString *)provider __attribute((deprecated("Use loginToProvider: instead")));


/*!
 Logs in the user with the specified provider.

 If the provider supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used instead of fast-app-switch.
 Calling this method when the user is already logged in will result in an exception.
 
 @param provider The provider's name.
 @param parameters A dictionary of optional login parameters. May include the following values:

 | Name                       | Type        | Description                                                                         |
 |----------------------------|-------------|-------------------------------------------------------------------------------------|
 | cid                        | NSString    | A string of maximum 100 characters length. This string will be associated with each transaction and will later appear on reports generated by Gigya, in the "Context ID" combo box. The cid allows you to associate the report information with your own internal data. The "Context ID" combo box lets you filter the report data by application context. |
 | facebookReadPermissions    | NSString    | A comma delimited list of Facebook extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. Please refer to Facebook's <a target="_blank" href="https://developers.facebook.com/docs/reference/login/#permissions">permissions</a> documentation for the complete list of read permissions. Note: you should only include read permissions, otherwise Facebook will fail the login. |
 | facebookLoginBehavior      | NSNumber    | A <a target="_blank" href="https://developers.facebook.com/docs/reference/ios/current/class/FBSDKLoginManager/#FBSDKLoginBehavior enum">FBSDKLoginBehavior</a> value determining the Facebook SDK login behavior. |
 | googleExtraPermissions     | NSString    | This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. The supported values are: "wallet" - for Google wallet permissions. **when not using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingGoogle+NativeLogin">native login</a>**. |
 | googlePlusExtraPermissions | NSString    | A comma delimited list of Google+/Google SignIn extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingGoogle+NativeLogin">native login</a>**. |
 | pendingRegistration        | NSNumber    | A Boolean value indicating whether the account should not be considered final until <a target="_blank" href="http://developers.gigya.com/display/GD/socialize.notifyRegistration+REST">socialize.notifyRegistration</a> is called. Default is `YES`. |
 | sessionExpiration          | NSNumber    | A time interval that defines the time in seconds that Gigya should keep the login session valid for the user. If this parameter is not specified, the session will be valid forever. |
 | forceAuthentication        | NSNumber    | A Boolean value indicating whether the user will be forced to provide his social network credentials during login, even if he is already connected to the social network. Default is `NO` |
 | temporaryAccount           | NSNumber    | A Boolean value indicating whether the account is temporary and is only accessible with the associated access token. This means that it is not possible to access the same account, and get the same Gigya UID again by using login. Default is `NO`. |
 | loginMode                  | NSString    | (optional) - The type of login being performed<ul><li>standard - (default) the user is logging into an existing account.</li><li>link - the user is linking a social network to an existing account. The account being used to login will become the primary account. When passing loginMode='link', regToken must also be passed to identify the account being linked. This is obtained from the initial login call response.</li><li>reAuth - the user is proving ownership of an existing account by logging into it. The loginID will be ignored and the password verified.</li></ul> |
 | regToken                   | NSString    | (optional) This parameter is required for completing the link accounts flow. Once the initial login has failed, call the login method with loginMode=link and the regToken returned from the initial call to complete the linking. For more information go to the <a target="_blank" href="http://developers.gigya.com/display/GD/Linking+Social+Accounts">social account linking guide</a>. |
 
 @param handler A completion handler that will be invoked when the login process is finished. The handler should have the signature `(GSUser *user, NSError *error)`. If the login was successful, the `error` parameter will be `nil`. Otherwise, you can check the `error.code` (see `GSErrorCode`) or `error.userInfo` to learn why it failed.
 */
+ (void)loginToProvider:(NSString * _Nonnull)provider
             parameters:(NSDictionary * _Nullable)parameters
      completionHandler:(GSUserInfoHandler _Nullable)handler;
+ (void)showLoginDialogOver:(UIViewController *)viewController
                   provider:(NSString *)provider
                 parameters:(NSDictionary *)parameters
          completionHandler:(GSUserInfoHandler)handler __attribute((deprecated("Use loginToProvider:parameters:completionHandler: instead")));

/*!
 Logs in the user with the specified provider.
 
 If the provider supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used instead of fast-app-switch.
 Calling this method when the user is already logged in will result in an exception.
 
 @param provider The provider's name.
 @param parameters A dictionary of optional login parameters. May include the following values:
 
 | Name                       | Type        | Description                                                                         |
 |----------------------------|-------------|-------------------------------------------------------------------------------------|
 | cid                        | NSString    | A string of maximum 100 characters length. This string will be associated with each transaction and will later appear on reports generated by Gigya, in the "Context ID" combo box. The cid allows you to associate the report information with your own internal data. The "Context ID" combo box lets you filter the report data by application context. |
 | facebookReadPermissions    | NSString    | A comma delimited list of Facebook extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. Please refer to Facebook's <a target="_blank" href="https://developers.facebook.com/docs/reference/login/#permissions">permissions</a> documentation for the complete list of read permissions. Note: you should only include read permissions, otherwise Facebook will fail the login. |
 | facebookLoginBehavior      | NSNumber    | A <a target="_blank" href="https://developers.facebook.com/docs/reference/ios/current/class/FBSDKLoginManager/#FBSDKLoginBehavior enum">FBSDKLoginBehavior</a> value determining the Facebook SDK login behavior. |
 | googleExtraPermissions     | NSString    | This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. The supported values are: "wallet" - for Google wallet permissions **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingGoogle+NativeLogin">native login</a>**. |
 | googlePlusExtraPermissions | NSString    | A comma delimited list of Google+ extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingGoogle+NativeLogin">native login</a>**. |
 | pendingRegistration        | NSNumber    | A Boolean value indicating whether the account should not be considered final until <a target="_blank" href="http://developers.gigya.com/display/GD/socialize.notifyRegistration+REST">socialize.notifyRegistration</a> is called. Default is `YES`. |
 | sessionExpiration          | NSNumber    | A time interval that defines the time in seconds that Gigya should keep the login session valid for the user. If this parameter is not specified, the session will be valid forever. |
 | forceAuthentication        | NSNumber    | A Boolean value indicating whether the user will be forced to provide his social network credentials during login, even if he is already connected to the social network. Default is `NO` |
 | temporaryAccount           | NSNumber    | A Boolean value indicating whether the account is temporary and is only accessible with the associated access token. This means that it is not possible to access the same account, and get the same Gigya UID again by using login. Default is `NO`. |
 | loginMode                  | NSString    | (optional) - The type of login being performed<ul><li>standard - (default) the user is logging into an existing account.</li><li>link - the user is linking a social network to an existing account. The account being used to login will become the primary account. When passing loginMode='link', regToken must also be passed to identify the account being linked. This is obtained from the initial login call response.</li><li>reAuth - the user is proving ownership of an existing account by logging into it. The loginID will be ignored and the password verified.</li></ul> |
 | regToken                   | NSString    | (optional) This parameter is required for completing the link accounts flow. Once the initial login has failed, call the login method with loginMode=link and the regToken returned from the initial call to complete the linking. For more information go to the <a target="_blank" href="http://developers.gigya.com/display/GD/Linking+Social+Accounts">social account linking guide</a>. |
 
 @param viewController A view controller on which to display the login dialog (used only if the `GigyaLoginDontLeaveApp` setting is enabled).
 @param handler A completion handler that will be invoked when the login process is finished. The handler should have the signature `(GSUser *user, NSError *error)`. If the login was successful, the `error` parameter will be `nil`. Otherwise, you can check the `error.code` (see `GSErrorCode`) or `error.userInfo` to learn why it failed.
 */
+ (void)loginToProvider:(NSString * _Nonnull)provider
             parameters:(NSDictionary * _Nullable)parameters
                   over:(UIViewController * _Nullable)viewController
      completionHandler:(GSUserInfoHandler _Nullable)handler;

/*!
 Displays a provider selection dialog, allowing the user to login to any of the supported providers.
 
 If the user selects a provider that supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used seamlessly from the provider selection view.
 Calling this method when the user is already logged in will result in an exception.
 
 @param viewController The ViewController on which to present the dialog.
 */
+ (void)showLoginProvidersDialogOver:(UIViewController *)viewController;

/*!
 Displays a provider selection popover, allowing the user to login to any of the supported providers.
 
 Supported in iPad only. Using this method in an iPhone/iPod will result in an exception.
 
 If the user selects a provider that supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used seamlessly from the provider selection view.
 Calling this method when the user is already logged in will result in an exception.
 
 @param view The view at which to anchor the popover window.
 */
+ (void)showLoginProvidersPopoverFrom:(UIView *)view;

/*!
 Displays a provider selection dialog, allowing the user to login to any of the specified providers.
 
 If the user selects a provider that supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used seamlessly from the provider selection view.
 Calling this method when the user is already logged in will result in an exception.
 
 @param viewController The ViewController on which to present the dialog.
 @param providers An array of provider name strings. If unspecified, all possible providers will be displayed.
 @param parameters A dictionary of optional login parameters. May include the following values:
 
 | Name                       | Type        | Description                                                                         |
 |----------------------------|-------------|-------------------------------------------------------------------------------------|
 | disabledProviders          | NSString    | A comma delimited list of providers that should not be displayed in the provider selection screen. |
 | captionText                | NSString    | Sets the navigation bar title for the provider selection screen. Default is `Login`. |
 | cid                        | NSString    | A string of maximum 100 characters length. This string will be associated with each transaction and will later appear on reports generated by Gigya, in the "Context ID" combo box. The cid allows you to associate the report information with your own internal data. The "Context ID" combo box lets you filter the report data by application context. |
 | facebookReadPermissions    | NSString    | A comma delimited list of Facebook extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. Please refer to Facebook's <a target="_blank" href="https://developers.facebook.com/docs/reference/login/#permissions">permissions</a> documentation for the complete list of read permissions. Note: you should only include read permissions, otherwise Facebook will fail the login. |
 | facebookLoginBehavior      | NSNumber    | A <a target="_blank" href="https://developers.facebook.com/docs/reference/ios/current/class/FBSDKLoginManager/#FBSDKLoginBehavior enum">FBSDKLoginBehavior</a> value determining the Facebook SDK login behavior. |
 | googleExtraPermissions     | NSString    | This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. The supported values are: "wallet" - for Google wallet permissions **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingGoogle+NativeLogin">native login</a>**. |
 | googlePlusExtraPermissions | NSString    | A comma delimited list of Google+ extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. |
 | pendingRegistration        | NSNumber    | A Boolean value indicating whether the account should not be considered final until <a target="_blank" href="http://developers.gigya.com/display/GD/socialize.notifyRegistration+REST">socialize.notifyRegistration</a> is called. Default is `YES`. |
 | sessionExpiration          | NSNumber    | A time interval that defines the time in seconds that Gigya should keep the login session valid for the user. If this parameter is not specified, the session will be valid forever. |
 | forceAuthentication        | NSNumber    | A Boolean value indicating whether the user will be forced to provide his social network credentials during login, even if he is already connected to the social network. Default is `NO` |
 | temporaryAccount           | NSNumber    | A Boolean value indicating whether the account is temporary and is only accessible with the associated access token. This means that it is not possible to access the same account, and get the same Gigya UID again by using login. Default is `NO`. |
 | loginMode                  | NSString    | (optional) - The type of login being performed<ul><li>standard - (default) the user is logging into an existing account.</li><li>link - the user is linking a social network to an existing account. The account being used to login will become the primary account. When passing loginMode='link', regToken must also be passed to identify the account being linked. This is obtained from the initial login call response.</li><li>reAuth - the user is proving ownership of an existing account by logging into it. The loginID will be ignored and the password verified.</li></ul> |
 | regToken                   | NSString    | (optional) This parameter is required for completing the link accounts flow. Once the initial login has failed, call the login method with loginMode=link and the regToken returned from the initial call to complete the linking. For more information go to the <a target="_blank" href="http://developers.gigya.com/display/GD/Linking+Social+Accounts">social account linking guide</a>. |
 
 @param handler A completion handler that will be invoked when the login process is finished. The handler should have the signature `(GSUser *user, NSError *error)`. If the login was successful, the `error` parameter will be `nil`. Otherwise, you can check the `error.code` (see `GSErrorCode`) or `error.userInfo` to learn why it failed.
 */
+ (void)showLoginProvidersDialogOver:(UIViewController *)viewController
                           providers:(NSArray *)providers
                          parameters:(NSDictionary *)parameters
                   completionHandler:(GSUserInfoHandler)handler;

/*!
 Displays a provider selection popover, allowing the user to login to any of the specified providers.

 Supported in iPad only. Using this method in an iPhone/iPod will result in an exception.
 
 If the user selects a provider that supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used seamlessly from the provider selection view.
 Calling this method when the user is already logged in will result in an exception.
 
 @param view The view at which to anchor the popover window.
 @param providers An array of provider name strings. If unspecified, all possible providers will be displayed.
 @param parameters A dictionary of optional login parameters. May include the following values:
 
 | Name                       | Type        | Description                                                                         |
 |----------------------------|-------------|-------------------------------------------------------------------------------------|
 | disabledProviders          | NSString    | A comma delimited list of providers that should not be displayed in the provider selection screen. |
 | captionText                | NSString    | Sets the navigation bar title for the provider selection screen. Default is `Login`. |
 | cid                        | NSString    | A string of maximum 100 characters length. This string will be associated with each transaction and will later appear on reports generated by Gigya, in the "Context ID" combo box. The cid allows you to associate the report information with your own internal data. The "Context ID" combo box lets you filter the report data by application context. |
 | facebookReadPermissions    | NSString    | A comma delimited list of Facebook extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. Please refer to Facebook's <a target="_blank" href="https://developers.facebook.com/docs/reference/login/#permissions">permissions</a> documentation for the complete list of read permissions. Note: you should only include read permissions, otherwise Facebook will fail the login. |
 | facebookLoginBehavior      | NSNumber    | A <a target="_blank" href="https://developers.facebook.com/docs/reference/ios/current/class/FBSDKLoginManager/#FBSDKLoginBehavior enum">FBSDKLoginBehavior</a> value determining the Facebook SDK login behavior. |
 | googleExtraPermissions     | NSString    | This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. The supported values are: "wallet" - for Google wallet permissions **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingGoogle+NativeLogin">native login</a>**. |
 | googlePlusExtraPermissions | NSString    | A comma delimited list of Google+ extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. |
 | pendingRegistration        | NSNumber    | A Boolean value indicating whether the account should not be considered final until <a target="_blank" href="http://developers.gigya.com/display/GD/socialize.notifyRegistration+REST">socialize.notifyRegistration</a> is called. Default is `YES`. |
 | sessionExpiration          | NSNumber    | A time interval that defines the time in seconds that Gigya should keep the login session valid for the user. If this parameter is not specified, the session will be valid forever. |
 | forceAuthentication        | NSNumber    | A Boolean value indicating whether the user will be forced to provide his social network credentials during login, even if he is already connected to the social network. Default is `NO` |
 | temporaryAccount           | NSNumber    | A Boolean value indicating whether the account is temporary and is only accessible with the associated access token. This means that it is not possible to access the same account, and get the same Gigya UID again by using login. Default is `NO`. |
 | loginMode                  | NSString    | (optional) - The type of login being performed<ul><li>standard - (default) the user is logging into an existing account.</li><li>link - the user is linking a social network to an existing account. The account being used to login will become the primary account. When passing loginMode='link', regToken must also be passed to identify the account being linked. This is obtained from the initial login call response.</li><li>reAuth - the user is proving ownership of an existing account by logging into it. The loginID will be ignored and the password verified.</li></ul> |
 | regToken                   | NSString    | (optional) This parameter is required for completing the link accounts flow. Once the initial login has failed, call the login method with loginMode=link and the regToken returned from the initial call to complete the linking. For more information go to the <a target="_blank" href="http://developers.gigya.com/display/GD/Linking+Social+Accounts">social account linking guide</a>. |
 
 @param handler A completion handler that will be invoked when the login process is finished. The handler should have the signature `(GSUser *user, NSError *error)`. If the login was successful, the `error` parameter will be `nil`. Otherwise, you can check the `error.code` (see `GSErrorCode`) or `error.userInfo` to learn why it failed.
 */
+ (void)showLoginProvidersPopoverFrom:(UIView *)view
                            providers:(NSArray *)providers
                           parameters:(NSDictionary *)parameters
                    completionHandler:(GSUserInfoHandler)handler;

/** @name Logging Out */

/**
 Logs out from Gigya and clears the saved session.
 
 If the user has logged in to Facebook or Google+ via <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, this method will log out from the corresponding native SDKs as well.
 */
+ (void)logout;

/*!
 Logs out from Gigya and clears the saved session.

 If the user has logged in to Facebook or Google+ via <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, this method will log out from the corresponding native SDKs as well.
 
 @param handler A completion handler that will be invoked when the logout process is finished. The handler should have the signature `(GSResponse *response, NSError *error)`. If the call to socialize.logout was successful, the `error` parameter will be `nil`. Otherwise, you can check the `error.code` (see `GSErrorCode`) or `error.userInfo` to learn why it failed.
 */
+ (void)logoutWithCompletionHandler:(GSResponseHandler)handler;

/** @name Adding a Connection to a Logged In User */

/*!
 Logs in the user with the specified provider. When the user completes the login process, Gigya will associate the connection with the user's account.
 
 If the provider supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used instead of fast-app-switch.
 Calling this method when the user isn't logged in (there is no Gigya session) will result in an exception.
 
 @param provider The provider's name.
 */
+ (void)addConnectionToProvider:(NSString *)provider;
+ (void)showAddConnectionDialogOver:(UIViewController *)viewController
                           provider:(NSString *)provider __attribute((deprecated("Use addConnectionToProvider: instead")));


/*!
 Logs in the user with the specified provider. When the user completes the login process, Gigya will associate the connection with the user's account.
 
 If the provider supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used instead of fast-app-switch.
 Calling this method when the user isn't logged in (there is no Gigya session) will result in an exception.
 
 @param provider The provider's name.
 @param parameters A dictionary of optional connection parameters. May include the following values:
 
 | Name                       | Type        | Description                                                                         |
 |----------------------------|-------------|-------------------------------------------------------------------------------------|
 | cid                        | NSString    | A string of maximum 100 characters length. This string will be associated with each transaction and will later appear on reports generated by Gigya, in the "Context ID" combo box. The cid allows you to associate the report information with your own internal data. The "Context ID" combo box lets you filter the report data by application context. |
 | facebookReadPermissions    | NSString    | A comma delimited list of Facebook extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. Please refer to Facebook's <a target="_blank" href="https://developers.facebook.com/docs/reference/login/#permissions">permissions</a> documentation for the complete list of read permissions. Note: you should only include read permissions, otherwise Facebook will fail the login. |
 | facebookLoginBehavior      | NSNumber    | A <a target="_blank" href="https://developers.facebook.com/docs/reference/ios/current/class/FBSDKLoginManager/#FBSDKLoginBehavior enum">FBSDKLoginBehavior</a> value determining the Facebook SDK login behavior. |
 | googleExtraPermissions     | NSString    | This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. The supported values are: "wallet" - for Google wallet permissions **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingGoogle+NativeLogin">native login</a>**. |
 | googlePlusExtraPermissions | NSString    | A comma delimited list of Google+ extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. |
 
 @param handler A completion handler that will be invoked when adding the connection is finished. The handler should have the signature `(GSUser *user, NSError *error)`. If the connection was added successfully, the `error` parameter will be `nil`. Otherwise, you can check the `error.code` (see `GSErrorCode`) or `error.userInfo` to learn why it failed.
 */
+ (void)addConnectionToProvider:(NSString *)provider
                     parameters:(NSDictionary * _Nullable)parameters
              completionHandler:(nullable GSUserInfoHandler)handler;
+ (void)showAddConnectionDialogOver:(UIViewController *)viewController
                           provider:(NSString *)provider
                         parameters:(NSDictionary * _Nullable)parameters
                  completionHandler:(nullable GSUserInfoHandler)handler __attribute((deprecated("Use addConnectionToProvider:parameters:completionHandler: instead")));

/*!
 Logs in the user with the specified provider. When the user completes the login process, Gigya will associate the connection with the user's account.
 
 If the provider supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used instead of fast-app-switch.
 Calling this method when the user isn't logged in (there is no Gigya session) will result in an exception.
 
 @param provider The provider's name.
 @param parameters A dictionary of optional connection parameters. May include the following values:
 
 | Name                       | Type        | Description                                                                         |
 |----------------------------|-------------|-------------------------------------------------------------------------------------|
 | cid                        | NSString    | A string of maximum 100 characters length. This string will be associated with each transaction and will later appear on reports generated by Gigya, in the "Context ID" combo box. The cid allows you to associate the report information with your own internal data. The "Context ID" combo box lets you filter the report data by application context. |
 | facebookReadPermissions    | NSString    | A comma delimited list of Facebook extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. Please refer to Facebook's <a target="_blank" href="https://developers.facebook.com/docs/reference/login/#permissions">permissions</a> documentation for the complete list of read permissions. Note: you should only include read permissions, otherwise Facebook will fail the login. |
 | facebookLoginBehavior      | NSNumber    | A <a target="_blank" href="https://developers.facebook.com/docs/reference/ios/current/class/FBSDKLoginManager/#FBSDKLoginBehavior enum">FBSDKLoginBehavior</a> value determining the Facebook SDK login behavior. |
 | googleExtraPermissions     | NSString    | This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. The supported values are: "wallet" - for Google wallet permissions **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingGoogle+NativeLogin">native login</a>**. |
 | googlePlusExtraPermissions | NSString    | A comma delimited list of Google+ extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. |
 
  @param viewController A view controller on which to display the login dialog (used only if the `GigyaLoginDontLeaveApp` setting is enabled).
 @param handler A completion handler that will be invoked when adding the connection is finished. The handler should have the signature `(GSUser *user, NSError *error)`. If the connection was added successfully, the `error` parameter will be `nil`. Otherwise, you can check the `error.code` (see `GSErrorCode`) or `error.userInfo` to learn why it failed.
 */
+ (void)addConnectionToProvider:(NSString *)provider
                     parameters:(NSDictionary * _Nullable)parameters
                           over:(UIViewController * _Nullable)viewController
              completionHandler:(nullable GSUserInfoHandler)handler;

/*!
 Displays a provider selection dialog, allowing the user to connect to any of the supported providers. When the user completes the login process, Gigya will associate the connection with the user's account.
 
 If the user selects a provider that supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used seamlessly from the provider selection view.
 Calling this method when the user isn't logged in (there is no Gigya session) will result in an exception.
 
 @param viewController The ViewController on which to present the dialog.
 */
+ (void)showAddConnectionProvidersDialogOver:(UIViewController *)viewController;

/*!
 Displays a provider selection popover, allowing the user to connect to any of the supported providers. When the user completes the login process, Gigya will associate the connection with the user's account.

 Supported in iPad only. Using this method in an iPhone/iPod will result in an exception.
 
 If the user selects a provider that supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used seamlessly from the provider selection view.
 Calling this method when the user is already logged in will result in an exception.
 
 @param view The view at which to anchor the popover window.
 */
+ (void)showAddConnectionProvidersPopoverFrom:(UIView *)view;

/*!
 Displays a provider selection dialog, allowing the user to connect to any of the specified providers. When the user completes the login process, Gigya will associate the connection with the user's account.
 
 If the user selects a provider that supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used seamlessly from the provider selection view.
 Calling this method when the user isn't logged in (there is no Gigya session) will result in an exception.
 
 @param viewController The ViewController on which to present the dialog.
 @param providers An array of provider name strings. If unspecified, all possible providers will be displayed.
 @param parameters A dictionary of optional connection parameters. May include the following values:
 
 | Name                       | Type        | Description                                                                         |
 |----------------------------|-------------|-------------------------------------------------------------------------------------|
 | disabledProviders          | NSString    | A comma delimited list of providers that should not be displayed in the provider selection screen. |
 | captionText                | NSString    | Sets the navigation bar title for the provider selection screen. Default is `Add Connection`. |
 | cid                        | NSString    | A string of maximum 100 characters length. This string will be associated with each transaction and will later appear on reports generated by Gigya, in the "Context ID" combo box. The cid allows you to associate the report information with your own internal data. The "Context ID" combo box lets you filter the report data by application context. |
 | facebookReadPermissions    | NSString    | A comma delimited list of Facebook extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. Please refer to Facebook's <a target="_blank" href="https://developers.facebook.com/docs/reference/login/#permissions">permissions</a> documentation for the complete list of read permissions. Note: you should only include read permissions, otherwise Facebook will fail the login. |
 | facebookLoginBehavior      | NSNumber    | A <a target="_blank" href="https://developers.facebook.com/docs/reference/ios/current/class/FBSDKLoginManager/#FBSDKLoginBehavior enum">FBSDKLoginBehavior</a> value determining the Facebook SDK login behavior. |
 | googleExtraPermissions     | NSString    | This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. The supported values are: "wallet" - for Google wallet permissions **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingGoogle+NativeLogin">native login</a>**. |
 | googlePlusExtraPermissions | NSString    | A comma delimited list of Google+ extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. |
 
 @param handler A completion handler that will be invoked when the login process is finished. The handler should have the signature `(GSUser *user, NSError *error)`. If the login was successful, the `error` parameter will be `nil`. Otherwise, you can check the `error.code` (see `GSErrorCode`) or `error.userInfo` to learn why it failed.
 */
+ (void)showAddConnectionProvidersDialogOver:(UIViewController *)viewController
                                   providers:(NSArray *)providers
                                  parameters:(NSDictionary *)parameters
                           completionHandler:(GSUserInfoHandler)handler;

/*!
 Displays a provider selection popover, allowing the user to connect to any of the specified providers. When the user completes the login process, Gigya will associate the connection with the user's account.
 
 Supported in iPad only. Using this method in an iPhone/iPod will result in an exception.
 
 If the user selects a provider that supports <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a>, it will be used seamlessly from the provider selection view.
 Calling this method when the user isn't logged in (there is no Gigya session) will result in an exception.
 
 @param view The view at which to anchor the popover window.
 @param providers An array of provider name strings. If unspecified, all possible providers will be displayed.
 @param parameters A dictionary of optional connection parameters. May include the following values:
 
 | Name                       | Type        | Description                                                                         |
 |----------------------------|-------------|-------------------------------------------------------------------------------------|
 | disabledProviders          | NSString    | A comma delimited list of providers that should not be displayed in the provider selection screen. |
 | captionText                | NSString    | Sets the navigation bar title for the provider selection screen. Default is `Add Connection`. |
 | cid                        | NSString    | A string of maximum 100 characters length. This string will be associated with each transaction and will later appear on reports generated by Gigya, in the "Context ID" combo box. The cid allows you to associate the report information with your own internal data. The "Context ID" combo box lets you filter the report data by application context. |
 | facebookReadPermissions    | NSString    | A comma delimited list of Facebook extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. Please refer to Facebook's <a target="_blank" href="https://developers.facebook.com/docs/reference/login/#permissions">permissions</a> documentation for the complete list of read permissions. Note: you should only include read permissions, otherwise Facebook will fail the login. |
 | facebookLoginBehavior      | NSNumber    | A <a target="_blank" href="https://developers.facebook.com/docs/reference/ios/current/class/FBSDKLoginManager/#FBSDKLoginBehavior enum">FBSDKLoginBehavior</a> value determining the Facebook SDK login behavior. |
 | googleExtraPermissions     | NSString    | This parameter gives the possibility to request extended permissions in addition to the permissions that Gigya is already requesting. The supported values are: "wallet" - for Google wallet permissions **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingGoogle+NativeLogin">native login</a>**. |
 | googlePlusExtraPermissions | NSString    | A comma delimited list of Google+ extended permissions to request from the user **when using <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">native login</a>**. |
 
 @param handler A completion handler that will be invoked when the login process is finished. The handler should have the signature `(GSUser *user, NSError *error)`. If the login was successful, the `error` parameter will be `nil`. Otherwise, you can check the `error.code` (see `GSErrorCode`) or `error.userInfo` to learn why it failed.
 */
+ (void)showAddConnectionProvidersPopoverFrom:(UIView *)view
                                    providers:(NSArray *)providers
                                   parameters:(NSDictionary *)parameters
                            completionHandler:(GSUserInfoHandler)handler;

/** @name Removing a Connection from a Logged In User */

/**
 Removes the connection to the specified provider from the logged in user.

 If the provider is Facebook or Google+, and <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a> was used, this method will log out from the corresponding native SDK as well.
 Calling this method when the user isn't logged in (there is no Gigya session) will result in an exception.
 
 @param provider A provider name string.
 */
+ (void)removeConnectionToProvider:(NSString *)provider;

/*!
 Removes the connection to the specified provider from the logged in user.
 
 If the provider is Facebook or Google+, and <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-c.AdditionalProviderConfiguration">native login</a> was used, this method will log out from the corresponding native SDK as well.
 Calling this method when the user isn't logged in (there is no Gigya session) will result in an exception.

 @param provider A provider name string.
 @param handler A completion handler that will be invoked when the removal process is finished. The handler should have the signature `(GSUser *user, NSError *error)`. If the call to socialize.removeConnection was successful, the `error` parameter will be `nil`. Otherwise, you can check the `error.code` (see `GSErrorCode`) or `error.userInfo` to learn why it failed.
 */
+ (void)removeConnectionToProvider:(NSString *)provider
                 completionHandler:(GSUserInfoHandler)handler;

/** @name Displaying Gigya Plugins */

/*!
 Uses <GSPluginView> to render Gigya <a target="_blank" href="http://developers.gigya.com/display/GD/Plugins">JS Plugins</a> and display them modally.
 
 To set the view controller's navigation title, pass the desired title as the `captionText` parameter.
 
 @param viewController The ViewController on which to present the dialog.
 @param plugin A plugin name of a supported plugin, see <GSPluginView> for a list.
 @param parameters The parameters passed to the plugin.
 */
+ (void)showPluginDialogOver:(UIViewController * _Nullable)viewController
                      plugin:(NSString *)plugin
                  parameters:(NSDictionary *)parameters;

/*!
 Uses <GSPluginView> to render Gigya <a target="_blank" href="http://developers.gigya.com/display/GD/Plugins">JS Plugins</a> and display them modally.
 
 @param viewController The ViewController on which to present the dialog.
 @param plugin A plugin name of a supported plugin, see <GSPluginView> for a list.
 @param parameters The parameters passed to the plugin.
 @param handler A handler that will be invoked when the dialog is dismissed. The handler should have the signature `(BOOL closedByUser, NSError *error)`.
 */
+ (void)showPluginDialogOver:(UIViewController * _Nullable)viewController
                      plugin:(NSString *)plugin
                  parameters:(NSDictionary *)parameters
           completionHandler:(nullable GSPluginCompletionHandler)handler;

/*!
 Uses <GSPluginView> to render Gigya <a target="_blank" href="http://developers.gigya.com/display/GD/Plugins">JS Plugins</a> and display them modally.
 
 @param viewController The ViewController on which to present the dialog.
 @param plugin A plugin name of a supported plugin, see <GSPluginView> for a list.
 @param parameters The parameters passed to the plugin.
 @param handler A handler that will be invoked when the dialog is dismissed. The handler should have the signature `(BOOL closedByUser, NSError *error)`.
 @param delegate A delegate object that will receive plugin events.
 @see GSPluginView, GSPluginViewDelegate
 */
+ (void)showPluginDialogOver:(UIViewController * _Nullable)viewController
                      plugin:(NSString *)plugin
                  parameters:(NSDictionary *)parameters
           completionHandler:(nullable GSPluginCompletionHandler)handler
                    delegate:(nullable id<GSPluginViewDelegate>)delegate;

/** @name Requesting Additional Facebook Permissions */

/*!
 Asks the user for new Facebook publish permissions. This method must be used to receive publish permissions, and can be used again if the user has previously declined the wanted permissions.
 This method works only with <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">Facebook native login</a>, and must be called after the user logged in.
 
 @param permissions A comma delimited list of Facebook publish permissions to request from the user. Please refer to Facebook's <a target="_blank" href="https://developers.facebook.com/docs/reference/login/#permissions">documentation</a> for a complete list of possible values.
 @param viewController The view controller to present from. If nil, the topmost view controller will be automatically determined as best as possible.
 @param handler A completion handler that will be invoked when the process if finished. The handler should have the signature `(BOOL granted, NSError *error, NSArray *declinedPermissions)`. If the `granted` parameter is `NO`, you can check the `error` parameter to learn why it failed. The `declinedPermissions` array, if exists, holds the permissions the user has declined in the process. These permissions can be requested again later using this method.
 */
+ (void)requestNewFacebookPublishPermissions:(NSString *)permissions
							  viewController:(UIViewController * _Nullable)viewController
							 responseHandler:(GSPermissionRequestResultHandler)handler;

/*!
 Asks the user for new Facebook read permissions. This method must be used if the user has previously declined the wanted permissions. 
 This method works only with <a target="_blank" href="http://developers.gigya.com/display/GD/iOS#iOS-AddingFacebookNativeLogin">Facebook native login</a>, and must be called after the user logged in.
 
 @param permissions A comma delimited list of Facebook publish permissions to request from the user. Please refer to Facebook's <a target="_blank" href="https://developers.facebook.com/docs/reference/login/#permissions">documentation</a> for a complete list of possible values.
 @param viewController The view controller to present from. If nil, the topmost view controller will be automatically determined as best as possible.
 @param handler A completion handler that will be invoked when the process if finished. The handler should have the signature `(BOOL granted, NSError *error, NSArray *declinedPermissions)`. If the `granted` parameter is `NO`, you can check the `error` parameter to learn why it failed. The `declinedPermissions` array, if exists, holds the permissions the user has declined in the process. These permissions can be requested again later using this method.
 */
+ (void)requestNewFacebookReadPermissions:(NSString *)permissions
						   viewController:(UIViewController * _Nullable)viewController
						  responseHandler:(GSPermissionRequestResultHandler)handler;

/** @name Handling Application Events */

/*!
 Handles URLs being opened by your AppDelegate. This method must be called and returned from your AppDelegate's `application:openURL:options:` method.
 
 @param url The url parameter provided by the AppDelegate method.
 @param app The app parameter provided by the AppDelegate method.
 @param options The options parameter provided by the AppDelegate method.
 
 @returns Returns `YES` if URL was handled.
 */
+ (BOOL)handleOpenURL:(NSURL *)url
                  app:(UIApplication *)app
              options:(NSDictionary<NSString *, id> *)options;

/*!
 Handles URLs being opened by your AppDelegate. This method must be called and returned from your AppDelegate's `application:handleOpenURL:` or `application:openURL:sourceApplication:annotation:` method.
 
 @param url The url parameter provided by the AppDelegate method.
 @param application The application parameter provided by the AppDelegate method.
 @param sourceApplication The sourceApplication parameter provided by the AppDelegate method, or `nil` if not present.
 @param annotation The annotation parameter provided by the AppDelegate method, or `nil` if not present.
 
 @returns Returns `YES` if URL was handled.
 */
+ (BOOL)handleOpenURL:(NSURL *)url application:(UIApplication *)application sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

/*!
 Handles the application returning to active state after jumping to Safari for login. This method must be called in your AppDelegate's `applicationDidBecomeActive` method.
 */
+ (void)handleDidBecomeActive;

/** @name Global SDK Settings */

/*!
 Retrieves whether HTTPS will be used for all requests.
 */
+ (BOOL)useHTTPS;

/*!
 Controls whether HTTPS will be used for all requests. The default is `YES`.
 
 @param useHTTPS use HTTPS
 */
+ (void)setUseHTTPS:(BOOL)useHTTPS;

/*!
 Retrieves whether status bar network activity indicator will be shown upon sending `GSRequest`s.
 */
+ (BOOL)networkActivityIndicatorEnabled;

/*!
 Controls whether status bar network activity indicator will be shown upon sending `GSRequest`s. The default is `YES`.
 
 @param networkActivityIndicatorEnabled network activity indicator enabled
 */
+ (void)setNetworkActivityIndicatorEnabled:(BOOL)networkActivityIndicatorEnabled;

/*!
 Retrieves the time in seconds before a request times out.
 */
+ (NSTimeInterval)requestTimeout;

/*!
 Controls the time in seconds before a request times out. The default is 30 seconds.
 
 @param requestTimeout request timeout
 */
+ (void)setRequestTimeout:(NSTimeInterval)requestTimeout;

/*!
 Retrieves whether login operations are restricted to the app context only
 
 @param dontLeaveApp don't leave app when user logins
 */
+ (BOOL)dontLeaveApp;

/*!
 Controls whether login operations are restricted to the app context only. The default is `YES`.
 
 @param dontLeaveApp don't leave app when user logins
 */
+ (void)setDontLeaveApp:(BOOL)dontLeaveApp;

+ (BOOL)__debugOptionEnableTestNetworks;

+ (void)__setDebugOptionEnableTestNetworks:(BOOL)debugOptionEnableTestNetworks;

NS_ASSUME_NONNULL_END
@end



