#import "UIColor+HexString.h"

@implementation UIColor (HexString)
+ (UIColor*)rebornColorFromHexString:(NSString*)hexString {
    // Normalize color string
    if (![hexString hasPrefix:@"#"]) {
        hexString = [NSString stringWithFormat:@"#%@", hexString];
    }

    unsigned int hexInt = 0;
    NSScanner* scanner = [NSScanner scannerWithString:hexString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexInt];

    CGFloat red, green, blue, alpha;
    switch ([hexString length]) {
        case 1:  // #
            // This case should not happen most of the time, but it is still a valid case.
            // Assume that all the RGB values are 0, and alpha is 1
            red = 0.0f;
            green = 0.0f;
            blue = 0.0f;
            alpha = 1.0f;
            break;
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

- (NSString*)hexString {
    CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    const CGFloat *components = CGColorGetComponents(self.CGColor);

    CGFloat r, g, b, a;

    switch (colorSpace) {
        case kCGColorSpaceModelMonochrome:
            r = components[0];
            g = components[0];
            b = components[0];
            a = components[1];
            break;
        case kCGColorSpaceModelRGB:
            r = components[0];
            g = components[1];
            b = components[2];
            a = components[3];
            break;
        case kCGColorSpaceModelCMYK:
            r = (1 - components[0]) * (1 - components[3]);
            g = (1 - components[1]) * (1 - components[3]);
            b = (1 - components[2]) * (1 - components[3]);
            a = 1.0f;
            break;
        default:
            return @"";
    }

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255),
            lroundf(a * 255)];
}

@end
