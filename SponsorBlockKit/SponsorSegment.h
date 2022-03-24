#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 *  Represents a SponsorBlock segment. Use the -[SponsorBlockClient getSponsorSegments:] method to get an array of 
 * SponsorBlock segments for a video.
 *
 * The only time you should create a SponsorSegment yourself is when you are submitting segments to the 
 * SponsorBlock API.
 */
@interface SponsorSegment : NSObject

/**
 *  ----------------------------------
 *  @name Accessing segment properties
 *  ----------------------------------
 */

/**
 * The start time of the segment in seconds.
 */
@property(assign, nonatomic) CGFloat startTime;

/**
 * The end time of the segment in seconds.
 */
@property(assign, nonatomic) CGFloat endTime;

/**
 * The category of the segment. It can be one of either:
 * - sponsor selfpromo interaction intro outro preview music_offtopic filler
 * 
 * @see [SponsorBlock's types](https://wiki.sponsor.ajay.app/w/Types) for a more updated list.
 */
@property(strong, nonatomic) NSString* category;

/**
 * The action type of the segment. It can be one of either:
 * - skip mute full poi
 *
 * @see [SponsorBlock's types](https://wiki.sponsor.ajay.app/w/Types) for a more updated list.
 */
@property(strong, nonatomic) NSString* actionType;

/**
 * The UUID of the segment.
 */
@property(strong, nonatomic) NSString* UUID;

/**
 * Whether or not submisson for this segment is locked.
 */
@property(assign, nonatomic) BOOL locked;

/**
 * The number of votes for this segment.
 */
@property(assign, nonatomic) NSUInteger votes;

/**
 * userID of the user who submitted this segment.
 */
@property(strong, nonatomic) NSString* userID;



/**
 *  ------------------
 *  @name Initializing
 *  ------------------
 */

/**
 *  Initializes a SponsorBlock segment.
 *
 *  @param startTime The start time of the segment in seconds.
 *  @param endTime The end time of the segment in seconds.
 *  @param category The category of the segment. It can be one of either:
 *  - sponsor selfpromo interaction intro outro preview music_offtopic filler
 *  @param actionType The action type of the segment. It can be one of either:
 *  - skip mute full poi
 *  @param UUID The UUID of the segment. If nil, a new UUID will be generated.
 *  @param locked Whether or not submisson for this segment is locked.
 *  @param votes The number of votes for this segment.
 *  @param userID The userID of the user who submitted this segment.
 *
 *  @return An initialized `SponsorSegment` object.
 * 
 *  @see [SponsorBlock's types](https://wiki.sponsor.ajay.app/w/Types)
 */
- (instancetype)initWithStartTime:(CGFloat)startTime
                          endTime:(CGFloat)endTime
                         category:(NSString*)category
                       actionType:(NSString*)actionType
                             UUID:(NSString*)UUID
                           locked:(BOOL)locked
                            votes:(NSUInteger)votes
                           userID:(NSString*)userID;
                           
/**
 *  Initializes a SponsorBlock segment. Convenience method, mainly for use when submitting segments.
 *
 *  @param startTime The start time of the segment in seconds.
 *  @param endTime The end time of the segment in seconds.
 *  @param category The category of the segment. It can be one of either:
 *  - sponsor selfpromo interaction intro outro preview music_offtopic filler
 *  @param UUID The UUID of the segment. If nil, a new UUID will be generated.
 *
 *  @return An initialized `SponsorSegment` object.
 * 
 *  @see [SponsorBlock's types](https://wiki.sponsor.ajay.app/w/Types)
 */
- (instancetype)initWithStartTime:(CGFloat)startTime
                          endTime:(CGFloat)endTime
                         category:(NSString*)category
                             UUID:(NSString*)UUID;

@end
