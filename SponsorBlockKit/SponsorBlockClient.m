#import "SponsorBlockClient.h"
#import <Foundation/Foundation.h>
#import "../Extensions/NSString+QueryString.h"
#import "../Extensions/NSString+SHA256.h"
#import "SponsorSegment.h"

#define SPONSORBLOCK_MAIN_API @"https://sponsor.ajay.app"
#define DEFAULT_CATEGORIES \
    @[ @"sponsor", @"selfpromo", @"poi_highlight", @"intro", @"outro", @"preview", @"filler", @"music_offtopic" ]

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
       useSHA256HashPrefix:(BOOL)useSHA256HashPrefix
                   handler:(void (^)(NSArray<SponsorSegment*>* sponsorSegments, NSError* error))handler {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    NSDictionary* query = useSHA256HashPrefix ? @{@"category" : [NSSet setWithArray:self.categories]} : @{
        @"videoID" : videoID,
        @"category" : [NSSet setWithArray:self.categories],  // we do a little deduplication
    };

    if (useSHA256HashPrefix) {
        [request setURL:[NSURL URLWithString:[NSString
                                                 stringWithFormat:@"%@/api/skipSegments/%@?%@", self.apiURL,
                                                                  [[NSString SHA256HashFor:videoID] substringToIndex:4],
                                                                  [NSString URLQueryStringFromDictionary:query]]]];
    } else {
        [request
            setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api/skipSegments?%@", self.apiURL,
                                                                   [NSString URLQueryStringFromDictionary:query]]]];
    }
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession]
        dataTaskWithRequest:request
          completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            if (error) {
                handler(nil, error);
                return;
            }
            NSHTTPURLResponse* URLResponse = (NSHTTPURLResponse*)response;
            if (URLResponse.statusCode != 200)
                handler(nil, [NSError errorWithDomain:@"SponsorBlockKit" code:URLResponse.statusCode userInfo:nil]);

            NSArray* jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                handler(nil, error);
                return;
            }
            NSLog(@"[YouTube Reborn] [SponsorBlock] Received data from SponsorBlock API: %@", jsonData);
            NSMutableArray* segments = [NSMutableArray array];
            NSArray* rawSegmentArray;
            if (useSHA256HashPrefix) {
                for (NSDictionary* _dict in jsonData) {
                    if ([(NSString*)[_dict objectForKey:@"videoID"] isEqualToString:videoID]) {
                        rawSegmentArray = (NSArray*)[_dict objectForKey:@"segments"];
                    }
                }
            } else {
                rawSegmentArray = jsonData;
            }
            for (NSDictionary* _dict in rawSegmentArray) {
                SponsorSegment* segment =
                    [[SponsorSegment alloc] initWithStartTime:[[_dict objectForKey:@"segment"][0] floatValue]
                                                      endTime:[[_dict objectForKey:@"segment"][1] floatValue]
                                                     category:(NSString*)[_dict objectForKey:@"category"]
                                                   actionType:(NSString*)[_dict objectForKey:@"actionType"]
                                                         UUID:(NSString*)[_dict objectForKey:@"UUID"]
                                                       locked:[[_dict objectForKey:@"locked"] boolValue]
                                                        votes:[[_dict objectForKey:@"votes"] unsignedIntegerValue]
                                                       userID:(NSString*)[_dict objectForKey:@"userID"]];
                [segments addObject:segment];
            }
            [segments sortUsingComparator:^NSComparisonResult(SponsorSegment* obj1, SponsorSegment* obj2) {
              NSNumber* first = @(obj1.startTime);
              NSNumber* second = @(obj2.startTime);
              return [first compare:second];
            }];
            handler(segments.copy, nil);
          }];
    NSLog(@"[YouTube Reborn] [SponsorBlock] Making request to %@", request.URL);
    [dataTask resume];
}

- (void)submitSponsorSegment:(SponsorSegment*)segment
                    forVideo:(NSString*)videoID
                     handler:(void (^)(NSError* error))handler {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request
        setURL:[NSURL URLWithString:
                          [NSString stringWithFormat:
                                        @"%@/api/skipSegments?videoID=%@&startTime=%f&endTime=%f&category=%@&userID=%@",
                                        self.apiURL, videoID, segment.startTime, segment.endTime, segment.category,
                                        self.userID]]];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession]
        dataTaskWithRequest:request
          completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            if (error) {
                handler(error);
                return;
            }
            NSHTTPURLResponse* URLResponse = (NSHTTPURLResponse*)response;
            if (URLResponse.statusCode != 200) {
                handler([NSError errorWithDomain:@"SponsorBlockKit" code:URLResponse.statusCode userInfo:nil]);
            } else {
                handler(nil);
            }
          }];
    [dataTask resume];
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
