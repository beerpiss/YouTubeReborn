#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import "Tweak.h"

%group gNoVideoAds
%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1 {
}
%end
%hook YTInnerTubeContextDecorator
- (void)decorateContext:(id)arg1 {
}
%end
%hook YTIPlayerResponse
- (BOOL)isMonetized {
    return 0;
}
%end
%hook YTDataUtils
+ (id)spamSignalsDictionary {
    return NULL;
}
%end
%end

%group gBackgroundPlayback
%hook YTIPlayerResponse
- (BOOL)isPlayableInBackground {
    return 1;
}
%end
%hook YTSingleVideo
- (BOOL)isPlayableInBackground {
    return 1;
}
%end
%hook YTSingleVideoMediaData
- (BOOL)isPlayableInBackground {
    return 1;
}
%end
%hook YTPlaybackData
- (BOOL)isPlayableInBackground {
    return 1;
}
%end
%hook YTIPlayabilityStatus
- (BOOL)isPlayableInBackground {
    return 1;
}
%end
%hook YTPlaybackBackgroundTaskController
- (BOOL)isContentPlayableInBackground {
    return 1;
}
- (void)setContentPlayableInBackground:(BOOL)arg1 {
    arg1 = 1;
    %orig;
}
%end
%hook YTBackgroundabilityPolicy
- (BOOL)isBackgroundableByUserSettings {
    return 1;
}
%end
%end

%group gNoDownloadButton
%hook YTTransferButton
- (void)setVisible:(BOOL)arg1 dimmed:(BOOL)arg2 {
    arg1 = 0;
    %orig;
}
%end
%end

%group gNoCastButton
%hook YTSettings
- (BOOL)disableMDXDeviceDiscovery {
    return 1;
}
%end
%hook YTRightNavigationButtons
- (void)layoutSubviews {
    %orig();
    if (![[self MDXButton] isHidden])
        [[self MDXButton] setHidden:YES];
}
%end
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
    %orig();
    if (![[self playbackRouteButton] isHidden])
        [[self playbackRouteButton] setHidden:YES];
}
%end
%end

%group gNoNotificationButton
%hook YTNotificationPreferenceToggleButton
- (void)setHidden:(BOOL)arg1 {
    arg1 = 1;
    %orig;
}
%end
%hook YTNotificationMultiToggleButton
- (void)setHidden:(BOOL)arg1 {
    arg1 = 1;
    %orig;
}
%end
%hook YTRightNavigationButtons
- (void)layoutSubviews {
    %orig();
    if (![[self notificationButton] isHidden])
        [[self notificationButton] setHidden:YES];
}
%end
%end

%group gAllowHDOnCellularData
%hook YTUserDefaults
- (BOOL)disableHDOnCellular {
    return 0;
}
- (void)setDisableHDOnCellular:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%hook YTSettings
- (BOOL)disableHDOnCellular {
    return 0;
}
- (void)setDisableHDOnCellular:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%end

%group gShowStatusBarInOverlay
%hook YTSettings
- (BOOL)showStatusBarWithOverlay {
    return 1;
}
%end
%end

%group gDisableRelatedVideosInOverlay
%hook YTRelatedVideosViewController
- (BOOL)isEnabled {
    return 0;
}
- (void)setEnabled:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%hook YTFullscreenEngagementOverlayView
- (BOOL)isEnabled {
    return 0;
}
- (void)setEnabled:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%hook YTFullscreenEngagementOverlayController
- (BOOL)isEnabled {
    return 0;
}
- (void)setEnabled:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%hook YTMainAppVideoPlayerOverlayView
- (void)setInfoCardButtonHidden:(BOOL)arg1 {
    arg1 = 1;
    %orig;
}
- (void)setInfoCardButtonVisible:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%hook YTMainAppVideoPlayerOverlayViewController
- (void)adjustPlayerBarPositionForRelatedVideos {
}
%end
%end

%group gDisableVideoEndscreenPopups
%hook YTCreatorEndscreenView
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
%end
%end

