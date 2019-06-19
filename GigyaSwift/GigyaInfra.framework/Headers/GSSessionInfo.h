#import <Foundation/Foundation.h>

@interface GSSessionInfo : NSObject <NSCoding>

/*!
 The session expiration date.
 */
@property (nonatomic, copy) NSDate *expiration;

/*!
 The session API key.
 */
@property (nonatomic, copy) NSString *APIKey;

- (GSSessionInfo *)initWithAPIKey:(NSString *)apikey
                       expiration:(NSDate *)expiration;

/*!
 Indicates whether the Gigya session info is valid, suggest session is valid.
 */

- (BOOL)isValid;

@end
