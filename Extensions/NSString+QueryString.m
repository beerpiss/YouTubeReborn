#import "NSString+QueryString.h"

@implementation NSString (QueryString)

+ (NSString*)URLQueryStringFromDictionary:(NSDictionary*)dictionary {
    NSArray* keys = [dictionary.allKeys
        filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
          return [(NSObject*)evaluatedObject isKindOfClass:[NSString class]];
        }]];

    NSMutableString* query = [NSMutableString new];
    for (NSString* key in [keys sortedArrayUsingSelector:@selector(compare:)]) {
        // There can be multiple values for the same key in a URL query string, so we try to support that.
        if ([(NSObject*)dictionary[key] isKindOfClass:[NSArray class]] ||
            [(NSObject*)dictionary[key] isKindOfClass:[NSMutableArray class]] ||
            [(NSObject*)dictionary[key] isKindOfClass:[NSSet class]]) {
            for (NSObject* value in dictionary[key]) {
                if (query.length > 0)
                    [query appendString:@"&"];
                [query appendFormat:@"%@=%@", key, [value description]];
            }
        } else {
            if (query.length > 0)
                [query appendString:@"&"];
            [query appendFormat:@"%@=%@", key, [(NSObject*)dictionary[key] description]];
        }
    }

    return [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}
@end
