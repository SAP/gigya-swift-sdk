#import <Foundation/Foundation.h>

/**
 This protocol declares methods that can be implemented by your application to handle changes in the Gigya session. All methods are optional.
 
 Changes include:
 
 - User was logged in
 - Added a connection to a user
 - Removed a connection from a user
 - User was logged out
 - The active session was set manually (by calling `[Gigya setSession:]`)
 */

__attribute((deprecated("Use [Gigya setSocializeDelegate:] with a GSSocializeDelegate instead")))
@protocol GSSessionDelegate <NSObject>

@optional

/*!
 Invoked after a user has logged in successfully.
 
 @param user The logged in user object.
 @see Gigya
 */
- (void)userDidLogin:(GSUser *)user;

/*!
 Invoked after a user has logged out.
 
 @see Gigya
 */
- (void)userDidLogout;

/*!
 Invoked after the user info has been updated.

 The user info is updated after:
 
 - Logging in
 - Adding/removing a connection
 - Other API calls that return an updated Gigya session (`sessionInfo`).

 @param user The updated user object.
 @see Gigya
 */
- (void)userInfoDidChange:(GSUser *)user;

@end
