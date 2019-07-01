#import <Foundation/Foundation.h>

@interface GSObject : NSObject

@property (nonatomic, copy) NSString *source;
- (id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)obj forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (NSArray *)allKeys;
- (NSString *)JSONString;

@end
