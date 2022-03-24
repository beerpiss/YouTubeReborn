#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (SHA256)
+ (NSString*)SHA256HashFor:(NSString*)input;
@end
