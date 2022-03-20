#import "NSString+HexColor.h"

@implementation NSString(HexColor)

+ (NSString *)hexStringFromColor:(UIColor *)color
{
    CGColorSpaceModel colorSpace = CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor));
    const CGFloat *components = CGColorGetComponents(color.CGColor);

    CGFloat r, g, b, a;

    switch (colorSpace) {
        case kCGColorSpaceModelMonochrome:
            r = g = b = components[0];
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
            a = 0.0f;
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
