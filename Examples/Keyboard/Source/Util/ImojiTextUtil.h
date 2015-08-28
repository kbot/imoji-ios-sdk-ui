//
// Created by Nima on 4/22/15.
// Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ImojiTextUtil : NSObject

+ (UIFont *)defaultFontWithSize:(CGFloat)size;

+ (NSAttributedString *)attributedString:(NSString *)text withFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor;

+ (NSAttributedString *)attributedString:(NSString *)text withFontSize:(CGFloat)fontSize textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)alignment;

@end
