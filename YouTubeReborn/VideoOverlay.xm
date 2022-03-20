#import <AFNetworking/AFNetworking.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <HBLog.h>
#import <MediaRemote/MediaRemote.h>
#import <UIKit/UIKit.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "../Controllers/PictureInPictureController.h"
#import "Tweak.h"

static NSString* const YTApiKey = @"AIzaSyCGZHGUPP9wojQDfrwPEr7Pr-mhBanHAb8";

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

NSMutableArray* _overlayButtons = [NSMutableArray array];
NSDictionary* _overlaySelectors = @{
    @"DWN" : @{
        @"selector" : [NSValue valueWithPointer:@selector(optionsAction:)],
        @"icon" : @"arrow.down.circle",
    },
    @"OP" : @{
        @"selector" : [NSValue valueWithPointer:@selector(playInApp)],
        @"icon" : @"list.dash",
    },
    @"PIP" : @{
        @"selector" : [NSValue valueWithPointer:@selector(pictureInPicture)],
        @"icon" : @"pip",
    },
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
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kHideRebornDWNButton"]) {
            [_overlayButtons addObject:@"DWN"];
        }
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kHideRebornOPButton"]) {
            [_overlayButtons addObject:@"OP"];
        }
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"kHideRebornPIPButton"]) {
            [_overlayButtons addObject:@"PIP"];
        }
        int _overlayButtonsCount = [_overlayButtons count];
        for (int i = 0; i < _overlayButtonsCount; i++) {
            // TODO: I guess this works, but there must be some way to make it cleaner and less repetitive...
            NSString* _btnName = _overlayButtons[i];
            SEL _selector = (SEL)[_overlaySelectors[_btnName][@"selector"] pointerValue];
            UIImage* _btnImage = [UIImage systemImageNamed:_overlaySelectors[_btnName][@"icon"]];

            switch (i) {
                case 0:
                    HBLogDebug(@"[YouTube Reborn] Creating overlay button %d: %@", i, _btnName);
                    self.overlayButtonOne = [UIButton buttonWithType:UIButtonTypeRoundedRect];

                    HBLogDebug(@"[YouTube Reborn] Adding action to button %d: %@", i, _btnName);
                    [self.overlayButtonOne addTarget:self
                                              action:_selector
                                    forControlEvents:UIControlEventTouchUpInside];

                    HBLogDebug(@"[YouTube Reborn] Setting image for button %d: %@", i, _overlayButtons[i]);
                    [self.overlayButtonOne setImage:_btnImage forState:UIControlStateNormal];

                    HBLogDebug(@"[YouTube Reborn] Inserting overlay button %d to view: %@", i, self.overlayButtonOne);
                    self.overlayButtonOne.frame = CGRectMake((CGFloat)40 + 45 * i, _overlayButtonsY, 40.0, 30.0);
                    [self addSubview:self.overlayButtonOne];
                    break;
                case 1:
                    HBLogDebug(@"[YouTube Reborn] Creating overlay button %d: %@", i, _btnName);
                    self.overlayButtonTwo = [UIButton buttonWithType:UIButtonTypeRoundedRect];

                    HBLogDebug(@"[YouTube Reborn] Adding action to button %d: %@", i, _btnName);
                    [self.overlayButtonTwo addTarget:self
                                              action:_selector
                                    forControlEvents:UIControlEventTouchUpInside];

                    HBLogDebug(@"[YouTube Reborn] Setting image for button %d: %@", i, _overlayButtons[i]);
                    [self.overlayButtonTwo setImage:_btnImage forState:UIControlStateNormal];

                    HBLogDebug(@"[YouTube Reborn] Inserting overlay button %d to view: %@", i, self.overlayButtonOne);
                    self.overlayButtonTwo.frame = CGRectMake((CGFloat)40 + 45 * i, _overlayButtonsY, 40.0, 30.0);
                    [self addSubview:self.overlayButtonTwo];
                    break;
                case 2:
                    HBLogDebug(@"[YouTube Reborn] Creating overlay button %d: %@", i, _btnName);
                    self.overlayButtonThree = [UIButton buttonWithType:UIButtonTypeRoundedRect];

                    HBLogDebug(@"[YouTube Reborn] Adding action to button %d: %@", i, _btnName);
                    [self.overlayButtonThree addTarget:self
                                                action:_selector
                                      forControlEvents:UIControlEventTouchUpInside];

                    HBLogDebug(@"[YouTube Reborn] Setting image for button %d: %@", i, _overlayButtons[i]);
                    [self.overlayButtonThree setImage:_btnImage forState:UIControlStateNormal];

                    HBLogDebug(@"[YouTube Reborn] Inserting overlay button %d to view: %@", i, self.overlayButtonOne);
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
                                                        preferredStyle:UIAlertControllerStyleActionSheet];

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
                                                                     style:UIAlertActionStyleCancel
                                                                   handler:^(UIAlertAction* action){
                                                                   }]];

                       UIViewController* menuViewController = self._viewControllerForAncestor;
                       [menuViewController presentViewController:alertMenu animated:YES completion:nil];
                   } else {
                       UIAlertController* alertFailed =
                           [UIAlertController alertControllerWithTitle:@"Notice"
                                                               message:@"This video is not supported by Infuse or VLC"
                                                        preferredStyle:UIAlertControllerStyleAlert];

                       [alertFailed addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction* action){
                                                                     }]];

                       UIViewController* failedViewController = self._viewControllerForAncestor;
                       [failedViewController presentViewController:alertFailed animated:YES completion:nil];
                   }
               } else {
                   UIAlertController* alertError =
                       [UIAlertController alertControllerWithTitle:@"Notice"
                                                           message:@"Unable to fetch video URL"
                                                    preferredStyle:UIAlertControllerStyleAlert];

                   [alertError addAction:[UIAlertAction actionWithTitle:@"OK"
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
                                                                preferredStyle:UIAlertControllerStyleActionSheet];

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
                                   HBLogError(@"[YouTube Reborn] YouTube API request failed: %@", error);
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

                       [alertFailed addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction* action){
                                                                     }]];

                       UIViewController* failedViewController = self._viewControllerForAncestor;
                       [failedViewController presentViewController:alertFailed animated:YES completion:nil];
                   }
               } else {
                   UIAlertController* alertUrlError =
                       [UIAlertController alertControllerWithTitle:@"Notice"
                                                           message:@"Unable to fetch video URL"
                                                    preferredStyle:UIAlertControllerStyleAlert];

                   [alertUrlError addAction:[UIAlertAction actionWithTitle:@"OK"
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
                                   HBLogError(@"[YouTube Reborn] YouTube API request failed: %@", error);
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

                       [alertFailed addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction* action){
                                                                     }]];

                       UIViewController* failedViewController = self._viewControllerForAncestor;
                       [failedViewController presentViewController:alertFailed animated:YES completion:nil];
                   }
               } else {
                   UIAlertController* alertUrlError =
                       [UIAlertController alertControllerWithTitle:@"Notice"
                                                           message:@"Unable to fetch video URL"
                                                    preferredStyle:UIAlertControllerStyleAlert];

                   [alertUrlError addAction:[UIAlertAction actionWithTitle:@"Ok"
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
                                                message:@"This video is not supported by Picture-In-Picture"
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
                                            message:@"Unable to fetch video URL"
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
