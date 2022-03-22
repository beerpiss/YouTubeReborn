#import "SponsorBlockClient.h"
#import <Foundation/Foundation.h>
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
                   handler:(void (^)(NSArray<SponsorSegment*>* sponsorSegments, NSError* error))handler {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    NSString* categories = [NSString stringWithFormat:@"[%%22%@%%22]", [self.categories componentsJoinedByString:@"%22,%20%22"]];

    [request setURL:[NSURL URLWithString:[
                 NSString stringWithFormat:@"%@/api/skipSegments?videoID=%@&categories=%@", self.apiURL, videoID,
                 categories
             ]]];
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask* dataTask = [[NSURLSession sharedSession]
        dataTaskWithRequest:request
          completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            if (data != nil && error == nil) {
                NSArray* jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
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
                NSArray* sponsorSegments = [segments sortedArrayUsingComparator:^NSComparisonResult(
                                                         SponsorSegment* obj1, SponsorSegment* obj2) {
                                             NSNumber* first = @(obj1.startTime);
                                             NSNumber* second = @(obj2.startTime);
                                             return [first compare:second];
                                           }].copy;
                handler(sponsorSegments, nil);
            } else {
                handler(nil, error);
            }
          }];
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
    handler(rejectedSegments, errors);
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
