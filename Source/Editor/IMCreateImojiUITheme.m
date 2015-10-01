//
//  ImojiSDKUI
//
//  Created by Nima Khoshini
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

#import "IMCreateImojiUITheme.h"
#import "IMAttributeStringUtil.h"

@implementation IMCreateImojiUITheme {

}

+ (IMCreateImojiUITheme *)instance {
    static IMCreateImojiUITheme *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tagScreenNavigationToolbarBarTintColor = [UIColor colorWithWhite:250.f / 255.f alpha:1.0f];
        _tagScreenTintColor = [UIColor colorWithWhite:122.f / 255.f alpha:1.0f];
        _tagScreenRemoveButtonDividerColor = [UIColor colorWithWhite:244.f / 255.f alpha:1.0f];
        _tagScreenTagFontColor = [UIColor colorWithWhite:122.f / 255.f alpha:1.0f];
        _tagScreenPlaceHolderFontColor = [UIColor colorWithWhite:122.f / 255.f alpha:.4f];
        _tagScreenRemoveButtonColor = [UIColor colorWithWhite:232.f / 255.f alpha:1.0f];
        _tagScreenTagItemBorderColor = [UIColor colorWithWhite:232.f / 255.f alpha:1.0f];
        _createViewBackgroundColor = [UIColor colorWithWhite:248.0f / 255.0f alpha:1];
        _trimScreenTintColor = [UIColor colorWithWhite:105.f / 255.f alpha:1.0f];

        _tagScreenTagFont = [IMAttributeStringUtil defaultFontWithSize:16.f];
        _tagScreenNavigationBarFont = [IMAttributeStringUtil defaultFontWithSize:18.f];
        _trimScreenNavigationBarFont = [IMAttributeStringUtil defaultFontWithSize:18.f];

        _trimScreenUndoButtonImage = [UIImage imageNamed:@"ImojiEditorAssets.bundle/create_trace_undo"];
        _trimScreenHelpButtonImage = [UIImage imageNamed:@"ImojiEditorAssets.bundle/create_trace_hints"];
        _trimScreenCancelButtonImage = [UIImage imageNamed:@"ImojiEditorAssets.bundle/create_back"];
        _trimScreenFinishTraceButtonImage = [UIImage imageNamed:@"ImojiEditorAssets.bundle/create_trace_proceed"];

        _tagScreenBackButtonImage = [UIImage imageNamed:@"ImojiEditorAssets.bundle/create_back"];
        _tagScreenFinishButtonImage = [UIImage imageNamed:@"ImojiEditorAssets.bundle/create_tag_done"];

        _tagScreenHelpImageStep1 = [UIImage imageNamed:@"ImojiEditorAssets.bundle/create_tips_1"];
        _tagScreenHelpImageStep2 = [UIImage imageNamed:@"ImojiEditorAssets.bundle/create_tips_2"];
        _tagScreenHelpImageStep3 = [UIImage imageNamed:@"ImojiEditorAssets.bundle/create_tips_3"];
        _tagScreenHelpNextButtonImage = [UIImage imageNamed:@"ImojiEditorAssets.bundle/create_tips_proceed"];
        _tagScreenHelpDoneButtonImage = [UIImage imageNamed:@"ImojiEditorAssets.bundle/create_tips_done"];

        _tagScreenRemoveTagIcon = [IMCreateImojiUITheme drawClearIconWithXColor:_tagScreenRemoveButtonColor
                                                                   dividerColor:_tagScreenRemoveButtonDividerColor];

        _tagScreenTagFieldBackgroundColor = [UIColor colorWithWhite:1.0f alpha:.3f];
        _tagScreenTagFieldBorderWidth = 1.0f;
        _tagScreenTagFieldCornerRadius = 7.5f;
        _tagScreenTagItemInsets = UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f);
        _tagScreenTagItemInterspacingDistance = 10.0f;

        _tagScreenTagItemViewInsets = UIEdgeInsetsMake(2.5, 7.5, 2.5, 2.5);
        _tagScreenTagItemTextButtonSpacing = 5.f;

    }

    return self;
}

- (void)setTagScreenRemoveButtonColor:(UIColor *)tagScreenRemoveButtonColor {
    _tagScreenRemoveButtonColor = tagScreenRemoveButtonColor;
    _tagScreenRemoveTagIcon = [IMCreateImojiUITheme drawClearIconWithXColor:_tagScreenRemoveButtonColor
                                                               dividerColor:_tagScreenRemoveButtonDividerColor];
}

- (void)setTagScreenRemoveButtonDividerColor:(UIColor *)tagScreenRemoveButtonDividerColor {
    _tagScreenRemoveButtonDividerColor = tagScreenRemoveButtonDividerColor;
    _tagScreenRemoveTagIcon = [IMCreateImojiUITheme drawClearIconWithXColor:_tagScreenRemoveButtonColor
                                                               dividerColor:_tagScreenRemoveButtonDividerColor];
}

+ (UIImage *)drawClearIconWithXColor:(UIColor *)xColor dividerColor:(UIColor *)dividerColor {
    CGSize size = CGSizeMake(30.0f, 30.0f);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetStrokeColorWithColor(context, dividerColor.CGColor);

    // draw divider line
    CGContextSetLineWidth(context, 2.0f);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, size.height);
    CGContextStrokePath(context);

    // draw X
    CGContextSetStrokeColorWithColor(context, xColor.CGColor);
    CGContextSetLineWidth(context, 2.25f);
    CGFloat relativeFrameScaleFactor = 1.5;
    CGContextMoveToPoint(context, size.width / relativeFrameScaleFactor, size.height / relativeFrameScaleFactor);
    CGContextAddLineToPoint(context, size.width - size.width / relativeFrameScaleFactor, size.height - size.height / relativeFrameScaleFactor);

    CGContextMoveToPoint(context, size.width - size.width / relativeFrameScaleFactor, size.height / relativeFrameScaleFactor);
    CGContextAddLineToPoint(context, size.width / relativeFrameScaleFactor, size.height - size.height / relativeFrameScaleFactor);

    CGContextStrokePath(context);

    UIImage *icon = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return icon;
}


@end
