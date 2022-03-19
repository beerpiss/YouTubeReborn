// MIT License

// Copyright (c) 2021 - 2022 PoomSmart

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <Foundation/Foundation.h>
#import <dlfcn.h>

#define YT_BUNDLE_ID @"com.google.ios.youtube"
#define YT_NAME @"YouTube"

@interface SSOConfiguration : NSObject
@end

%hook YTVersionUtils
+ (NSString*)appName {
    return YT_NAME;
}

+ (NSString*)appID {
    return YT_BUNDLE_ID;
}
%end

%hook GCKBUtils
+ (NSString*)appIdentifier {
    return YT_BUNDLE_ID;
}
%end

%hook GPCDeviceInfo
+ (NSString*)bundleId {
    return YT_BUNDLE_ID;
}
%end

%hook OGLBundle
+ (NSString*)shortAppName {
    return YT_NAME;
}
%end

%hook GVROverlayView
+ (NSString*)appName {
    return YT_NAME;
}
%end

%hook OGLPhenotypeFlagServiceImpl
- (NSString*)bundleId {
    return YT_BUNDLE_ID;
}
%end

%hook SSOConfiguration
- (id)initWithClientID:(id)clientID supportedAccountServices:(id)supportedAccountServices {
    self = %orig;
    [self setValue:YT_NAME forKey:@"_shortAppName"];
    [self setValue:YT_BUNDLE_ID forKey:@"_applicationIdentifier"];
    return self;
}
%end

%hook NSBundle
- (NSString*)bundleIdentifier {
    NSArray* address = [NSThread callStackReturnAddresses];
    Dl_info info = {0};
    if (dladdr((void*)[address[2] longLongValue], &info) == 0)
        return %orig;
    NSString* path = [NSString stringWithUTF8String:info.dli_fname];
    if ([path hasPrefix:NSBundle.mainBundle.bundlePath])
        return YT_BUNDLE_ID;
    return %orig;
}

- (id)objectForInfoDictionaryKey:(NSString*)key {
    if ([key isEqualToString:@"CFBundleIdentifier"])
        return YT_BUNDLE_ID;
    if ([key isEqualToString:@"CFBundleDisplayName"] || [key isEqualToString:@"CFBundleName"])
        return YT_NAME;
    return %orig;
}
%end