%group gDisableYouTubeKids
%hook YTWatchMetadataAppPromoCell
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
%end
%hook YTHUDMessageView
- (id)initWithMessage:(id)arg1 dismissHandler:(id)arg2 {
    return NULL;
}
%end
%hook YTNGWatchMiniBarViewController
- (id)miniplayerRenderer {
    return NULL;
}
%end
%hook YTWatchMiniBarViewController
- (id)miniplayerRenderer {
    return NULL;
}
%end
%end

%group gDisableVoiceSearch
%hook YTSearchTextField
- (void)setVoiceSearchEnabled:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%hook YTSearchViewController
- (void)viewDidLoad {
    %orig();
    MSHookIvar<UIButton*>(self, "_voiceButton").enabled = NO;
    MSHookIvar<UIButton*>(self, "_voiceButton").frame = CGRectMake(0, 0, 0, 0);
}
%end
%end

%group gDisableHints
%hook YTSettings
- (BOOL)areHintsDisabled {
    return 1;
}
- (void)setHintsDisabled:(BOOL)arg1 {
    arg1 = 1;
    %orig;
}
%end
%hook YTUserDefaults
- (BOOL)areHintsDisabled {
    return 1;
}
- (void)setHintsDisabled:(BOOL)arg1 {
    arg1 = 1;
    %orig;
}
%end
%end

%group gHideExploreTab
%hook YTPivotBarView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTPivotBarItemView*>(self, "_itemView2").hidden = YES;
}
- (YTPivotBarItemView*)itemView2 {
    return 1 ? 0 : %orig;
}
%end
%end

%group gHideUploadTab
%hook YTPivotBarView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTPivotBarItemView*>(self, "_itemView3").hidden = YES;
}
- (YTPivotBarItemView*)itemView3 {
    return 1 ? 0 : %orig;
}
%end
%end

%group gHideSubscriptionsTab
%hook YTPivotBarView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTPivotBarItemView*>(self, "_itemView4").hidden = YES;
}
- (YTPivotBarItemView*)itemView4 {
    return 1 ? 0 : %orig;
}
%end
%end

%group gHideLibraryTab
%hook YTPivotBarView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTPivotBarItemView*>(self, "_itemView5").hidden = YES;
}
- (YTPivotBarItemView*)itemView5 {
    return 1 ? 0 : %orig;
}
%end
%end

%group gDisableDoubleTapToSkip
%hook YTDoubleTapToSeekController
- (void)enableDoubleTapToSeek:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
- (void)showDoubleTapToSeekEducationView:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%hook YTSettings
- (BOOL)doubleTapToSeekEnabled {
    return 0;
}
%end
%end

%group gHideOverlayDarkBackground
%hook YTMainAppVideoPlayerOverlayView
- (void)setBackgroundVisible:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%end

%group gAlwaysShowPlayerBar
%hook YTPlayerBarController
- (void)setPlayerViewLayout:(int)arg1 {
    arg1 = 2;
    %orig;
}
%end
%hook YTRelatedVideosViewController
- (BOOL)isEnabled {
    return 0;
}
- (void)setEnabled:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%hook YTFullscreenEngagementOverlayView
- (BOOL)isEnabled {
    return 0;
}
- (void)setEnabled:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%hook YTFullscreenEngagementOverlayController
- (BOOL)isEnabled {
    return 0;
}
- (void)setEnabled:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%hook YTMainAppVideoPlayerOverlayView
- (void)setInfoCardButtonHidden:(BOOL)arg1 {
    arg1 = 1;
    %orig;
}
- (void)setInfoCardButtonVisible:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%hook YTMainAppVideoPlayerOverlayViewController
- (void)adjustPlayerBarPositionForRelatedVideos {
}
%end
%end

%group gEnableiPadStyleOniPhone
%hook UIDevice
- (long long)userInterfaceIdiom {
    return 1;
}
%end
%hook UIStatusBarStyleAttributes
- (long long)idiom {
    return 0;
}
%end
%hook UIKBTree
- (long long)nativeIdiom {
    return 0;
}
%end
%hook UIKBRenderer
- (long long)assetIdiom {
    return 0;
}
%end
%end

