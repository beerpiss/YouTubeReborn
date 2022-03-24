#import <UIKit/UIKit.h>
#import "../Extensions/UIColor+HexString.h"

@interface UIView ()
- (UIViewController*)_viewControllerForAncestor;
@end

/** 
 *  @brief a subclass of UITableViewCell designed to make it easy to add and deal with UIColorWells.
 */
@interface RebornTableCell : UITableViewCell <UIColorPickerViewControllerDelegate>
/**
 *  @name Accessing properties
 */

/**
 *  The defaults key to write to when the color is changed.
 *  Add a UIControlEventValueChanged action with the selector as @(colorWellValueChanged:)
 */
@property (strong, nonatomic) NSString* category;

/**
 *  The sub key to write to when the color is changed
 *  If colorType is nil, category is the defaults key, but if colorType is not nil, category is assumed
 *  to be a dictionary containing the key colorType.
 */
@property (strong, nonatomic) NSString* colorType;

/**
 *  The color well bound to this table cell. Required for -[RebornTableCell colorWellValueChanged:]
 */
@property (strong, nonatomic) UIColorWell *colorWell;

/**
 *  The notification name to post when the color is changed (if it is not nil).
 */
@property (strong, nonatomic) NSString* notificationName;
- (void)colorWellValueChanged:(UITableViewCell*)sender;
- (void)presentColorPicker:(UITableViewCell*)sender;
@end
