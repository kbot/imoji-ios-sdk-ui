//
// Created by Nima on 4/22/15.
// Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import "ImojiTextUtil.h"

NSString *const DEFAULT_FONT = @"HelveticaNeue";

@implementation ImojiTextUtil {

}

+ (UIFont *)defaultFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:DEFAULT_FONT size:size];
}

+ (NSAttributedString *)attributedString:(NSString *)text
                            withFontSize:(CGFloat)fontSize
                               textColor:(UIColor *)textColor {
    return [ImojiTextUtil attributedString:text
                              withFontSize:fontSize
                                 textColor:textColor
                             textAlignment:NSTextAlignmentLeft];
}

+ (NSAttributedString *)attributedString:(NSString *)text
                            withFontSize:(CGFloat)fontSize
                               textColor:(UIColor *)textColor
                           textAlignment:(NSTextAlignment)alignment {

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = alignment;

    NSDictionary *textAttributes = @{
            NSFontAttributeName : [ImojiTextUtil defaultFontWithSize:fontSize],
            NSForegroundColorAttributeName : textColor,
            NSParagraphStyleAttributeName : paragraphStyle
    };

    return [[NSAttributedString alloc] initWithString:text
                                           attributes:textAttributes];
}

@end
