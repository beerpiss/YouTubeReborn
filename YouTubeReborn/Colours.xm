#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Tweak.h"
UIColor* hexColour() {
    NSData* colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"kYTRebornColourOptionsVTwo"];
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:colorData error:nil];
    [unarchiver setRequiresSecureCoding:NO];
    return [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
}

%group gColourOptions
%hook UIView
- (void)setBackgroundColor:(UIColor*)color {
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTPivotBarView")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTSlideForActionsView")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTChipCloudCell")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTEngagementPanelView")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTPlaylistPanelProminentThumbnailVideoCell")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTPlaylistHeaderView")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTAsyncCollectionView")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTLinkCell")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTMessageCell")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTSearchView")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTDrawerAvatarCell")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTFeedHeaderView")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatTextCell")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatViewerEngagementCell")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTCommentsHeaderView")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatView")]) {
        color = hexColour();
    }
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YCHLiveChatTickerViewController")]) {
        color = hexColour();
    }
    %orig;
}
- (void)layoutSubviews {
    %orig();
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"_ASDisplayView")]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    }
}
%end
%hook YTAsyncCollectionView
- (void)setBackgroundColor:(UIColor*)color {
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTRelatedVideosCollectionViewController")]) {
        color = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    } else if ([self.nextResponder
                   isKindOfClass:NSClassFromString(@"YTFullscreenMetadataHighlightsCollectionViewController")]) {
        color = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    } else {
        color = hexColour();
    }
    %orig;
}
%end
%hook YTPivotBarView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTHeaderView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTSubheaderContainerView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTAppView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTChannelListSubMenuView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTSlideForActionsView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTPageView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTWatchView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTPlaylistMiniBarView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTEngagementPanelHeaderView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTPlaylistPanelControlsView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTHorizontalCardListView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTWatchMiniBarView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTCreateCommentAccessoryView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTCreateCommentTextView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTSearchView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTVideoView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTSearchBoxView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTTabTitlesView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTPrivacyTosFooterView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTOfflineStorageUsageView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTInlineSignInView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTFeedChannelFilterHeaderView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YCHLiveChatView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YCHLiveChatActionPanelView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTEmojiTextView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTTopAlignedView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
- (void)layoutSubviews {
    %orig();
    MSHookIvar<YTTopAlignedView*>(self, "_contentView").backgroundColor = hexColour();
}
%end
%hook GOODialogView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTNavigationBar
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
- (void)setBarTintColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTChannelMobileHeaderView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTChannelSubMenuView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTWrapperSplitView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTReelShelfCell
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTReelShelfItemView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTReelShelfView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YTCommentView
- (void)setBackgroundColor:(UIColor*)color {
    color = hexColour();
    %orig;
}
%end
%hook YCHLiveChatBannerCell
- (void)layoutSubviews {
    %orig();
    MSHookIvar<UIImageView*>(self, "_bannerContainerImageView").hidden = YES;
    MSHookIvar<UIView*>(self, "_bannerContainerView").backgroundColor = hexColour();
}
%end
%hook YTSearchSuggestionCollectionViewCell
- (void)updateColors {
}
%end
%end

%ctor {
    @autoreleasepool {
        NSData* colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"kYTRebornColourOptionsVTwo"];
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:colorData error:nil];
        [unarchiver setRequiresSecureCoding:NO];
        NSString* hexString = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
        if (hexString != nil) {
            %init(gColourOptions);
        }
    }
}
