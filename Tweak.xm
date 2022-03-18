#import <AFNetworking/AFNetworking.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <MediaRemote/MediaRemote.h>
#import <UIKit/UIKit.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import <dlfcn.h>
#import "Controllers/PictureInPictureController.h"
#import "Controllers/RootOptionsController.h"
#import "DTTJailbreakDetection/DTTJailbreakDetection.h"
#import "Tweak.h"

NSString* YTApiKey = @"AIzaSyCGZHGUPP9wojQDfrwPEr7Pr-mhBanHAb8";

UIColor* hexColour() {
    NSData* colorData = [[NSUserDefaults standardUserDefaults] objectForKey:@"kYTRebornColourOptionsVTwo"];
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:colorData error:nil];
    [unarchiver setRequiresSecureCoding:NO];
    return [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
}

YTLocalPlaybackController* playingVideoID;

%hook YTLocalPlaybackController
- (NSString*)currentVideoID {
    playingVideoID = self;
    return %orig;
}
%end

YTMainAppVideoPlayerOverlayViewController* resultOut;
YTMainAppVideoPlayerOverlayViewController* layoutOut;
YTMainAppVideoPlayerOverlayViewController* stateOut;

%hook YTMainAppVideoPlayerOverlayViewController
- (CGFloat)mediaTime {
    resultOut = self;
    return %orig;
}
- (int)playerViewLayout {
    layoutOut = self;
    return %orig;
}
- (NSInteger)playerState {
    stateOut = self;
    return %orig;
}
%end

YTUserDefaults* ytThemeSettings;

%hook YTUserDefaults
- (long long)appThemeSetting {
    ytThemeSettings = self;
    return %orig;
}
%end

%hook YTWrapperView
- (void)layoutSubviews {
    %orig();
    if ([self.nextResponder isKindOfClass:NSClassFromString(@"YTSettingsViewController")]) {
        UIView* childView = MSHookIvar<UIView*>(self, "_childView");
        childView.frame =
            CGRectMake(childView.frame.origin.x, 51, childView.frame.size.width, childView.frame.size.height);

        long long ytDarkModeCheck = [ytThemeSettings appThemeSetting];

        UIView* rebornView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, childView.bounds.size.width, 51)];
        [rebornView setUserInteractionEnabled:YES];
        rebornView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];

        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, rebornView.frame.size.width, 51)];
        label.text = @"YT Reborn Settings";
        if (ytDarkModeCheck == 0 || ytDarkModeCheck == 1) {
            if (UIScreen.mainScreen.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                label.textColor = [UIColor blackColor];
            } else {
                label.textColor = [UIColor whiteColor];
            }
        }
        if (ytDarkModeCheck == 2) {
            label.textColor = [UIColor blackColor];
        }
        if (ytDarkModeCheck == 3) {
            label.textColor = [UIColor whiteColor];
        }
        [label setFont:[UIFont systemFontOfSize:16]];
        [rebornView addSubview:label];

        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button addTarget:self action:@selector(rootOptionsAction:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, rebornView.frame.size.width, 51);
        [rebornView addSubview:button];

        [self addSubview:rebornView];
    }
}
%new
;
- (void)rootOptionsAction:(id)sender {
    RootOptionsController* rootOptionsController = [[RootOptionsController alloc] init];
    UINavigationController* rootOptionsControllerView =
        [[UINavigationController alloc] initWithRootViewController:rootOptionsController];
    rootOptionsControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

    UIViewController* rootPrefsViewController = self._viewControllerForAncestor;
    [rootPrefsViewController presentViewController:rootOptionsControllerView animated:YES completion:nil];
}
%end

