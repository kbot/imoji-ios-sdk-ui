//
//  ImojiSDKUI
//
//  Created by Jeff Wang
//  Copyright (C) 2015 Imoji
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import <CoreText/CoreText.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>

NSString *const IMAttributeStringUtilDefaultFont = @"HelveticaNeue-Medium";
NSString *const IMAttributeStringUtilMontserratLight = @"Montserrat-Light";
NSString *const IMAttributeStringUtilSFLightFont = @"SFUIDisplay-Light";
NSString *const IMAttributeStringUtilSFRegularFont = @"SFUIDisplay-Regular";
NSString *const IMAttributeStringUtilSFMediumFont = @"SFUIDisplay-Medium";
NSString *const IMAttributeStringUtilSFTextBoldFont = @"SFUIText-Bold";
NSString *const IMAttributeStringUtilSFTextSemiBoldFont = @"SFUIText-SemiBold";
NSString *const IMAttributeStringUtilSFTextMediumFont = @"SFUIText-Medium";
NSString *const IMAttributeStringUtilSFTextRegularFont = @"SFUIText-Regular";
NSString *const IMAttributeStringUtilImojiRegularFont = @"Imoji-Regular";

@implementation IMAttributeStringUtil {

}

+ (UIFont *)defaultFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:IMAttributeStringUtilDefaultFont size:size];
}

+ (UIFont *)montserratLightFontWithSize:(CGFloat)size {
    return [IMAttributeStringUtil checkedStyledFontWithName:IMAttributeStringUtilMontserratLight andSize:size];
}

+ (UIFont *)sfUIDisplayLightFontWithSize:(CGFloat)size {
    return [IMAttributeStringUtil checkedStyledFontWithName:IMAttributeStringUtilSFLightFont andSize:size];
}

+ (UIFont *)sfUIDisplayRegularFontWithSize:(CGFloat)size {
    return [IMAttributeStringUtil checkedStyledFontWithName:IMAttributeStringUtilSFRegularFont andSize:size];
}

+ (UIFont *)sfUIDisplayMediumFontWithSize:(CGFloat)size {
    return [IMAttributeStringUtil checkedStyledFontWithName:IMAttributeStringUtilSFMediumFont andSize:size];
}

+ (UIFont *)sfUITextBoldFontWithSize:(CGFloat)size {
    return [IMAttributeStringUtil checkedStyledFontWithName:IMAttributeStringUtilSFTextBoldFont andSize:size];
}

+ (UIFont *)sfUITextSemiBoldFontWithSize:(CGFloat)size {
    return [IMAttributeStringUtil checkedStyledFontWithName:IMAttributeStringUtilSFTextSemiBoldFont andSize:size];
}

+ (UIFont *)sfUITextMediumFontWithSize:(CGFloat)size {
    return [IMAttributeStringUtil checkedStyledFontWithName:IMAttributeStringUtilSFTextMediumFont andSize:size];
}

+ (UIFont *)sfUITextRegularFontWithSize:(CGFloat)size {
    return [IMAttributeStringUtil checkedStyledFontWithName:IMAttributeStringUtilSFTextRegularFont andSize:size];
}

+ (UIFont *)imojiRegularFontWithSize:(CGFloat)size {
    return [IMAttributeStringUtil checkedStyledFontWithName:IMAttributeStringUtilImojiRegularFont andSize:size];
}

+ (NSAttributedString *)attributedString:(NSString *)text
                                withFont:(UIFont *)font
                                   color:(UIColor *)color {
    return [IMAttributeStringUtil attributedString:text withFont:font color:color andAlignment:NSTextAlignmentLeft];
}

+ (UIFont *)checkedStyledFontWithName:(NSString *)name andSize:(CGFloat)size {
    UIFont *font = [UIFont fontWithName:name size:size];
    if (!font) {
        [IMAttributeStringUtil dynamicallyLoadFontNamed:name];
        font = [UIFont fontWithName:name size:size];

        if(!font) {
            return [IMAttributeStringUtil defaultFontWithSize:size];
        }
    }

    return font;
}

+ (void)dynamicallyLoadFontNamed:(NSString *)name
{
    NSURL *url = [[IMResourceBundleUtil fontsBundle] URLForResource:name withExtension:@"otf"];
    NSData *fontData = [NSData dataWithContentsOfURL:url];
    if (fontData) {
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)fontData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            NSLog(@"Failed to load font: %@", errorDescription);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);
    }
}

+ (NSAttributedString *)attributedString:(NSString *)text
                                withFont:(UIFont *)font
                                   color:(UIColor *)color
                            andAlignment:(NSTextAlignment)alignment {

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = alignment;

    return [IMAttributeStringUtil attributedString:text withFont:font color:color andParagraphStyle:paragraphStyle];
}

+ (NSAttributedString *)attributedString:(NSString *)text
                                withFont:(UIFont *)font
                                   color:(UIColor *)color
                       andParagraphStyle:(NSParagraphStyle *)paragraphStyle {

    NSDictionary *textAttributes = @{
            NSFontAttributeName : font,
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName : paragraphStyle
    };

    return [[NSAttributedString alloc] initWithString:text
                                           attributes:textAttributes];
}

@end
