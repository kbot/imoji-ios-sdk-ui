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

#import "IMAttributeStringUtil.h"

NSString *const DEFAULT_FONT = @"HelveticaNeue-Medium";
NSString *const SF_UI_DISPLAY_LIGHT_FONT = @"SFUIDisplay-Light";
NSString *const SF_UI_DISPLAY_REGULAR_FONT = @"SFUIDisplay-Regular";
NSString *const SF_UI_DISPLAY_MEDIUM_FONT = @"SFUIDisplay-Medium";

@implementation IMAttributeStringUtil {

}

+ (UIFont *)defaultFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:DEFAULT_FONT size:size];
}

+ (UIFont *)sfUIDisplayLightFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:SF_UI_DISPLAY_LIGHT_FONT size:size];
}

+ (UIFont *)sfUIDisplayRegularFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:SF_UI_DISPLAY_REGULAR_FONT size:size];
}

+ (UIFont *)sfUIDisplayMediumFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:SF_UI_DISPLAY_MEDIUM_FONT size:size];
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