%hook SSOKeychain
+ (id)accessGroup {
    if (![DTTJailbreakDetection isJailbroken]) {
        NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSString*)kSecClassGenericPassword,
                                                                         (__bridge NSString*)kSecClass, @"bundleSeedID",
                                                                         kSecAttrAccount, @"", kSecAttrService,
                                                                         (id)kCFBooleanTrue, kSecReturnAttributes, nil];
        CFDictionaryRef result = nil;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&result);
        if (status == errSecItemNotFound)
            status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef*)&result);
        if (status != errSecSuccess)
            return nil;
        NSString* accessGroup = [(__bridge NSDictionary*)result objectForKey:(__bridge NSString*)kSecAttrAccessGroup];

        return accessGroup;
    }
    return %orig;
}
+ (id)sharedAccessGroup {
    if (![DTTJailbreakDetection isJailbroken]) {
        NSDictionary* query = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSString*)kSecClassGenericPassword,
                                                                         (__bridge NSString*)kSecClass, @"bundleSeedID",
                                                                         kSecAttrAccount, @"", kSecAttrService,
                                                                         (id)kCFBooleanTrue, kSecReturnAttributes, nil];
        CFDictionaryRef result = nil;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&result);
        if (status == errSecItemNotFound)
            status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef*)&result);
        if (status != errSecSuccess)
            return nil;
        NSString* accessGroup = [(__bridge NSDictionary*)result objectForKey:(__bridge NSString*)kSecAttrAccessGroup];

        return accessGroup;
    }
    return %orig;
}
%end

NSMutableArray* _overlayButtons = [NSMutableArray array];
NSDictionary* _overlaySelectors = @{
    @"DWN" : [NSValue valueWithPointer:@selector(optionsAction:)],
    @"OP" : [NSValue valueWithPointer:@selector(playInApp)],
    @"PIP" : [NSValue valueWithPointer:@selector(pictureInPicture)],
};
NSString* pipTime;
NSURL* pipURL;

%hook YTMainAppControlsOverlayView
%property(retain, nonatomic) UIButton* overlayButtonOne;
%property(retain, nonatomic) UIButton* overlayButtonTwo;
%property(retain, nonatomic) UIButton* overlayButtonThree;

- (id)initWithDelegate:(id)delegate {
    self = %orig;
    if (self) {
        CGFloat _overlayButtonsY = 9;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kShowStatusBarInOverlay"]) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableiPadStyleOniPhone"]) {
                _overlayButtonsY = 24;
            }
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideRebornDWNButton"] == NO) {
            [_overlayButtons addObject:@"DWN"];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideRebornOPButton"] == NO) {
            [_overlayButtons addObject:@"OP"];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kHideRebornPIPButton"] == NO) {
            [_overlayButtons addObject:@"PIP"];
        }
        int _overlayButtonsCount = [_overlayButtons count];
        for (int i = 0; i < _overlayButtonsCount; i++) {
            switch (i) {
                case 0:
                    NSLog(@"[YouTube Reborn] Creating overlay button %d: %@", i, _overlayButtons[i]);
                    self.overlayButtonOne = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [self.overlayButtonOne
                               addTarget:self
                                  action:(SEL)[[_overlaySelectors objectForKey:_overlayButtons[i]] pointerValue]
                        forControlEvents:UIControlEventTouchUpInside];
                    [self.overlayButtonOne setTitle:_overlayButtons[i] forState:UIControlStateNormal];
                    NSLog(@"[YouTube Reborn] Inserting overlay button %d to view: %@", i, self.overlayButtonOne);
                    self.overlayButtonOne.frame = CGRectMake((CGFloat)40 + 45 * i, _overlayButtonsY, 40.0, 30.0);
                    [self addSubview:self.overlayButtonOne];
                    break;
                case 1:
                    NSLog(@"[YouTube Reborn] Creating overlay button %d: %@", i, _overlayButtons[i]);
                    self.overlayButtonTwo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [self.overlayButtonTwo
                               addTarget:self
                                  action:(SEL)[[_overlaySelectors objectForKey:_overlayButtons[i]] pointerValue]
                        forControlEvents:UIControlEventTouchUpInside];
                    [self.overlayButtonTwo setTitle:_overlayButtons[i] forState:UIControlStateNormal];
                    NSLog(@"[YouTube Reborn] Inserting overlay button %d to view: %@", i, self.overlayButtonTwo);
                    self.overlayButtonTwo.frame = CGRectMake((CGFloat)40 + 45 * i, _overlayButtonsY, 40.0, 30.0);
                    [self addSubview:self.overlayButtonTwo];
                    break;
                case 2:
                    NSLog(@"[YouTube Reborn] Creating overlay button %d: %@", i, _overlayButtons[i]);
                    self.overlayButtonThree = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    [self.overlayButtonThree
                               addTarget:self
                                  action:(SEL)[[_overlaySelectors objectForKey:_overlayButtons[i]] pointerValue]
                        forControlEvents:UIControlEventTouchUpInside];
                    [self.overlayButtonThree setTitle:_overlayButtons[i] forState:UIControlStateNormal];
                    NSLog(@"[YouTube Reborn] Inserting overlay button %d to view: %@", i, self.overlayButtonThree);
                    self.overlayButtonThree.frame = CGRectMake((CGFloat)40 + 45 * i, _overlayButtonsY, 40.0, 30.0);
                    [self addSubview:self.overlayButtonThree];
                    break;
                default:
                    break;
            }
        }
    }
    return self;
}

