@interface YTWrapperView : UIView
- (void)rootOptionsAction:(id)sender;
@end

@interface YTUserDefaults : NSObject
- (long long)appThemeSetting;
@end

@interface UIView ()
- (UIViewController*)_viewControllerForAncestor;
@end

extern YTUserDefaults* ytThemeSettings;