%group gHidePreviousButtonInOverlay
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTMainAppControlsOverlayView*>(self, "_previousButton").hidden = YES;
}
%end
%end

%group gHideNextButtonInOverlay
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTMainAppControlsOverlayView*>(self, "_nextButton").hidden = YES;
}
%end
%end

%group gDisableVideoAutoPlay
%hook YTPlaybackConfig
- (void)setStartPlayback:(BOOL)arg1 {
    arg1 = 0;
    %orig;
}
%end
%end

%group gHideAutoPlaySwitchInOverlay
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
    %orig();
    if (![[self autonavSwitch] isHidden])
        [[self autonavSwitch] setHidden:YES];
}
%end
%end

%group gHideCaptionsSubtitlesButtonInOverlay
%hook YTMainAppControlsOverlayView
- (void)layoutSubviews {
    %orig();
    if (![[self closedCaptionsOrSubtitlesButton] isHidden])
        [[self closedCaptionsOrSubtitlesButton] setHidden:YES];
}
%end
%end

%group gDisableVideoInfoCards
%hook YTInfoCardDarkTeaserContainerView
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
- (BOOL)isVisible {
    return 0;
}
%end
%hook YTInfoCardTeaserContainerView
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
- (BOOL)isVisible {
    return 0;
}
%end
%hook YTSimpleInfoCardDarkTeaserView
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
%end
%hook YTSimpleInfoCardTeaserView
- (id)initWithFrame:(CGRect)arg1 {
    return NULL;
}
%end
%hook YTPaidContentOverlayView
- (id)initWithParentResponder:(id)arg1 paidContentRenderer:(id)arg2 enableNewPaidProductDisclosure:(BOOL)arg3 {
    arg2 = NULL;
    arg3 = 0;
    return %orig;
}
%end
%end

%group gNoSearchButton
%hook YTRightNavigationButtons
- (void)layoutSubviews {
    %orig();
    if (![[self searchButton] isHidden])
        [[self searchButton] setHidden:YES];
}
%end
%end

%group gHideTabBarLabels
%hook YTPivotBarItemView
- (void)layoutSubviews {
    %orig();
    [[self navigationButton] setTitle:@"" forState:UIControlStateNormal];
    [[self navigationButton] setTitle:@"" forState:UIControlStateSelected];
}
%end
%end

%group gHideChannelWatermark
%hook YTAnnotationsViewController
- (void)loadFeaturedChannelWatermark {
}
%end
%end

%group gUnlockUHDQuality
%hook YTSettings
- (BOOL)isWebMEnabled {
    return YES;
}
%end
%hook YTUserDefaults
- (int)manualQualitySelectionChosenResolution {
    return 2160;
}
- (int)ml_manualQualitySelectionChosenResolution {
    return 2160;
}
- (int)manualQualitySelectionPrecedingResolution {
    return 2160;
}
- (int)ml_manualQualitySelectionPrecedingResolution {
    return 2160;
}
%end
%hook MLManualFormatSelectionMetadata
- (int)stickyCeilingResolution {
    return 2160;
}
%end
%hook YTIHamplayerStreamFilter
- (BOOL)enableVideoCodecSplicing {
    return YES;
}
- (BOOL)hasVp9 {
    return YES;
}
%end
%hook YTIHamplayerSoftwareStreamFilter
- (int)maxFps {
    return 60;
}
- (int)maxArea {
    return 8294400;
}
%end
%end

%group gHideShortsCameraButton
%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTQTMButton*>(self, "_cameraOrSearchButton").hidden = YES;
}
%end
%end

%group gHideShortsMoreActionsButton
%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTQTMButton*>(self, "_overflowButton").hidden = YES;
}
%end
%end

%group gHideShortsLikeButton
%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTQTMButton*>(self, "_reelLikeButton").hidden = YES;
}
%end
%end

%group gHideShortsDislikeButton
%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTQTMButton*>(self, "_reelDislikeButton").hidden = YES;
}
%end
%end

%group gHideShortsCommentsButton
%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTQTMButton*>(self, "_viewCommentButton").hidden = YES;
}
%end
%end

