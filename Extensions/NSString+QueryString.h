#import <Foundation/Foundation.h>

@interface NSString (QueryString)

+ (NSString*)URLQueryStringFromDictionary:(NSDictionary*)dictionary;

@end
