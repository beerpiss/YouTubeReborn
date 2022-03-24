#import <UIKit/UIKit.h>

@interface SponsorBlockOptionsController : UITableViewController

@end

@interface UIView ()
- (UIViewController*)_viewControllerForAncestor;
@end

@interface UISegment : UIView
@end

@interface SponsorBlockTableCell : UITableViewCell <UIColorPickerViewControllerDelegate>
@property (strong, nonatomic) NSString* category;
@property (strong, nonatomic) NSString* colorType;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColorWell *colorWell;
@end
