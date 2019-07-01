#import <Foundation/Foundation.h>

@class GSResponse;
@class GSSession;

/*!
 Response handler
 
 @param response Response
 @param error Error
 */
typedef void(^ _Nullable GSResponseHandler)(GSResponse * _Nullable response, NSError * _Nullable error);

/** This class can be used to send requests to the <a target="_blank" href="http://developers.gigya.com/display/GD/REST+API">Gigya REST API</a>.
 
 Example:
 
    GSRequest *request = [GSRequest requestForMethod:@"socialize.getSessionInfo"];
    [request.parameters setObject:@"facebook" forKey:@"provider"];
    [request sendWithResponseHandler:^(GSResponse *response, NSError *error) {
        if (!error) {
            // Success! Use the response object.
        }
        else {
            // Check the error code according to the GSErrorCode enum, and handle it.
        }
    }];
 
 */
@interface GSRequest : NSObject

/** @name Creating a Request */

/*!
 Creates a `GSRequest` object for a given method.
 
 @param method The API method.
 @returns A new `GSRequest` object for the method.
 */
+ (GSRequest * _Nonnull)requestForMethod:(NSString * _Nonnull)method;

/*!
 Creates a `GSRequest` object for a given method and parameters.
 
 @param method The API method.
 @param parameters A dictionary of parameters to pass to the method.
 @returns A new `GSRequest` object for the method and parameters.
 */
+ (GSRequest * _Nonnull)requestForMethod:(NSString * _Nonnull)method parameters:(NSDictionary * _Nullable)parameters;

/*!
 The API method name.
 */
@property (nonatomic, copy) NSString * _Nonnull method;

/*!
 The paremeters for the API method.
 */
@property (nonatomic, strong) NSMutableDictionary * _Nullable parameters;

/*!
 Indicates whether HTTPS should be used. The default is `YES`. Overrides the global setting in [Gigya].
 */
@property (nonatomic) BOOL useHTTPS;
/*!
 Indicates the time in seconds before a request times out. Overrides the global setting in [Gigya].
 */
@property (nonatomic) NSTimeInterval requestTimeout;


/** @name Sending a Request */

/*!
 Sends the request asynchronously and calls the handler with the response.
 
 @param handler A response handler that will be invoked when the response arrives. The handler should have the signature `(GSResponse *response, NSError *error)`. If the request was successful, the `error` parameter will be `nil`. Otherwise you can check its value (see `GSErrorCode` enum for error codes) or `response` to learn why it failed.
 */
- (void)sendWithResponseHandler:(GSResponseHandler)handler;

/*!
 Cancels the request. The provided handler will not be invoked.
 */
- (void)cancel;

@property (nonatomic, strong) GSSession * _Nullable session;
@property (nonatomic, strong, readonly) NSString * _Nonnull requestID;
@property (nonatomic) BOOL includeAuthInfo;
@property (nonatomic, copy) NSString * _Nonnull source;

@end