%group gHideShortsShareButton
%hook YTReelWatchPlaybackOverlayView
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTQTMButton*>(self, "_shareButton").hidden = YES;
}
%end
%end

%group gAutoFullScreen
%hook YTPlayerViewController
- (void)loadWithPlayerTransition:(id)arg1 playbackConfig:(id)arg2 {
    %orig();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      YTWatchController* watchController = [self valueForKey:@"_UIDelegate"];
      [watchController showFullScreen];
    });
}
%end
%end

%group gHideYouTubeLogo
%hook YTHeaderLogoController
- (YTHeaderLogoController*)init {
    return NULL;
}
%end
%end

%group gEnableEnhancedSearchBar
%hook YTColdConfig
- (BOOL)isEnhancedSearchBarEnabled {
    return 1;
}
%end
%end

%group gHideTabBar
%hook YTPivotBarView
- (BOOL)isHidden {
    return 1;
}
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTPivotBarItemView*>(self, "_itemView1").hidden = YES;
    MSHookIvar<YTPivotBarItemView*>(self, "_itemView2").hidden = YES;
    MSHookIvar<YTPivotBarItemView*>(self, "_itemView3").hidden = YES;
    MSHookIvar<YTPivotBarItemView*>(self, "_itemView4").hidden = YES;
    MSHookIvar<YTPivotBarItemView*>(self, "_itemView5").hidden = YES;
}
- (YTPivotBarItemView*)itemView1 {
    return 1 ? 0 : %orig;
}
- (YTPivotBarItemView*)itemView2 {
    return 1 ? 0 : %orig;
}
- (YTPivotBarItemView*)itemView3 {
    return 1 ? 0 : %orig;
}
- (YTPivotBarItemView*)itemView4 {
    return 1 ? 0 : %orig;
}
- (YTPivotBarItemView*)itemView5 {
    return 1 ? 0 : %orig;
}
%end
%end

%group gUseNativeShareSheet
%hook YTShareTargetCell

- (void)drawRect:(CGRect)rect {
    %orig;

    UIView* superview = self.superview;

    if ([superview isKindOfClass:[UICollectionView class]]) {
        UICollectionView* collectionView = (UICollectionView*)superview;
        [collectionView
            setContentOffset:CGPointMake([collectionView contentSize].width - collectionView.frame.size.width, 0)
                    animated:NO];
    }
}

- (void)setEntry:(YTIShareTargetServiceUpdateRenderer*)entry {
    %orig;
    if ([entry serviceId] != 82) {
        return;
    }
    [self didTap];
}
%end

%hook YTShareRequestViewController
- (void)viewDidLoad {
    [self.view setAlpha:0.0];
}
%end
%end

// YTETA: https://github.com/iCrazeiOS/YTETA
%group gShowWhenVideoEnds
%hook YTPlayerViewController
- (void)singleVideo:(id)arg1 currentVideoTimeDidChange:(id)arg2 {
    %orig;

    // Fixes crash with auto-playing videos on the home page
    if ([self.view.overlayView class] != %c(YTMainAppVideoPlayerOverlayView))
        return;

    // Get remaining seconds
    float remainingSeconds = [[self.view.overlayView.playerBar valueForKey:@"_totalTime"] floatValue] -
                             [[self.view.overlayView.playerBar valueForKey:@"_roundedMediaTime"] floatValue];
    float videoSpeed = self.playbackRate;

    // Get time label
    UILabel* progressLabel = self.view.overlayView.playerBar.durationLabel;

    if (![progressLabel.text containsString:@"Ends at"]) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        NSMutableString* formatString = [[NSMutableString alloc] initWithString:@"mm"];

        // Add seconds, if they're enabled
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kShowSeconds"] == YES)
            [formatString appendString:@":ss"];

        // Determine 12h/24h time
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kUse24HourClock"] == YES)
            [formatString insertString:@"HH:" atIndex:0];
        else
            [formatString insertString:@"hh:" atIndex:0];

        // Make NSDateFormatter use time format
        [dateFormatter setDateFormat:formatString];

        // Get time when video ends
        NSString* endsAtString =
            [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:remainingSeconds / videoSpeed]];

        // Update label text
        if (![progressLabel.text containsString:@"Ends at"])
            [progressLabel setText:[NSString stringWithFormat:@"%@ - Ends at: %@", progressLabel.text, endsAtString]];

        // Resize frame so that label fits
        [progressLabel sizeToFit];
    }
}
%end
%end

