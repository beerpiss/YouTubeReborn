#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SponsorSegment : NSObject
@property(assign, nonatomic) CGFloat startTime;
@property(assign, nonatomic) CGFloat endTime;
@property(strong, nonatomic) NSString* category;
@property(strong, nonatomic) NSString* actionType;
@property(strong, nonatomic) NSString* UUID;
@property(assign, nonatomic) BOOL locked;
@property(assign, nonatomic) NSUInteger votes;
@property(strong, nonatomic) NSString* userID;

- (instancetype)initWithStartTime:(CGFloat)startTime
                          endTime:(CGFloat)endTime
                         category:(NSString*)category
                       actionType:(NSString*)actionType
                             UUID:(NSString*)UUID
                           locked:(BOOL)locked
                            votes:(NSUInteger)votes
                           userID:(NSString*)userID;

@end
