#import <Foundation/Foundation.h>

/**
 This protocol defines methods that can be implemented by your application to handle Gigya Socialize events. All methods are optional.
 */
@protocol GSSocializeDelegate <NSObject>

@optional

/*!
 Invoked after a user has logged in successfully.
 
 @param user The logged in user object.
 @see Gigya, GSUser
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
 @see Gigya, GSUser
 */
- (void)userInfoDidChange:(GSUser *)user;

@end
