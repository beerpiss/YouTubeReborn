#import <Foundation/Foundation.h>
#import "SponsorBlockClient.h"
#import "SponsorSegment.h"

#define SPONSORBLOCK_MAIN_API @"https://sponsor.ajay.app"
#define DEFAULT_CATEGORIES \
    @[ @"sponsor", @"selfpromo", @"poi_highlight", @"intro", @"outro", @"preview", @"filler", @"music_offtopic" ]

NSString* QueryStringWithDictionary(NSDictionary* dictionary) {
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

@implementation SponsorBlockClient
- (instancetype)initWithUserID:(NSString*)userID apiURL:(NSString*)apiURL categories:(NSArray<NSString*>*)categories {
    if (!(self = [super init])) {
        return nil;
    }
    self.userID = userID;
    self.apiURL = apiURL;
    self.categories = categories;
    return self;
}

- (instancetype)initWithUserID:(NSString*)userID apiURL:(NSString*)apiURL {
    return [self initWithUserID:userID apiURL:apiURL categories:DEFAULT_CATEGORIES];
}

- (instancetype)initWithUserID:(NSString*)userID {
    return [self initWithUserID:userID apiURL:SPONSORBLOCK_MAIN_API categories:DEFAULT_CATEGORIES];
}

- (instancetype)init {
    return [self initWithUserID:[[NSUUID UUID] UUIDString] apiURL:SPONSORBLOCK_MAIN_API categories:DEFAULT_CATEGORIES];
}

- (void)getSponsorSegments:(NSString*)videoID
                   handler:(void (^)(NSArray<SponsorSegment*>* sponsorSegments, NSError* error))handler {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    NSDictionary* query = @{
        @"videoID" : videoID,
        @"category" : self.categories,
    };

    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/skipSegments?%@", self.apiURL,
                                                                    QueryStringWithDictionary(query)]]];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession]
        dataTaskWithRequest:request
          completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            if (data != nil && error == nil) {
                NSArray* jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (error != nil) {
                    handler(nil, error);
                    return;
                }
                NSLog(@"[YouTube Reborn] [SponsorBlock] Received data from SponsorBlock API: %@", jsonData);
                NSMutableArray* segments = [NSMutableArray array];
                for (NSDictionary* dict in jsonData) {
                    SponsorSegment* segment =
                        [[SponsorSegment alloc] initWithStartTime:[[dict objectForKey:@"segment"][0] floatValue]
                                                          endTime:[[dict objectForKey:@"segment"][1] floatValue]
                                                         category:(NSString*)[dict objectForKey:@"category"]
                                                       actionType:(NSString*)[dict objectForKey:@"actionType"]
                                                             UUID:(NSString*)[dict objectForKey:@"UUID"]
                                                           locked:[[dict objectForKey:@"locked"] boolValue]
                                                            votes:[[dict objectForKey:@"votes"] unsignedIntegerValue]
                                                           userID:(NSString*)[dict objectForKey:@"userID"]];
                    [segments addObject:segment];
                }
                [segments sortUsingComparator:^NSComparisonResult(SponsorSegment* obj1, SponsorSegment* obj2) {
                  if (obj1.startTime < obj2.startTime)
                      return NSOrderedAscending;
                  else if (obj1.startTime > obj2.startTime)
                      return NSOrderedDescending;
                  else
                      return NSOrderedSame;
                }];
                handler(segments.copy, nil);
            } else {
                handler(nil, error);
            }
          }];
    NSLog(@"[YouTube Reborn] [SponsorBlock] Making request to %@", request.URL);
    [dataTask resume];
}

- (void)submitSponsorSegments:(NSArray<SponsorSegment*>*)sponsorSegments
                     forVideo:(NSString*)videoID
                       userID:(NSString*)userID
                      handler:(void (^)(NSArray<SponsorSegment*>* rejectedSegments, NSArray<NSError*>* error))handler {
    __block NSMutableArray<SponsorSegment*>* rejectedSegments;
    __block NSMutableArray<NSError*>* errors;
    for (SponsorSegment* segment in sponsorSegments) {
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
        [request
            setURL:[NSURL URLWithString:
                              [NSString
                                  stringWithFormat:
                                      @"%@/api/skipSegments?videoID=%@&startTime=%f&endTime=%f&category=%@&userID=%@",
                                      self.apiURL, videoID, segment.startTime, segment.endTime, segment.category,
                                      self.userID]]];
        request.HTTPMethod = @"POST";
        NSURLSessionDataTask* dataTask =
            [[NSURLSession sharedSession] dataTaskWithRequest:request
                                            completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
                                              NSHTTPURLResponse* URLResponse = (NSHTTPURLResponse*)response;
                                              if (URLResponse.statusCode != 200) {
                                                  [rejectedSegments addObject:segment];
                                                  [errors addObject:error];
                                              }
                                            }];
        [dataTask resume];
    }
    handler(rejectedSegments.copy, errors.copy);
}

- (void)normalVoteForSegment:(SponsorSegment*)segment
                      userID:(NSString*)userID
                        type:(NSUInteger)type
                     handler:(void (^)(NSError* error))handler {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request
        setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/voteOnSponsorTime?UUID=%@&userID=%@&type=%lu",
                                                               self.apiURL, segment.UUID, userID, type]]];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask* dataTask =
        [[NSURLSession sharedSession] dataTaskWithRequest:request
                                        completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
                                          NSHTTPURLResponse* URLResponse = (NSHTTPURLResponse*)response;
                                          if (URLResponse.statusCode != 200) {
                                              handler(error);
                                          } else {
                                              handler(nil);
                                          }
                                        }];
    [dataTask resume];
}
- (void)categoryVoteForSegment:(SponsorSegment*)segment
                        userID:(NSString*)userID
                      category:(NSString*)category
                       handler:(void (^)(NSError* error))handler {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString
                                             stringWithFormat:@"%@/api/voteOnSponsorTime?UUID=%@&userID=%@&category=%@",
                                                              self.apiURL, segment.UUID, userID, category]]];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask* dataTask =
        [[NSURLSession sharedSession] dataTaskWithRequest:request
                                        completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
                                          NSHTTPURLResponse* URLResponse = (NSHTTPURLResponse*)response;
                                          if (URLResponse.statusCode != 200) {
                                              handler(error);
                                          } else {
                                              handler(nil);
                                          }
                                        }];
    [dataTask resume];
}

- (void)viewedVideoSponsorTime:(SponsorSegment*)segment {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/viewedVideoSponsorTime?UUID=%@",
                                                                    self.apiURL, segment.UUID]]];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask* dataTask =
        [[NSURLSession sharedSession] dataTaskWithRequest:request
                                        completionHandler:^(NSData* data, NSURLResponse* response, NSError* error){
                                        }];
    [dataTask resume];
}
@end
