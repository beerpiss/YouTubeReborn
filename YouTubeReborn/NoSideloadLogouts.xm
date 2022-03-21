#import <Foundation/Foundation.h>
#import <HBLog.h>
#import "../DTTJailbreakDetection/DTTJailbreakDetection.h"

%group NoSideloadLogouts
%hook SSOKeychain
+ (id)accessGroup {
    NSDictionary* query =
        [NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSString*)kSecClassGenericPassword,
                                                   (__bridge NSString*)kSecClass, @"bundleSeedID", kSecAttrAccount, @"",
                                                   kSecAttrService, (id)kCFBooleanTrue, kSecReturnAttributes, nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef*)&result);
    if (status != errSecSuccess)
        return nil;
    NSString* accessGroup = [(__bridge NSDictionary*)result objectForKey:(__bridge NSString*)kSecAttrAccessGroup];

    return accessGroup;
}
+ (id)sharedAccessGroup {
    NSDictionary* query =
        [NSDictionary dictionaryWithObjectsAndKeys:(__bridge NSString*)kSecClassGenericPassword,
                                                   (__bridge NSString*)kSecClass, @"bundleSeedID", kSecAttrAccount, @"",
                                                   kSecAttrService, (id)kCFBooleanTrue, kSecReturnAttributes, nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef*)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef*)&result);
    if (status != errSecSuccess)
        return nil;
    NSString* accessGroup = [(__bridge NSDictionary*)result objectForKey:(__bridge NSString*)kSecAttrAccessGroup];

    return accessGroup;
}
%end
%end

%ctor {
    @autoreleasepool {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults registerDefaults:@{
            @"kPreventSideloadedLogouts" : @(![DTTJailbreakDetection isJailbroken]),
        }];
        if ([defaults boolForKey:@"kPreventSideloadedLogouts"]) {
            HBLogDebug(@"[YouTube Reborn] Preventing logouts");
            %init(NoSideloadLogouts);
        }
    }
}
