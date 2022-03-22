#import <Foundation/Foundation.h>
#import "SponsorSegment.h"

/**
 *  The SponsorBlockClient class is used to interact with the SponsorBlock API.
 */
@interface SponsorBlockClient : NSObject

@property(nonatomic, strong) NSString* userID;
@property(nonatomic, strong) NSString* apiURL;
@property(nonatomic, strong) NSArray<NSString*>* categories;

- (instancetype)initWithUserID:(NSString*)userID apiURL:(NSString*)apiURL categories:(NSArray<NSString*>*)categories;
- (instancetype)initWithUserID:(NSString*)userID apiURL:(NSString*)apiURL;
- (instancetype)initWithUserID:(NSString*)userID;
- (instancetype)init;

- (void)getSponsorSegments:(NSString*)videoID
                   handler:(void (^)(NSArray<SponsorSegment*>* sponsorSegments, NSError* error))handler;
- (void)submitSponsorSegments:(NSArray<SponsorSegment*>*)sponsorSegments
                     forVideo:(NSString*)videoID
                       userID:(NSString*)userID
                      handler:(void (^)(NSArray<SponsorSegment*>* rejectedSegments, NSArray<NSError*>* error))handler;
- (void)normalVoteForSegment:(SponsorSegment*)segment
                      userID:(NSString*)userID
                        type:(NSUInteger)type
                     handler:(void (^)(NSError* error))handler;
- (void)categoryVoteForSegment:(SponsorSegment*)segment
                        userID:(NSString*)userID
                      category:(NSString*)category
                       handler:(void (^)(NSError* error))handler;
- (void)viewedVideoSponsorTime:(SponsorSegment *)segment;

@end
