#import "SponsorBlock.h"

SponsorBlockClient* sbclient;

%group gRebornSponsorBlock
%hook YTPlayerViewController
%property(strong, nonatomic) NSArray* skipSegments;
%property(nonatomic, assign) NSInteger currentSponsorSegment;
%property(nonatomic, assign) NSInteger unskippedSegment;

- (void)playbackController:(id)arg1 didActivateVideo:(id)arg2 withPlaybackData:(id)arg3 {
    %orig;
    if (!self.isPlayingAd && [self.view.overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]) {
        [sbclient getSponsorSegments:self.currentVideoID
                 useSHA256HashPrefix:YES
                             handler:^(NSArray<SponsorSegment*>* sponsorSegments, NSError* error) {
                               if (error == nil) {
                                   NSLog(@"[YouTube Reborn] [SponsorBlock] Found %lu segments for %@",
                                         (unsigned long)sponsorSegments.count, self.currentVideoID);
                                   self.skipSegments = sponsorSegments;
                               }
                             }];
        self.currentSponsorSegment = 0;
        self.unskippedSegment = -1;
    }
}

- (void)singleVideo:(id)arg1 currentVideoTimeDidChange:(YTSingleVideoTime*)arg2 {
    %orig;
    id overlayView = self.view.overlayView;
    if (self.skipSegments.count > 0 && [overlayView isKindOfClass:%c(YTMainAppVideoPlayerOverlayView)]) {
        SponsorSegment* sponsorSegment;
        if (self.currentSponsorSegment <= self.skipSegments.count - 1) {
            sponsorSegment = self.skipSegments[self.currentSponsorSegment];
        }
        if ((ceil(sponsorSegment.startTime) == lroundf(arg2.time) && arg2.time >= sponsorSegment.startTime) ||
            (ceil(sponsorSegment.startTime) <= lroundf(arg2.time) && arg2.time < sponsorSegment.endTime)) {
            // Handle edge case where the segment end time is longer than the video duration
            CGFloat _endTime = sponsorSegment.endTime > self.currentVideoTotalMediaTime
                                   ? self.currentVideoTotalMediaTime
                                   : sponsorSegment.endTime;
            NSLog(@"[YouTube Reborn] [SponsorBlock] Skipping segment %ld which starts at %f and ends at %f",
                  (long)self.currentSponsorSegment, sponsorSegment.startTime, _endTime);
            [self scrubToTime:_endTime];
            if (self.currentSponsorSegment <= self.skipSegments.count - 1)
                self.currentSponsorSegment++;
        } else if (lroundf(arg2.time) > sponsorSegment.startTime &&
                   self.currentSponsorSegment < self.skipSegments.count - 1) {
            self.currentSponsorSegment++;
        } else if (self.currentSponsorSegment == 0 && self.unskippedSegment != -1) {
            self.currentSponsorSegment++;
        } else if (self.currentSponsorSegment > 0 &&
                   lroundf(arg2.time) < self.skipSegments[self.currentSponsorSegment - 1].endTime) {
            if (self.MDXActive) {
                // Do nothing bruh
            } else if (self.unskippedSegment != self.currentSponsorSegment - 1) {
                self.currentSponsorSegment--;
            } else if (arg2.time < self.skipSegments[self.currentSponsorSegment - 1].startTime - 0.01) {
                self.unskippedSegment = -1;
            }
        }
    }
}
%end
%end

%ctor {
    @autoreleasepool {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:@{
            @"kRebornSponsorBlockEnabled" : @YES,
            @"kRebornSponsorBlockUserID" : [[NSUUID UUID] UUIDString],
            @"kRebornSponsorBlockAPIURL" : @"https://sponsor.ajay.app",
            @"kRebornSponsorBlockTimeSaved" : @0.0f,
            @"kRebornSponsorBlockMinimumSegmentDuration" : @0.0f,
            @"kRebornSponsorBlockShowSkipNotice" : @YES,
            @"kRebornSponsorBlockShowButtonsInPlayer" : @YES,
            @"kRebornSponsorBlockShowModifiedTime" : @YES,
            @"kRebornSponsorBlockSkipTimeTracking" : @YES,
            @"kRebornSponsorBlockSkipNoticeDuration" : @2.0f,
            @"kRebornSponsorBlockWhitelistedChannels" : @[],
            @"kRebornSponsorBlockSponsor" : @{
                @"categoryName" : @"sponsor",
                @"status" : @1,
                @"color" : @"#00D400",
                @"unsubmittedColor" : @"#007800",
            },
            @"kRebornSponsorBlockSelfPromo" : @{
                @"categoryName" : @"selfpromo",
                @"status" : @1,
                @"color" : @"#FFFF00",
                @"unsubmittedColor" : @"#BFBF35",
            },
            @"kRebornSponsorBlockHighlight" : @{
                @"categoryName" : @"poi_highlight",
                @"status" : @1,
                @"color" : @"#FF1684",
                @"unsubmittedColor" : @"#9B044C",
            },
            @"kRebornSponsorBlockIntro" : @{
                @"categoryName" : @"intro",
                @"status" : @1,
                @"color" : @"#00FFFF",
                @"unsubmittedColor" : @"BFBF35",
            },
            @"kRebornSponsorBlockOutro" : @{
                @"categoryName" : @"outro",
                @"status" : @1,
                @"color" : @"#0202ED",
                @"unsubmittedColor" : @"#000070",
            },
            @"kRebornSponsorBlockPreview" : @{
                @"categoryName" : @"preview",
                @"status" : @1,
                @"color" : @"#008FD6",
                @"unsubmittedColor" : @"#005799",
            },
            @"kRebornSponsorBlockFiller" : @{
                @"categoryName" : @"filler",
                @"status" : @1,
                @"color" : @"#7300FF",
                @"unsubmittedColor" : @"#2E8066",
            },
            @"kRebornSponsorBlockOffTopic" : @{
                @"categoryName" : @"music_offtopic",
                @"status" : @1,
                @"color" : @"#FF9900",
                @"unsubmittedColor" : @"#A6634A",
            },
        }];
        [defaults synchronize];
        if ([defaults objectForKey:@"kRebornSponsorBlockEnabled"]) {
            NSString* _userID = [defaults objectForKey:@"kRebornSponsorBlockUserID"];
            NSString* _apiURL = [defaults objectForKey:@"kRebornSponsorBlockAPIURL"];
            NSArray* _categorySettings = @[
                @"kRebornSponsorBlockSponsor",
                @"kRebornSponsorBlockSelfPromo",
                @"kRebornSponsorBlockHighlight",
                @"kRebornSponsorBlockIntro",
                @"kRebornSponsorBlockOutro",
                @"kRebornSponsorBlockPreview",
                @"kRebornSponsorBlockFiller",
                @"kRebornSponsorBlockOffTopic",
            ];
            NSMutableArray* _categories = [[NSMutableArray alloc] init];
            for (id key in _categorySettings) {
                if ([[defaults objectForKey:key][@"status"] integerValue] != 0) {
                    [_categories addObject:[defaults objectForKey:key][@"categoryName"]];
                }
            }
            NSLog(@"[YouTube Reborn] Activating SponsorBlock with user ID %@, endpoint %@, categories %@", _userID,
                  _apiURL, _categories);
            sbclient = [[SponsorBlockClient alloc] initWithUserID:_userID apiURL:_apiURL categories:_categories.copy];
            %init(gRebornSponsorBlock);
        }
    }
}
