#import <Foundation/Foundation.h>

/**
 This protocol defines methods that can be implemented by your application to handle Gigya Accounts events. All methods are optional.
 */
@protocol GSAccountsDelegate <NSObject>

@optional

/*!
 Invoked after an account was logged in to successfully.
 
 @param account The logged in account object.
 @see Gigya
 */
- (void)accountDidLogin:(GSAccount *)account;

/*!
 Invoked after an account has been logged out from.
 
 @see Gigya
 */
- (void)accountDidLogout;

@end
