#import "UIColor+HexString.h"

@implementation UIColor (HexString)

+ (UIColor*)rebornColorFromHexString:(NSString*)hexString {
    unsigned int hexInt = 0;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexInt];

    CGFloat red, green, blue, alpha;
    switch ([hexString length]) {
        case 4:  // #RGB
            red = (float)(hexInt >> 8) / 15.0f;
            green = (float)(hexInt >> 4 & 0xF) / 15.0f;
            blue = (float)(hexInt & 0xF) / 15.0f;
            alpha = 1.0f;
            break;
        case 5:  // #RGBA
            red = (float)(hexInt >> 12) / 15.0f;
            green = (float)(hexInt >> 8 & 0xF) / 15.0f;
            blue = (float)(hexInt >> 4 & 0xF) / 15.0f;
            alpha = (float)(hexInt & 0xF) / 15.0f;
            break;
        case 7:  // #RRGGBB
            red = (float)(hexInt >> 16) / 255.0f;
            green = (float)(hexInt >> 8 & 0xFF) / 255.0f;
            blue = (float)(hexInt & 0xFF) / 255.0f;
            alpha = 1.0f;
            break;
        case 9:  // #RRGGBBAA
            red = (float)(hexInt >> 24) / 255.0f;
            green = (float)(hexInt >> 16 & 0xFF) / 255.0f;
            blue = (float)(hexInt >> 8 & 0xFF) / 255.0f;
            alpha = (float)(hexInt & 0xFF) / 255.0f;
            break;
        default:
            [NSException raise:@"Invalid color value"
                        format:@"Color value %@ is invalid.  It should be a hex value of the form #RGB, #RGBA, "
                               @"#RRGGBB, or #RRGGBBAA",
                               hexString];
            break;
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
