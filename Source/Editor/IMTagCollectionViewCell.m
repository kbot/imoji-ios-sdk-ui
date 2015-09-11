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

#import <Masonry/Masonry.h>
#import "IMTagCollectionViewCell.h"

UIEdgeInsets const IMTagCollectionViewCellContentInsets = {5, 5, 5, 5};

@interface IMTagCollectionViewCell ()

@end

@implementation IMTagCollectionViewCell

- (void)setTagContents:(NSString *)tagContents {
    _tagContents = tagContents;

    if (!self.textView) {
        _textView = [UILabel new];
        _removeButton = [UIButton new];

        [self.removeButton setImage:[IMTagCollectionViewCell removeIcon] forState:UIControlStateNormal];

        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 5.0f;

        [self addSubview:self.textView];
        [self addSubview:self.removeButton];

        [self.removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-IMTagCollectionViewCellContentInsets.right);
            make.centerY.equalTo(self);
        }];

        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(IMTagCollectionViewCellContentInsets.left);
            make.centerY.equalTo(self);
            make.right.equalTo(self.removeButton.mas_left);
        }];
    }

    self.textView.text = tagContents;
}

+ (UIFont *)textFont {
    static UIFont *_font;

    @synchronized (self) {
        if (_font == nil) {
            _font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        }
    }

    return _font;
}

+ (UIImage *)removeIcon {
    static UIImage *_icon = nil;

    @synchronized (self) {
        if (_icon == nil) {
            CGSize size = CGSizeMake(20.0f, 20.0f);
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
            CGContextRef context = UIGraphicsGetCurrentContext();

            CGContextSetBlendMode(context, kCGBlendModeNormal);
            CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);

            CGContextSetLineWidth(context, 1.5);

            // draw X
            CGFloat relativeFrameScaleFactor = 1.25;
            CGContextMoveToPoint(context, size.width / relativeFrameScaleFactor, size.height / relativeFrameScaleFactor);
            CGContextAddLineToPoint(context, size.width - size.width / relativeFrameScaleFactor, size.height - size.height / relativeFrameScaleFactor);

            CGContextMoveToPoint(context, size.width - size.width / relativeFrameScaleFactor, size.height / relativeFrameScaleFactor);
            CGContextAddLineToPoint(context, size.width / relativeFrameScaleFactor, size.height - size.height / relativeFrameScaleFactor);

            CGContextStrokePath(context);

            _icon = UIGraphicsGetImageFromCurrentImageContext();

            UIGraphicsEndImageContext();
        }
    }

    return _icon;
}

+ (IMTagCollectionViewCell *)instance {
    static IMTagCollectionViewCell *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

+ (CGSize)sizeThatFitsTag:(NSString *)tag andSize:(CGSize)size {
    CGSize textSize = [tag sizeWithAttributes:@{NSFontAttributeName : [IMTagCollectionViewCell textFont]}];
    CGSize removeIconSize = [IMTagCollectionViewCell removeIcon].size;

    return CGSizeMake(
            MIN(textSize.width, size.width) + removeIconSize.width + IMTagCollectionViewCellContentInsets.left + IMTagCollectionViewCellContentInsets.right,
            MIN(MAX(textSize.height, removeIconSize.height), size.height) + IMTagCollectionViewCellContentInsets.top + IMTagCollectionViewCellContentInsets.bottom
    );
}

@end
