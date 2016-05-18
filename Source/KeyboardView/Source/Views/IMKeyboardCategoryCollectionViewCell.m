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

#import <Masonry/Masonry.h>
#import <YYImage/YYAnimatedImageView.h>
#import "IMKeyboardCategoryCollectionViewCell.h"
#import "IMAttributeStringUtil.h"

@implementation IMKeyboardCategoryCollectionViewCell {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.placeholderView.contentMode = UIViewContentModeScaleAspectFit;

        [self.placeholderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.and.height.equalTo(@62.0f);
        }];

        [self.imojiView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(5.0f, 0.0f, 0.0f, 0.0f));
        }];

        [self.imojiImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.centerX.equalTo(self.imojiView);
            make.width.and.height.equalTo(@54.0f);
        }];

        self.titleView.font = [IMAttributeStringUtil montserratLightFontWithSize:11.0f];
        self.titleView.adjustsFontSizeToFitWidth = YES;

        [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imojiImageView.mas_bottom).offset(5.0f);
            make.width.and.centerX.equalTo(self.imojiView);
            make.bottom.equalTo(self.imojiView);
        }];
    }

    return self;
}

- (void)setupPlaceholderImageWithPosition:(NSUInteger)position {
    [super setupPlaceholderImageWithPosition:position];
    self.placeholderView.contentMode = UIViewContentModeScaleAspectFit;
}

@end
