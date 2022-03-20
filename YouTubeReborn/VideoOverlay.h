@interface UIView ()
- (UIViewController*)_viewControllerForAncestor;
@end

@interface YTMainAppControlsOverlayView : UIView
@property(retain, nonatomic) UIButton* overlayButtonOne;
@property(retain, nonatomic) UIButton* overlayButtonTwo;
@property(retain, nonatomic) UIButton* overlayButtonThree;
- (void)playInApp;
- (void)optionsAction:(id)sender;
- (void)audioDownloader;
- (void)videoDownloader;
- (void)pictureInPicture;
@end

@interface YTMainAppVideoPlayerOverlayViewController
- (CGFloat)mediaTime;
- (int)playerViewLayout;
- (NSInteger)playerState;
@end

@interface YTLocalPlaybackController : NSObject
- (NSString*)currentVideoID;
@end

@interface YTWrapperView : UIView
@end

@interface YTAsyncCollectionView : UICollectionView
@end

@interface YTTopAlignedView : UIView
@end

// Tweak Variables

extern NSMutableArray* _overlayButtons;
extern NSDictionary* _overlaySelectors;
extern NSString* pipTime;
extern NSURL* pipURL;