- (void)setTopOverlayVisible:(BOOL)visible isAutonavCanceledState:(BOOL)canceledState {
    int _overlayButtonsCount = [_overlayButtons count];
    int rotation = [layoutOut playerViewLayout];
    for (int i = 0; i < _overlayButtonsCount; i++) {
        switch (i) {
            case 0:
                if (canceledState)
                    self.overlayButtonOne.alpha = 0.0;
                else if (!self.overlayButtonOne.hidden)
                    self.overlayButtonOne.alpha = rotation == 2 ? (visible ? 1.0 : 0.0) : 0.0;
                break;
            case 1:
                if (canceledState)
                    self.overlayButtonTwo.alpha = 0.0;
                else if (!self.overlayButtonTwo.hidden)
                    self.overlayButtonTwo.alpha = rotation == 2 ? (visible ? 1.0 : 0.0) : 0.0;
                break;
            case 2:
                if (canceledState)
                    self.overlayButtonThree.alpha = 0.0;
                else if (!self.overlayButtonThree.hidden)
                    self.overlayButtonThree.alpha = rotation == 2 ? (visible ? 1.0 : 0.0) : 0.0;
                break;
            default:
                break;
        }
    }
    %orig;
}

%new
;
- (void)playInApp {
    NSInteger videoStatus = [stateOut playerState];
    if (videoStatus == 3) {
        MRMediaRemoteSendCommand(MRMediaRemoteCommandPause, 0);
    }

    NSString* videoIdentifier = [playingVideoID currentVideoID];

    [[XCDYouTubeClient defaultClient]
        getVideoWithIdentifier:videoIdentifier
             completionHandler:^(XCDYouTubeVideo* video, NSError* error) {
               if (video) {
                   NSDictionary* streamURLs = video.streamURLs;
                   NSURL* streamURL = streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming];

                   if (streamURL != NULL) {
                       UIAlertController* alertMenu =
                           [UIAlertController alertControllerWithTitle:@"Options"
                                                               message:nil
                                                        preferredStyle:UIAlertControllerStyleAlert];

                       [alertMenu
                           addAction:[UIAlertAction
                                         actionWithTitle:@"Play In Infuse"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction* action) {
                                                   [[UIApplication sharedApplication]
                                                                 openURL:[NSURL URLWithString:
                                                                                    [NSString
                                                                                        stringWithFormat:
                                                                                            @"infuse://x-callback-url/"
                                                                                            @"play?url=%@",
                                                                                            streamURL]]
                                                                 options:@{}
                                                       completionHandler:nil];
                                                 }]];

                       [alertMenu
                           addAction:[UIAlertAction
                                         actionWithTitle:@"Play In VLC"
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction* action) {
                                                   [[UIApplication sharedApplication]
                                                                 openURL:[NSURL
                                                                             URLWithString:[NSString
                                                                                               stringWithFormat:
                                                                                                   @"vlc-x-callback://"
                                                                                                   @"x-callback-url/"
                                                                                                   @"stream?url=%@",
                                                                                                   streamURL]]
                                                                 options:@{}
                                                       completionHandler:nil];
                                                 }]];

                       [alertMenu addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction* action){
                                                                   }]];

                       UIViewController* menuViewController = self._viewControllerForAncestor;
                       [menuViewController presentViewController:alertMenu animated:YES completion:nil];
                   } else {
                       UIAlertController* alertFailed =
                           [UIAlertController alertControllerWithTitle:@"Notice"
                                                               message:@"This video is not supported by Infuse or VLC"
                                                        preferredStyle:UIAlertControllerStyleAlert];

                       [alertFailed addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction* action){
                                                                     }]];

                       UIViewController* failedViewController = self._viewControllerForAncestor;
                       [failedViewController presentViewController:alertFailed animated:YES completion:nil];
                   }
               } else {
                   UIAlertController* alertError =
                       [UIAlertController alertControllerWithTitle:@"Notice"
                                                           message:@"Unable to fetch youtube video url from googles api"
                                                    preferredStyle:UIAlertControllerStyleAlert];

                   [alertError addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction* action){
                                                                }]];

                   UIViewController* errorViewController = self._viewControllerForAncestor;
                   [errorViewController presentViewController:alertError animated:YES completion:nil];
               }
             }];
}

