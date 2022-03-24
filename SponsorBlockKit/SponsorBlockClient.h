#import <Foundation/Foundation.h>
#import "SponsorSegment.h"

/**
 *  The SponsorBlockClient class is used to interact with the SponsorBlock API.
 */
@interface SponsorBlockClient : NSObject

/**
 *  ---------------------------------
 *  @name Accessing client properties
 *  ---------------------------------
 */

/**
 * The user ID of the SponsorBlock user.
 */
@property(nonatomic, strong) NSString* userID;

/**
 * The base URL of the API.
 */
@property(nonatomic, strong) NSString* apiURL;

/**
 * A list of categories to request from the SponsorBlock API
 * The array can contain any of the following:
 * - sponsor selfpromo interaction intro outro preview music_offtopic filler
 *
 * @see [SponsorBlock's types](https://wiki.sponsor.ajay.app/w/Types) for a more updated list.
 */
@property(nonatomic, strong) NSArray<NSString*>* categories;

/**
 *  ---------------------------
 *  @name Initializing a client
 *  ---------------------------
 */

/**
 *  Initializes a client.
 *
 *  @param userID The user ID of the SponsorBlock user.
 *  @param apiURL The base URL of the API.
 *  @param categories A list of categories to request from the SponsorBlock API
 *
 *  @return An initialized client.
 *
 *  @see categories
 */

- (instancetype)initWithUserID:(NSString*)userID apiURL:(NSString*)apiURL categories:(NSArray<NSString*>*)categories;

/**
 *  Initializes a client. Convenience method to initialize a client with all segment categories.
 *
 *  @param userID The user ID of the SponsorBlock user.
 *  @param apiURL The base URL of the API.
 *
 *  @return An initialized client.
 *
 *  @see categories
 *  @see -[initWihtUserID:apiURL:categories:]
 */
- (instancetype)initWithUserID:(NSString*)userID apiURL:(NSString*)apiURL;

/**
 *  Initializes a client. Convenience method to initialize a client with all segment categories
 *  and the main SponsorBlock API instance.
 *
 *  @param userID The user ID of the SponsorBlock user.
 *
 *  @return An initialized client.
 *
 *  @see categories
 *  @see -[initWihtUserID:apiURL:categories:]
 */
- (instancetype)initWithUserID:(NSString*)userID;

/**
 *  Initializes a client. Really convenient method that usese all default settings and a randomized userID.
 *  and the main SponsorBlock API instance.
 *
 *  @return An initialized client.
 *
 *  @see categories
 *  @see -[initWihtUserID:apiURL:categories:]
 */
- (instancetype)init;

/**
 * ---------------------------------------------
 * @name Communicating with the SponsorBlock API
 * ---------------------------------------------
 */

/**
 *  Get segments from the SponsorBlock API.
 *
 *  @param vidoeID the 11-letter YouTube video ID.
 *  @param useSHA256HashPrefix whether to use the first 4 letters of the SHA256 hash of the video ID for extra privacy
 * ([see this](https://wiki.sponsor.ajay.app/w/API_Docs#GET_.2Fapi.2FskipSegments.2F:sha256HashPrefix))
 *  @param handler the block to call when the request is complete.
 *  It has two arguments: an array of SponsorSegments, sorted by startTime and an NSError.
 *
 */
- (void)getSponsorSegments:(NSString*)videoID
       useSHA256HashPrefix:(BOOL)useSHA256HashPrefix
                   handler:(void (^)(NSArray<SponsorSegment*>* sponsorSegments, NSError* error))handler;

/**
 *  Submit a segment to the SponsorBlock database.
 *
 *  @param sponsorSegment the SponsorSegment object to submit
 *  @param videoID the 11-letter YouTube video ID to submit the segment for.
 *  @param handler the block to call when the request is complete. It accepts one argument, error, which is nil if the
 * request was successful.
 *
 *  @see SponsorSegment
 */
- (void)submitSponsorSegment:(SponsorSegment*)sponsorSegment
                    forVideo:(NSString*)videoID
                     handler:(void (^)(NSError* error))handler;
- (void)normalVoteForSegment:(SponsorSegment*)segment
                      userID:(NSString*)userID
                        type:(NSUInteger)type
                     handler:(void (^)(NSError* error))handler;
- (void)categoryVoteForSegment:(SponsorSegment*)segment
                        userID:(NSString*)userID
                      category:(NSString*)category
                       handler:(void (^)(NSError* error))handler;
- (void)viewedVideoSponsorTime:(SponsorSegment*)segment;

@end
