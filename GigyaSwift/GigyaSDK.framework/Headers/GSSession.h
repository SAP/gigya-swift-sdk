#import <Foundation/Foundation.h>
#import "GSSessionInfo.h"

/**
 This class represents a Gigya session. It is created in the login process and persists between app launches, until cleared by `[Gigya logout]`.
 
 Usually there is no need to create a `GSSession` instance manually. If you choose to do so, call `[Gigya setSession:]` in order to make it the active session.
 */
@interface GSSession : NSObject <NSCoding>

/** @name Accessing Session Information */

/*!
 The session authentication token.
 */
@property (nonatomic, copy) NSString *token;

/*!
 The session secret, used to <a target="_blank" href="http://developers.gigya.com/display/GD/REST+API+with+Gigya's+Authorization+Method#RESTAPIwithGigya'sAuthorizationMethod-SigningtheRequest">sign requests</a>.
 */
@property (nonatomic, copy) NSString *secret;

/*!
 The session information.
 */
@property (nonatomic, retain) GSSessionInfo *info;

/*!
 The provider used to login.
 */
@property (nonatomic, copy) NSString *lastLoginProvider;

/** @name Manually Creating a Session */

/*!
 Initializes a new `GSSession` instance with the given token and secret.
 
 @param token The session authentication token.
 @param secret The session secret.
 
 @returns A new session instance.
 */
- (GSSession *)initWithSessionToken:(NSString *)token
                             secret:(NSString *)secret;

/*!
 Initializes a new `GSSession` instance with the given token and secret.
 
 @param token The session authentication token.
 @param secret The session secret.
 @param expiration The session expiration date.
 @returns A new session instance.
 */
- (GSSession *)initWithSessionToken:(NSString *)token
                             secret:(NSString *)secret
                         expiration:(NSDate *)expiration;

/*!
 Initializes a new `GSSession` instance with the given token and secret.
 
 @param token The session authentication token.
 @param secret The session secret.
 @param expiresIn The session expiration date as string representation.
 @returns A new session instance.
 */
- (GSSession *)initWithSessionToken:(NSString *)token
                             secret:(NSString *)secret
                          expiresIn:(NSString *)expiresIn;

/*!
 Indicates whether the Gigya session is valid.
 */
- (BOOL)isValid;

@end
