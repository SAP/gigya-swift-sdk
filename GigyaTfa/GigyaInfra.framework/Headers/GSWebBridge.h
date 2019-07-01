#import "Gigya.h"

@class GSWebBridge;

/**
 This protocol defines methods that can be implemented to handle <GSWebBridge> events. All methods are optional.
 */
@protocol GSWebBridgeDelegate <NSObject>

@optional
/**
 Invoked before the web bridge begins a login process.
 
 @param webView A registered web view that has initiated the login.
 @param method A string specifying the login type - either `"login"` or `"addConnection"`.
 @param parameters A dictionary of the login request parameters.
 */
- (void)webView:(id)webView startedLoginForMethod:(NSString *)method parameters:(NSDictionary *)parameters;

/**
 Invoked after the login process is finished.
 
 @param webView A registered web view that has initiated the login.
 @param response A response object with the login result.
 */
- (void)webView:(id)webView finishedLoginWithResponse:(GSResponse *)response;

/**
  Invoked when a Gigya JavaScript SDK plugin fires a <a target="_blank" href="http://developers.gigya.com/display/GD/Events#Events-PluginEvents">custom event</a> inside the web view. (For example - commentUI's <a target="_blank" href="http://developers.gigya.com/display/GD/comments.showCommentsUI+JS#comments.showCommentsUIJS-onCommentSubmittedEventData">commentSubmitted</a>)
 
 @param webView A registered web view that contains the origin plugin.
 @param event The event object.
 @param containerID The ID of the HTML element that contains the plugin.
 */
- (void)webView:(id)webView receivedPluginEvent:(NSDictionary *)event fromPluginInContainer:(NSString *)containerID;

/**
 Invoked when a Gigya JavaScript SDK writes to log
 
 @param webView A registered web view that contains the log entry.
 @param logType The log entry type. possible values: debug, info, warn, error.
 @param logInfo The log entry info object. possible values: debug, info, warn, error.
 */
- (void)webView:(id)webView receivedJsLog:(NSString *)logType logInfo:(NSDictionary *)logInfo;
@end

/** `GSWebBridge` connects between the Gigya JavaScript SDK and the Gigya iOS SDK. 
 Any `UIWebView` can be registered to use the web bridge. Doing this gives the following benefits:
 
 - Session state will be synchronized. If the user is logged in and the session is active in the iOS SDK - he will be automatically logged in in the JS SDK.
 - Any API requests by the JS SDK will be routed through the iOS SDK, using the iOS SDK session.
 - Any login process invoked by the JS SDK will be handled by the iOS SDK, creating a seamless login experience - using Safari or the provider's native login.
 
 To register a web view, follow these steps:
 
 1. Call `registerWebView:delegate:` before the web view has started loading:
 
       [GSWebBridge registerWebView:webView delegate:self];
 
 2. Add the following code to your `UIWebViewDelegate` implementation:
    a. In the beginning of `webView:shouldStartLoadWithRequest:navigationType:`:
        
           if ([GSWebBridge handleRequest:request webView:webView]) {
             return NO;
           }
 
    b. In `webViewDidStartLoad:`:
            
           [GSWebBridge webViewDidStartLoad:webView];
 
 3. Unregister the web view when finished:
 
       [GSWebBridge unregisterWebView:webView];
 */
@interface GSWebBridge : NSObject

/** @name Registering a Web View */

/**
 Registers a web view to the web bridge. This method should be called before calling `UIWebView`'s `loadRequest:`.
 
 @param webView A web view.
 @param delegate A delegate to be notified with `GSWebBridge` events.
 @see GSWebBridgeDelegate
 */
+ (void)registerWebView:(id)webView delegate:(id<GSWebBridgeDelegate>)delegate;

/**
 Registers a web view to the web bridge. This method should be called before calling `UIWebView`'s `loadRequest:`.
 
 @param webView A web view.
 @param delegate A delegate to be notified with `GSWebBridge` events.
 @param settings A settings object that will be passed to the Javascript SDK.
 @see GSWebBridgeDelegate
 */
+ (void)registerWebView:(id)webView delegate:(id<GSWebBridgeDelegate>)delegate settings:(NSDictionary *)settings;

/**
 Unregisters a web view from the web bridge. This method must be called before the web view has been deallocated.
 
 @param webView A web view that has already registered using `registerWebView:delegate:`.
 */
+ (void)unregisterWebView:(id)webView;

/** @name Routing Requests to the Web Bridge */

/**
 Notifies the web bridge that a registered web view has started loading. Should be called in `UIWebViewDelegate`'s `webViewDidStartLoad:`.
 
 @param webView A web view that has already registered using `registerWebView:delegate:`.
 */
+ (void)webViewDidStartLoad:(id)webView;

/**
 Routes a request from a registered web view. Should be called in `UIWebViewDelegate`'s `webView:shouldStartLoadWithRequest:navigationType:`.
 
 @param request The request object as passed in `webView:shouldStartLoadWithRequest:navigationType:`.
 @param webView A web view that has already registered using `registerWebView:delegate:`.
 @return A Boolean value indicating whether the web bridge has handled the request.
 */
+ (BOOL)handleRequest:(NSURLRequest *)request webView:(id)webView;


@end
