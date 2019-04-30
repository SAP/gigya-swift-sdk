#import "GSResponse.h"

/**
 This class represents Gigya account information, as returned from the <a target="_blank" href="http://developers.gigya.com/display/GD/accounts.getAccountInfo+REST">accounts.getAccountInfo</a> method in the <a target="_blank" href="http://developers.gigya.com/display/GD/REST+API">Gigya REST API</a>.
 
 `GSAccount` values can be accessed by keys (similiar to NSDictionary) and support subscripting syntax:
 
    // These two statements are equivalent
    NSString *uid = [account objectForKey:@"UID"];
    NSString *uid = account[@"UID"];
 
 `GSAccount` also providers properties for easy access to the most commonly used values.
 */
@interface GSAccount : GSResponse

/** @name Basic Account Information */

/*!
 The unique ID of the user.
 */
@property (weak, nonatomic, readonly) NSString *UID;

/*!
 The user's profile information as described in the <a target="_blank" href="http://developers.gigya.com/display/GD/Profile+JS">Profile</a> object.
 */
@property (weak, nonatomic, readonly) NSDictionary *profile;

/*!
 Custom data that was stored for the user.
 */
@property (weak, nonatomic, readonly) NSDictionary *data;

/*!
 The user's nickname, this may be either the nickname provided by the connected provider or a concatenation of the first and last names.
 */
@property (weak, nonatomic, readonly) NSString *nickname;

/*!
 The user's first name.
 */
@property (weak, nonatomic, readonly) NSString *firstName;

/*!
 The user's last name.
 */
@property (weak, nonatomic, readonly) NSString *lastName;

/*!
 The user's email.
 */
@property (weak, nonatomic, readonly) NSString *email;

/*!
 The URL of person's full size photo.
 */
@property (weak, nonatomic, readonly) NSURL *photoURL;

/*!
 The URL of person's thumbnail photo if available.
 */
@property (weak, nonatomic, readonly) NSURL *thumbnailURL;

/** @name Accessing Keys and Values */

/*!
 Returns an array containing the user dictionary keys.
 
 @returns An array containing the user dictionary keys.
 */
- (NSArray *)allKeys;

/*!
 Returns the value associated with the given key.
 
 @param key The key for which to return the value.
 */
- (id)objectForKey:(NSString *)key;

/*!
 Returns the value associated with the given key.
 
 This method is the same as <objectForKey:>, but is required for subscripting syntax.
 
 @param key The key for which to return the value.
 */
- (id)objectForKeyedSubscript:(NSString *)key;

/** @name JSON Encoding */

/*!
 Returns a JSON representation of the `accounts.getAccountInfo` response.
 */
- (NSString *)JSONString;

@end
