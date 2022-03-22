#import <Foundation/Foundation.h>
#import <SponsorBlockKit/SponsorBlockKit.h>

@interface YTInlinePlayerBarView : UIView
@end

@interface YTInlinePlayerBarContainerView : UIView
-(void)setChapters:(NSArray *)arg1;
@property (strong, nonatomic) NSArray *chaptersArray;
@property (strong, nonatomic) YTInlinePlayerBarView *playerBar;
@property (strong, nonatomic) YTInlinePlayerBarView *segmentablePlayerBar;
@property (strong, nonatomic) UILabel *durationLabel;
@end

@interface YTMainAppControlsOverlayView : UIView
@end

@interface YTMainAppVideoPlayerOverlayView : UIView
@property (strong, nonatomic) YTInlinePlayerBarContainerView *playerBar;
@property (strong, nonatomic) YTMainAppControlsOverlayView *controlsOverlayView;
@end    

@interface YTPlayerView : UIView
@property (strong, nonatomic) YTMainAppVideoPlayerOverlayView *overlayView;
@end

@interface YTIVideoDetails : NSObject
@property (strong, nonatomic) NSString *channelId;
@end

@interface MLVideo : NSObject
@property (strong, nonatomic) YTIVideoDetails *videoDetails;
@end

@interface YTPlaybackData : NSObject
@property (strong, nonatomic) MLVideo *video;
@end

@interface YTSingleVideo : NSObject
@property (strong, nonatomic) MLVideo *video;
@property (strong, nonatomic) YTPlaybackData *playbackData;
@end

@interface YTSingleVideoController : NSObject
@property (strong, nonatomic) YTSingleVideo *singleVideo;
@end

@interface YTSingleVideoTime : NSObject
@property (nonatomic, assign) CGFloat time;
@end

@interface YTPlayerViewController : UIViewController
@property (strong, nonatomic) YTPlayerView *view;

@property (strong, nonatomic) NSArray <SponsorSegment *> *skipSegments;
@property(nonatomic, assign) NSInteger currentSponsorSegment;
@property (nonatomic, assign) NSInteger unskippedSegment;

@property (strong, nonatomic) NSString *currentVideoID;
@property (nonatomic, assign) CGFloat currentVideoTotalMediaTime;
@property (nonatomic, assign) BOOL isPlayingAd;

@property (nonatomic, assign, getter=isMDXActive) BOOL MDXActive;
- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3;
- (void)singleVideo:(id)arg1 currentVideoTimeDidChange:(id)arg2;
- (instancetype)initWithParentResponder:(id)arg1 overlayFactory:(id)arg2;
- (void)scrubToTime:(CGFloat)time;

@end
