#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (HexString)
/*!
 * The #RRGGBBAA hex string representation of the color.
 */
@property (readonly, strong, nonatomic) NSString* hexString;
/*!
 * @brief Converts a hex string into a UIColor.
 *
 * @param hexString string format: #RGB, #RGBA, #RRGGBB, #RRGGBBAA
 *
 * @return UIColor object.
 */
+ (UIColor*)rebornColorFromHexString:(NSString*)hexString;
@end
