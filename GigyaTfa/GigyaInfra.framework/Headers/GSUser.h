#import "GSResponse.h"

/**
 This class represents Gigya user information, as returned from the <a target="_blank" href="http://developers.gigya.com/display/GD/socialize.getUserInfo+REST">socialize.getUserInfo</a> method in the <a target="_blank" href="http://developers.gigya.com/display/GD/REST+API">Gigya REST API</a>.
 
 `GSUser` values can be accessed by keys (similiar to NSDictionary) and support subscripting syntax:
 
    // These two statements are equivalent
    NSString *email = [user objectForKey:@"email"];
    NSString *email = user[@"email"];
 
 `GSUser` also providers properties for easy access to the most commonly used values.
 */
@interface GSUser : GSResponse

/** @name Basic User Information */

/*!
 The unique ID of the user.
 */
@property (weak, nonatomic, readonly) NSString *UID;

/*!
 The name of the provider that the user used in order to login.
 */
@property (weak, nonatomic, readonly) NSString *loginProvider;

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
 An array of dictionaries that represent <a target="_blank" href="http://developers.gigya.com/display/GD/Identity+JS">identity objects</a>, describing a person's identity on a specific provider.
 */
@property (weak, nonatomic, readonly) NSArray *identities;

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
 Returns a JSON representation of the `getUserInfo` response.
 */
- (NSString *)JSONString;

@end