%new
;
- (void)optionsAction:(id)sender {
    NSInteger videoStatus = [stateOut playerState];
    if (videoStatus == 3) {
        MRMediaRemoteSendCommand(MRMediaRemoteCommandPause, 0);
    }

    UIAlertController* alertMenu = [UIAlertController alertControllerWithTitle:@"Options"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];

    [alertMenu addAction:[UIAlertAction actionWithTitle:@"Download Audio (M4A Audio)"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction* action) {
                                                  [self audioDownloader];
                                                }]];

    [alertMenu addAction:[UIAlertAction actionWithTitle:@"Download Video (MP4 Video)"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction* action) {
                                                  [self videoDownloader];
                                                }]];

    [alertMenu addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction* action){
                                                }]];

    UIViewController* menuViewController = self._viewControllerForAncestor;
    [menuViewController presentViewController:alertMenu animated:YES completion:nil];
}

%new
;
- (void)audioDownloader {
    NSInteger videoStatus = [stateOut playerState];
    if (videoStatus == 3) {
        MRMediaRemoteSendCommand(MRMediaRemoteCommandPause, 0);
    }

    NSString* videoIdentifier = [playingVideoID currentVideoID];

    [[XCDYouTubeClient defaultClient]
        getVideoWithIdentifier:videoIdentifier
             completionHandler:^(XCDYouTubeVideo* video, NSError* error) {
               if (video) {
                   NSDictionary* streamURLs = video.streamURLs;
                   NSURL *streamURL = streamURLs[@(XCDYouTubeVideoQualityHD720)] ?: streamURLs[@(XCDYouTubeVideoQualityMedium360)] ?: streamURLs[@(XCDYouTubeVideoQualitySmall240)];

                   if (streamURL != NULL) {
                       NSURLSessionConfiguration* dataConfiguration =
                           [NSURLSessionConfiguration defaultSessionConfiguration];
                       AFURLSessionManager* dataManager =
                           [[AFURLSessionManager alloc] initWithSessionConfiguration:dataConfiguration];

                       NSString* apiUrl = [NSString
                           stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=snippet&id=%@&key=%@",
                                            videoIdentifier, YTApiKey];
                       NSURL* dataUrl = [NSURL URLWithString:apiUrl];
                       NSURLRequest* apiRequest = [NSURLRequest requestWithURL:dataUrl];

                       NSURLSessionDataTask* dataTask = [dataManager
                           dataTaskWithRequest:apiRequest
                                uploadProgress:nil
                              downloadProgress:nil
                             completionHandler:^(NSURLResponse* response, id responseObject, NSError* error) {
                               if (error) {
                                   NSLog(@"Error: %@", error);
                               } else {
                                   NSMutableDictionary* jsonResponse = responseObject;
                                   NSArray* items = [jsonResponse objectForKey:@"items"];
                                   NSString* escapedString;
                                   for (NSDictionary* item in items) {
                                       NSDictionary* snippet = [item objectForKey:@"snippet"];
                                       NSString* title = [snippet objectForKey:@"title"];
                                       NSCharacterSet* notAllowedChars =
                                           [[NSCharacterSet alphanumericCharacterSet] invertedSet];
                                       escapedString = [[title componentsSeparatedByCharactersInSet:notAllowedChars]
                                           componentsJoinedByString:@""];
                                   }

                                   UIAlertController* alertDownloading = [UIAlertController
                                       alertControllerWithTitle:@"Notice"
                                                        message:[NSString stringWithFormat:
                                                                              @"Audio Is Downloading \n\nProgress: "
                                                                              @"0.00%% \n\nDon't Exit The App"]
                                                 preferredStyle:UIAlertControllerStyleAlert];
                                   UIViewController* downloadingViewController = self._viewControllerForAncestor;
                                   [downloadingViewController presentViewController:alertDownloading
                                                                           animated:YES
                                                                         completion:nil];

                                   NSURLSessionConfiguration* configuration =
                                       [NSURLSessionConfiguration defaultSessionConfiguration];
                                   AFURLSessionManager* manager =
                                       [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                                   NSURLRequest* request = [NSURLRequest requestWithURL:streamURL];

                                   NSURLSessionDownloadTask* downloadTask = [manager downloadTaskWithRequest:request
                                       progress:^(NSProgress* _Nonnull downloadProgress) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                           float downloadPercent = downloadProgress.fractionCompleted * 100;
                                           alertDownloading.message = [NSString
                                               stringWithFormat:
                                                   @"Audio Is Downloading \n\nProgress: %.02f%% \n\nDon't Exit The App",
                                                   downloadPercent];
                                         });
                                       }
                                       destination:^NSURL*(NSURL* targetPath, NSURLResponse* response) {
                                         NSURL* documentsDirectoryURL =
                                             [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                    inDomain:NSUserDomainMask
                                                                           appropriateForURL:nil
                                                                                      create:NO
                                                                                       error:nil];
                                         return [documentsDirectoryURL
                                             URLByAppendingPathComponent:[response suggestedFilename]];
                                       }
                                       completionHandler:^(NSURLResponse* response, NSURL* filePath, NSError* error) {
                                         NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                                              NSUserDomainMask, YES);
                                         NSString* documentsDirectory = [paths objectAtIndex:0];

                                         NSURL* outputURL =
                                             [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/videoplayback.m4a",
                                                                                               documentsDirectory]];
                                         NSURL* inputURL =
                                             [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/videoplayback.mp4",
                                                                                               documentsDirectory]];
                                         AVAsset* asset = [AVAsset assetWithURL:inputURL];

                                         AVAssetExportSession* session = [[AVAssetExportSession alloc]
                                             initWithAsset:asset
                                                presetName:AVAssetExportPresetPassthrough];
                                         session.outputURL = outputURL;
                                         session.outputFileType = AVFileTypeAppleM4A;

                                         [session exportAsynchronouslyWithCompletionHandler:^{
                                           if (session.status == AVAssetExportSessionStatusCompleted) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                 NSString* oldVideoName = [NSString
                                                     stringWithFormat:@"%@/videoplayback.mp4", documentsDirectory];
                                                 NSString* oldName = [NSString
                                                     stringWithFormat:@"%@/videoplayback.m4a", documentsDirectory];
                                                 NSString* newName = [NSString
                                                     stringWithFormat:@"%@/%@.m4a", documentsDirectory, escapedString];
                                                 [[NSFileManager defaultManager] removeItemAtPath:oldVideoName
                                                                                            error:nil];
                                                 [[NSFileManager defaultManager] moveItemAtPath:oldName
                                                                                         toPath:newName
                                                                                          error:nil];
                                                 [alertDownloading dismissViewControllerAnimated:YES completion:nil];
                                                 UIAlertController* alertDownloaded = [UIAlertController
                                                     alertControllerWithTitle:@"Notice"
                                                                      message:@"Audio Download Complete"
                                                               preferredStyle:UIAlertControllerStyleAlert];

                                                 [alertDownloaded
                                                     addAction:[UIAlertAction
                                                                   actionWithTitle:@"Finish"
                                                                             style:UIAlertActionStyleCancel
                                                                           handler:^(UIAlertAction* _Nonnull action){
                                                                           }]];

                                                 UIViewController* downloadedViewController =
                                                     self._viewControllerForAncestor;
                                                 [downloadedViewController presentViewController:alertDownloaded
                                                                                        animated:YES
                                                                                      completion:nil];
                                               });
                                           }
                                         }];
                                       }];
                                   [downloadTask resume];
                               }
                             }];
                       [dataTask resume];
                   } else {
                       UIAlertController* alertFailed =
                           [UIAlertController alertControllerWithTitle:@"Notice"
                                                               message:@"This video is not supported by the downloader"
                                                        preferredStyle:UIAlertControllerStyleAlert];

                       [alertFailed addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction* action){
                                                                     }]];

                       UIViewController* failedViewController = self._viewControllerForAncestor;
                       [failedViewController presentViewController:alertFailed animated:YES completion:nil];
                   }
               } else {
                   UIAlertController* alertUrlError =
                       [UIAlertController alertControllerWithTitle:@"Notice"
                                                           message:@"Unable to fetch youtube video url from googles api"
                                                    preferredStyle:UIAlertControllerStyleAlert];

                   [alertUrlError addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction* action){
                                                                   }]];

                   UIViewController* urlErrorViewController = self._viewControllerForAncestor;
                   [urlErrorViewController presentViewController:alertUrlError animated:YES completion:nil];
               }
             }];
}

