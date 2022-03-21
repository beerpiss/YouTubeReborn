#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../Controllers/RootOptionsController.h"
#import "../Extensions/UIColor+HexString.h"
#import "Settings.h"

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
        rebornView.backgroundColor = [UIColor
            rebornColorFromHexString:[[NSUserDefaults standardUserDefaults] stringForKey:@"kYTRebornColourOptionsV3"]];

        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, rebornView.frame.size.width, 51)];
        label.text = @"YouTube Reborn settings";
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