int selectedTabIndex = 0;

%hook YTPivotBarViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig();
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"kStartupPageInt"]) {
        int selectedTab = [[NSUserDefaults standardUserDefaults] integerForKey:@"kStartupPageInt"];
        if (selectedTab == 0) {
            if (selectedTabIndex == 0) {
                [self selectItemWithPivotIdentifier:@"FEwhat_to_watch"];
                selectedTabIndex = 1;
            }
        }
        if (selectedTab == 1) {
            if (selectedTabIndex == 0) {
                [self selectItemWithPivotIdentifier:@"FEexplore"];
                selectedTabIndex = 1;
            }
        }
        if (selectedTab == 2) {
            if (selectedTabIndex == 0) {
                [self selectItemWithPivotIdentifier:@"FEshorts"];
                selectedTabIndex = 1;
            }
        }
        if (selectedTab == 3) {
            if (selectedTabIndex == 0) {
                [self selectItemWithPivotIdentifier:@"FEuploads"];
                selectedTabIndex = 1;
            }
        }
        if (selectedTab == 4) {
            if (selectedTabIndex == 0) {
                [self selectItemWithPivotIdentifier:@"FEsubscriptions"];
                selectedTabIndex = 1;
            }
        }
        if (selectedTab == 5) {
            if (selectedTabIndex == 0) {
                [self selectItemWithPivotIdentifier:@"FElibrary"];
                selectedTabIndex = 1;
            }
        }
        if (selectedTab == 6) {
            if (selectedTabIndex == 0) {
                [self selectItemWithPivotIdentifier:@"FEtrending"];
                selectedTabIndex = 1;
            }
        }
    }
}
%end

%hook YTColdConfig
- (BOOL)shouldUseAppThemeSetting {
    return 1;
}
- (BOOL)enableYouthereCommandsOnIos {
    return 0;
}
%end

%hook YTYouThereController
- (BOOL)shouldShowYouTherePrompt {
    return 0;
}
%end

%hook YTCommerceEventGroupHandler
- (void)addEventHandlers {
}
%end

%hook YTInterstitialPromoEventGroupHandler
- (void)addEventHandlers {
}
%end

%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial {
    return 1;
}
%end

%hook YTSettings
- (BOOL)allowAudioOnlyManualQualitySelection {
    return 1;
}
%end

%hook YTUpsell
- (BOOL)isCounterfactual {
    return 1;
}
%end