%new
;
- (void)videoDownloader {
    NSInteger videoStatus = [stateOut playerState];
    if (videoStatus == 3) {
        MRMediaRemoteSendCommand(MRMediaRemoteCommandPause, 0);
    }

    NSString* videoIdentifier = [playingVideoID currentVideoID];

    [[XCDYouTubeClient defaultClient]
        getVideoWithIdentifier:videoIdentifier
             completionHandler:^(XCDYouTubeVideo* video, NSError* error) {
               if (video) {
                   NSDictionary* streamURLs = video.streamURLs;
                   NSURL *streamURL = streamURLs[@(XCDYouTubeVideoQualityHD720)] ?: streamURLs[@(XCDYouTubeVideoQualityMedium360)] ?: streamURLs[@(XCDYouTubeVideoQualitySmall240)];

                   if (streamURL != NULL) {
                       NSURLSessionConfiguration* dataConfiguration =
                           [NSURLSessionConfiguration defaultSessionConfiguration];
                       AFURLSessionManager* dataManager =
                           [[AFURLSessionManager alloc] initWithSessionConfiguration:dataConfiguration];

                       NSString* apiUrl = [NSString
                           stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=snippet&id=%@&key=%@",
                                            videoIdentifier, YTApiKey];
                       NSURL* dataUrl = [NSURL URLWithString:apiUrl];
                       NSURLRequest* apiRequest = [NSURLRequest requestWithURL:dataUrl];

                       NSURLSessionDataTask* dataTask = [dataManager
                           dataTaskWithRequest:apiRequest
                                uploadProgress:nil
                              downloadProgress:nil
                             completionHandler:^(NSURLResponse* response, id responseObject, NSError* error) {
                               if (error) {
                                   NSLog(@"Error: %@", error);
                               } else {
                                   NSMutableDictionary* jsonResponse = responseObject;
                                   NSArray* items = [jsonResponse objectForKey:@"items"];
                                   NSString* escapedString;
                                   for (NSDictionary* item in items) {
                                       NSDictionary* snippet = [item objectForKey:@"snippet"];
                                       NSString* title = [snippet objectForKey:@"title"];
                                       NSCharacterSet* notAllowedChars =
                                           [[NSCharacterSet alphanumericCharacterSet] invertedSet];
                                       escapedString = [[title componentsSeparatedByCharactersInSet:notAllowedChars]
                                           componentsJoinedByString:@""];
                                   }

                                   UIAlertController* alertDownloading = [UIAlertController
                                       alertControllerWithTitle:@"Notice"
                                                        message:[NSString stringWithFormat:
                                                                              @"Video Is Downloading \n\nProgress: "
                                                                              @"0.00%% \n\nDon't Exit The App"]
                                                 preferredStyle:UIAlertControllerStyleAlert];
                                   UIViewController* downloadingViewController = self._viewControllerForAncestor;
                                   [downloadingViewController presentViewController:alertDownloading
                                                                           animated:YES
                                                                         completion:nil];

                                   NSURLSessionConfiguration* configuration =
                                       [NSURLSessionConfiguration defaultSessionConfiguration];
                                   AFURLSessionManager* manager =
                                       [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                                   NSURLRequest* request = [NSURLRequest requestWithURL:streamURL];

                                   NSURLSessionDownloadTask* downloadTask = [manager downloadTaskWithRequest:request
                                       progress:^(NSProgress* _Nonnull downloadProgress) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                           float downloadPercent = downloadProgress.fractionCompleted * 100;
                                           alertDownloading.message = [NSString
                                               stringWithFormat:
                                                   @"Video Is Downloading \n\nProgress: %.02f%% \n\nDon't Exit The App",
                                                   downloadPercent];
                                         });
                                       }
                                       destination:^NSURL*(NSURL* targetPath, NSURLResponse* response) {
                                         NSURL* documentsDirectoryURL =
                                             [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                    inDomain:NSUserDomainMask
                                                                           appropriateForURL:nil
                                                                                      create:NO
                                                                                       error:nil];
                                         return [documentsDirectoryURL
                                             URLByAppendingPathComponent:[response suggestedFilename]];
                                       }
                                       completionHandler:^(NSURLResponse* response, NSURL* filePath, NSError* error) {
                                         NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                                              NSUserDomainMask, YES);
                                         NSString* documentsDirectory = [paths objectAtIndex:0];
                                         NSString* oldName =
                                             [NSString stringWithFormat:@"%@/videoplayback.mp4", documentsDirectory];
                                         NSString* newName = [NSString
                                             stringWithFormat:@"%@/%@.mp4", documentsDirectory, escapedString];
                                         [[NSFileManager defaultManager] moveItemAtPath:oldName
                                                                                 toPath:newName
                                                                                  error:nil];
                                         [alertDownloading dismissViewControllerAnimated:YES completion:nil];
                                         UIAlertController* alertDownloaded =
                                             [UIAlertController alertControllerWithTitle:@"Notice"
                                                                                 message:@"Video Download Complete"
                                                                          preferredStyle:UIAlertControllerStyleAlert];

                                         [alertDownloaded
                                             addAction:[UIAlertAction actionWithTitle:@"Finish"
                                                                                style:UIAlertActionStyleCancel
                                                                              handler:^(UIAlertAction* _Nonnull action){
                                                                              }]];

                                         UIViewController* downloadedViewController = self._viewControllerForAncestor;
                                         [downloadedViewController presentViewController:alertDownloaded
                                                                                animated:YES
                                                                              completion:nil];
                                       }];
                                   [downloadTask resume];
                               }
                             }];
                       [dataTask resume];
                   } else {
                       UIAlertController* alertFailed =
                           [UIAlertController alertControllerWithTitle:@"Notice"
                                                               message:@"This video is not supported by the downloader"
                                                        preferredStyle:UIAlertControllerStyleAlert];

                       [alertFailed addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction* action){
                                                                     }]];

                       UIViewController* failedViewController = self._viewControllerForAncestor;
                       [failedViewController presentViewController:alertFailed animated:YES completion:nil];
                   }
               } else {
                   UIAlertController* alertUrlError =
                       [UIAlertController alertControllerWithTitle:@"Notice"
                                                           message:@"Unable to fetch youtube video url from googles api"
                                                    preferredStyle:UIAlertControllerStyleAlert];

                   [alertUrlError addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction* action){
                                                                   }]];

                   UIViewController* urlErrorViewController = self._viewControllerForAncestor;
                   [urlErrorViewController presentViewController:alertUrlError animated:YES completion:nil];
               }
             }];
}

