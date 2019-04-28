#import <Foundation/Foundation.h>
#import "Gigya.h"

#define GSLog(format, ...) [[GSLogger sharedInstance] log:format, ##__VA_ARGS__]
#define GSLogContext(message, ...) [[GSLogger sharedInstance] logInContext:self format:message, ##__VA_ARGS__]

@protocol GSLoggerContext <NSObject>

@required
- (NSString *)contextID;

@end

@interface GSLogger : NSObject

@property (nonatomic) BOOL enabled;

+ (GSLogger *)sharedInstance;
- (void)log:(NSString *)format, ...;
- (void)logInContext:(id<GSLoggerContext>)context format:(NSString *)format, ...;
+ (void)clear:(id<GSLoggerContext>)context;
+ (NSString *)logForContext:(id<GSLoggerContext>)context;

@end