%ctor {
    @autoreleasepool {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:@{
            // General options
            @"kEnableiPadStyleOniPhone" : @NO,
            @"kUnlockUHDQuality" : @NO,
            @"kNoCastButton" : @NO,
            @"kNoNotificationButton" : @NO,
            @"kNoSearchButton" : @NO,
            @"kDisableYouTubeKidsPopup" : @NO,
            @"kDisableHints" : @NO,
            @"kHideYouTubeLogo" : @NO,
            @"kUseNativeShareSheet" : @NO,
            // Video options
            @"kEnableNoVideoAds" : @YES,
            @"kEnableBackgroundPlaybacck" : @NO,
            @"kAllowHDOnCellularData" : @NO,
            @"kAutoFullScreen" : @NO,
            @"kDisableVideoEndscreenPopups" : @NO,
            @"kDisableVideoInfoCards" : @NO,
            @"kDisableVideoAutoPlay" : @NO,
            @"kDisableDoubleTapToSkip" : @NO,
            @"kHideChannelWatermark" : @NO,
            @"kAlwaysShowPlayerBar" : @NO,
            @"kShowWhenVideoEnds" : @NO,
            @"kShowSeconds" : @NO,
            @"kUse24HourClock" : @NO,
            // Under-video options
            @"kNoDownloadButton" : @NO,
            // Overlay options
            @"kShowStatussBarInOverlay" : @NO,
            @"kHidePreviousButtonInOverlay" : @NO,
            @"kHideNextButtonInOverlay" : @NO,
            @"kHideAutoPlaySwitchInOverlay" : @NO,
            @"kHideCaptionsSubtitlesButtonInOverlay" : @NO,
            @"kDisableRelatedVideosInOverlay" : @NO,
            @"kHideOverlayDarkBackground" : @NO,
            // Tabbar options
            @"kStartupPageInt" : @0,
            @"kHideTabBar" : @NO,
            @"kHideTabBarLabels" : @NO,
            @"kHideExploreTab" : @NO,
            @"kHideUploadTab" : @NO,
            @"kHideSubscriptionsTab" : @NO,
            @"kHideLibraryTab" : @NO,
            // Color options
            @"kYTRebornColourOptionsVTwo" : [NSData data],
            // Search options
            @"kEnableEnhancedSearchBar" : @NO,
            @"kDisableVoiceSearch" : @NO,
            // Shorts options
            @"kHideShortsCameraButton" : @NO,
            @"kHideShortsMoreActionsButton" : @NO,
            @"kHideShortsLikeButton" : @NO,
            @"kHideShortsDislikeButton" : @NO,
            @"kHideShortsCommentsButton" : @NO,
            @"kHideShortsShareButton" : @NO,
            // Reborn options
            // TODO: Update paths for rootless jailbreaks
            @"kHideRebornPIPButton" : dlopen("/Library/MobileSubstrate/DynamicLibraries/YouPiP.dylib", RTLD_LAZY) ||
                    dlopen([[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"Frameworks/YouPiP.dylib"]
                               UTF8String],
                           RTLD_LAZY)
                ? @YES
                : @NO,
            @"kHideRebornDWNButton" : @NO,
            @"kHideRebornOPButton" : @NO,
        }];
        [defaults synchronize];
        if ([defaults boolForKey:@"kEnableNoVideoAds"] == YES)
            %init(gNoVideoAds);
        if ([defaults boolForKey:@"kEnableBackgroundPlayback"] == YES)
            %init(gBackgroundPlayback);
        if ([defaults boolForKey:@"kNoDownloadButton"] == YES)
            %init(gNoDownloadButton);
        if ([defaults boolForKey:@"kNoCastButton"] == YES)
            %init(gNoCastButton);
        if ([defaults boolForKey:@"kNoNotificationButton"] == YES)
            %init(gNoNotificationButton);
        if ([defaults boolForKey:@"kAllowHDOnCellularData"] == YES)
            %init(gAllowHDOnCellularData);
        if ([defaults boolForKey:@"kDisableVideoEndscreenPopups"] == YES)
            %init(gDisableVideoEndscreenPopups);
        if ([defaults boolForKey:@"kDisableYouTubeKidsPopup"] == YES)
            %init(gDisableYouTubeKids);
        if ([defaults boolForKey:@"kDisableVoiceSearch"] == YES)
            %init(gDisableVoiceSearch);
        if ([defaults boolForKey:@"kDisableHints"] == YES)
            %init(gDisableHints);
        if ([defaults boolForKey:@"kHideTabBarLabels"] == YES)
            %init(gHideTabBarLabels);
        if ([defaults boolForKey:@"kHideExploreTab"] == YES)
            %init(gHideExploreTab);
        if ([defaults boolForKey:@"kHideUploadTab"] == YES)
            %init(gHideUploadTab);
        if ([defaults boolForKey:@"kHideSubscriptionsTab"] == YES)
            %init(gHideSubscriptionsTab);
        if ([defaults boolForKey:@"kHideLibraryTab"] == YES)
            %init(gHideLibraryTab);
        if ([defaults boolForKey:@"kDisableDoubleTapToSkip"] == YES)
            %init(gDisableDoubleTapToSkip);
        if ([defaults boolForKey:@"kHideOverlayDarkBackground"] == YES)
            %init(gHideOverlayDarkBackground);
        if ([defaults boolForKey:@"kHidePreviousButtonInOverlay"] == YES)
            %init(gHidePreviousButtonInOverlay);
        if ([defaults boolForKey:@"kHideNextButtonInOverlay"] == YES)
            %init(gHideNextButtonInOverlay);
        if ([defaults boolForKey:@"kDisableVideoAutoPlay"] == YES)
            %init(gDisableVideoAutoPlay);
        if ([defaults boolForKey:@"kHideAutoPlaySwitchInOverlay"] == YES)
            %init(gHideAutoPlaySwitchInOverlay);
        if ([defaults boolForKey:@"kHideCaptionsSubtitlesButtonInOverlay"] == YES)
            %init(gHideCaptionsSubtitlesButtonInOverlay);
        if ([defaults boolForKey:@"kDisableVideoInfoCards"] == YES)
            %init(gDisableVideoInfoCards);
        if ([defaults boolForKey:@"kNoSearchButton"] == YES)
            %init(gNoSearchButton);
        if ([defaults boolForKey:@"kHideChannelWatermark"] == YES)
            %init(gHideChannelWatermark);
        if ([defaults boolForKey:@"kUnlockUHDQuality"] == YES)
            %init(gUnlockUHDQuality);
        if ([defaults boolForKey:@"kHideShortsCameraButton"] == YES)
            %init(gHideShortsCameraButton);
        if ([defaults boolForKey:@"kHideShortsMoreActionsButton"] == YES)
            %init(gHideShortsMoreActionsButton);
        if ([defaults boolForKey:@"kHideShortsLikeButton"] == YES)
            %init(gHideShortsLikeButton);
        if ([defaults boolForKey:@"kHideShortsDislikeButton"] == YES)
            %init(gHideShortsDislikeButton);
        if ([defaults boolForKey:@"kHideShortsCommentsButton"] == YES)
            %init(gHideShortsCommentsButton);
        if ([defaults boolForKey:@"kHideShortsShareButton"] == YES)
            %init(gHideShortsShareButton);
        if ([defaults boolForKey:@"kAutoFullScreen"] == YES)
            %init(gAutoFullScreen);
        if ([defaults boolForKey:@"kHideYouTubeLogo"] == YES)
            %init(gHideYouTubeLogo);
        if ([defaults boolForKey:@"kEnableEnhancedSearchBar"] == YES)
            %init(gEnableEnhancedSearchBar);
        if ([defaults boolForKey:@"kHideTabBar"] == YES)
            %init(gHideTabBar);
        if ([defaults boolForKey:@"kUseNativeShareSheet"] == YES)
            %init(gUseNativeShareSheet);
        if ([defaults boolForKey:@"kShowWhenVideoEnds"] == YES)
            %init(gShowWhenVideoEnds);
        if ([defaults boolForKey:@"kEnableiPadStyleOniPhone"] == NO &
            [defaults boolForKey:@"kShowStatusBarInOverlay"] == YES) {
            %init(gShowStatusBarInOverlay);
        }
        if ([defaults boolForKey:@"kShowStatusBarInOverlay"] == YES &
                [defaults boolForKey:@"kEnableiPadStyleOniPhone"] == YES ||
            [defaults boolForKey:@"kEnableiPadStyleOniPhone"] == YES &
                [defaults boolForKey:@"kShowStatusBarInOverlay"] == NO) {
            %init(gEnableiPadStyleOniPhone);
        }
        if ([defaults boolForKey:@"kAlwaysShowPlayerBar"] == NO &
            [defaults boolForKey:@"kDisableRelatedVideosInOverlay"] == YES) {
            %init(gDisableRelatedVideosInOverlay);
        }
        if ([defaults boolForKey:@"kAlwaysShowPlayerBar"] == YES &
                [defaults boolForKey:@"kDisableRelatedVideosInOverlay"] == YES ||
            [defaults boolForKey:@"kAlwaysShowPlayerBar"] == YES &
                [defaults boolForKey:@"kDisableRelatedVideosInOverlay"] == NO) {
            %init(gAlwaysShowPlayerBar);
        }
        %init(_ungrouped);
    }
}
