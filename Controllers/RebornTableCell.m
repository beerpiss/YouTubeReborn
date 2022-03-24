#import "RebornTableCell.h"

@implementation RebornTableCell
// FIXME: I Have Zero Fucking Idea Why My Delegate Function Isn't Working But It's Annoying As Hell
- (void)colorWellValueChanged:(UITableViewCell*)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    UIColor* color = self.colorWell.selectedColor;
    NSLog(@"[YouTube Reborn] User selected color %@ for category %@, color type %@",
          color, self.category, self.colorType);

    if (self.colorType != nil && self.category != nil) {
        NSMutableDictionary* categorySettings = [(NSDictionary*)[defaults objectForKey:self.category] mutableCopy];
        [categorySettings setObject:color.hexString forKey:self.colorType];
        [defaults setObject:categorySettings forKey:self.category];
    }
    else if (self.category != nil) {
        [defaults setObject:color.hexString forKey:self.category];
    }
    [defaults synchronize];
    if (self.notificationName != nil)
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)self.notificationName, NULL, NULL, YES);
}

- (void)presentColorPicker:(UITableViewCell*)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    UIColor* color = [defaults objectForKey:self.category][self.colorType];

    UIColorPickerViewController* colorPicker = [[UIColorPickerViewController alloc] init];
    colorPicker.popoverPresentationController.sourceView = self;
    colorPicker.supportsAlpha = NO;
    colorPicker.delegate = self;
    colorPicker.selectedColor = color;

    UIViewController* rootViewController = self._viewControllerForAncestor;
    [rootViewController presentViewController:colorPicker animated:YES completion:nil];
}
@end
