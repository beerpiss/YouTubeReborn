@interface UIView ()
- (UIViewController*)_viewControllerForAncestor;
@property(nonatomic, readwrite) UIView* overlayView;
@property(nonatomic, readwrite) UIView* playerBar;
@property(nonatomic, readwrite) UILabel* durationLabel;
@end

@interface YTQTMButton : UIButton
@end

@interface ABCSwitch : UISwitch
@end

@interface YTPivotBarItemView : UIView
@property(readonly, nonatomic) YTQTMButton* navigationButton;
@end

@interface YTRightNavigationButtons
@property(readonly, nonatomic) YTQTMButton* MDXButton;
@property(readonly, nonatomic) YTQTMButton* searchButton;
@property(readonly, nonatomic) YTQTMButton* notificationButton;
@end

@interface YTMainAppControlsOverlayView : UIView
@property(readonly, nonatomic) YTQTMButton* playbackRouteButton;
@property(readonly, nonatomic) YTQTMButton* previousButton;
@property(readonly, nonatomic) YTQTMButton* nextButton;
@property(readonly, nonatomic) ABCSwitch* autonavSwitch;
@property(readonly, nonatomic) YTQTMButton* closedCaptionsOrSubtitlesButton;
@end

@interface YTMainAppSkipVideoButton
@property(readonly, nonatomic) UIImageView* imageView;
@end

@protocol YTPlaybackController
@end

@interface YTPlayerViewController : UIViewController <YTPlaybackController>
@property float playbackRate;
- (void)didSeekToTime:(CGFloat)time toleranceBefore:(CGFloat)before toleranceAfter:(CGFloat)after;
@end

@interface YTUserDefaults : NSObject
- (long long)appThemeSetting;
@end

@interface YTWatchController : NSObject
- (void)showFullScreen;
@end

@interface YTPivotBarViewController : UIViewController
- (void)selectItemWithPivotIdentifier:(id)pivotIndentifier;
@end

@interface YTWrapperView : UIView
- (void)rootOptionsAction:(id)sender;
@end

@interface YTIShareTargetServiceUpdateRenderer
- (int)serviceId;
@end

@interface YTShareTargetCell : UIView
- (void)didTap;
@end

@interface YTShareRequestViewController : UIViewController
@end
