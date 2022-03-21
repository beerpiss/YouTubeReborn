#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (HexString)
/*!
 * @brief Converts a hex string into a UIColor.
 *
 * @param hexString string format: #RGB, #RGBA, #RRGGBB, #RRGGBBAA
 *
 * @return UIColor object.
 */
+ (UIColor*)rebornColorFromHexString:(NSString*)hexString;
@end
