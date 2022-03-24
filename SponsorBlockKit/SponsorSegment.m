#import "SponsorSegment.h"

@implementation SponsorSegment
- (instancetype)initWithStartTime:(CGFloat)startTime
                          endTime:(CGFloat)endTime
                         category:(NSString*)category
                       actionType:(NSString*)actionType
                             UUID:(NSString*)UUID
                           locked:(BOOL)locked
                            votes:(NSUInteger)votes
                           userID:(NSString*)userID {
    self = [super init];
    if (self) {
        self.startTime = startTime;
        self.endTime = endTime;
        self.category = category;
        self.actionType = actionType;
        self.UUID = UUID == nil ? [NSUUID UUID].UUIDString : UUID;
        self.locked = locked;
        self.votes = votes;
        self.userID = userID;
    }
    return self;
}

- (instancetype)initWithStartTime:(CGFloat)startTime
                          endTime:(CGFloat)endTime
                         category:(NSString*)category
                             UUID:(NSString*)UUID {
    return [self initWithStartTime:startTime
                           endTime:endTime
                          category:category
                        actionType:nil
                              UUID:UUID
                            locked:NO
                             votes:0
                            userID:nil];
}
@end