%new
;
- (void)pictureInPicture {
    NSInteger videoStatus = [stateOut playerState];
    if (videoStatus == 3) {
        MRMediaRemoteSendCommand(MRMediaRemoteCommandPause, 0);
    }

    XCDYouTubeClient.innertubeApiKey = YTApiKey;

    NSString* videoIdentifier = [playingVideoID currentVideoID];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kEnableBackgroundPlayback"] == YES) {
        [[XCDYouTubeClient defaultClient]
            getVideoWithIdentifier:videoIdentifier
                 completionHandler:^(XCDYouTubeVideo* video, NSError* error) {
                   if (video) {
                       NSDictionary* streamURLs = video.streamURLs;
                       pipTime = [NSString stringWithFormat:@"%f", [resultOut mediaTime]];
                       pipURL = streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming];
                       if (pipURL != NULL) {
                           PictureInPictureController* pictureInPictureController =
                               [[PictureInPictureController alloc] init];
                           pictureInPictureController.videoTime = pipTime;
                           pictureInPictureController.videoPath = pipURL;
                           UINavigationController* pictureInPictureControllerView =
                               [[UINavigationController alloc] initWithRootViewController:pictureInPictureController];
                           pictureInPictureControllerView.modalPresentationStyle = UIModalPresentationFullScreen;

                           UIViewController* pictureInPictureViewController = self._viewControllerForAncestor;
                           [pictureInPictureViewController presentViewController:pictureInPictureControllerView
                                                                        animated:YES
                                                                      completion:nil];
                       } else {
                           UIAlertController* alertPip = [UIAlertController
                               alertControllerWithTitle:@"Notice"
                                                message:@"This video is not supported by the Picture-In-Picture"
                                         preferredStyle:UIAlertControllerStyleAlert];

                           [alertPip addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                                        style:UIAlertActionStyleCancel
                                                                      handler:^(UIAlertAction* _Nonnull action){
                                                                      }]];

                           UIViewController* pipViewController = self._viewControllerForAncestor;
                           [pipViewController presentViewController:alertPip animated:YES completion:nil];
                       }
                   } else {
                       UIAlertController* alertPip = [UIAlertController
                           alertControllerWithTitle:@"Notice"
                                            message:@"Unable to fetch youtube video url from googles api"
                                     preferredStyle:UIAlertControllerStyleAlert];

                       [alertPip addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction* _Nonnull action){
                                                                  }]];

                       UIViewController* pipViewController = self._viewControllerForAncestor;
                       [pipViewController presentViewController:alertPip animated:YES completion:nil];
                   }
                 }];
    } else {
        UIAlertController* alertPip =
            [UIAlertController alertControllerWithTitle:@"Notice"
                                                message:@"You must enable 'Background Playback' in YouTube Reborn "
                                                        @"settings to use Picture-In-Picture"
                                         preferredStyle:UIAlertControllerStyleAlert];

        [alertPip addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction* _Nonnull action){
                                                   }]];

        UIViewController* pipViewController = self._viewControllerForAncestor;
        [pipViewController presentViewController:alertPip animated:YES completion:nil];
    }
}
%end

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
        NSData* colorData = [defaults objectForKey:@"kYTRebornColourOptionsVTwo"];
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:colorData error:nil];
        [unarchiver setRequiresSecureCoding:NO];
        NSString* hexString = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
        if (hexString != nil) {
            %init(gColourOptions);
        }
        %init(_ungrouped);
    }
}
