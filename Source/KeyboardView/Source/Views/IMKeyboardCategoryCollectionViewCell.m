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
#import "IMKeyboardCategoryCollectionViewCell.h"
#import "IMAttributeStringUtil.h"
#import "IMCollectionView.h"


@implementation IMKeyboardCategoryCollectionViewCell {

}


- (void)loadImojiCategory:(NSString *)categoryTitle imojiImojiImage:(UIImage *)imojiImage {
    float imageHeightRatio = 0.75f;
    float textHeightRatio = 0.18f;
    int inBetweenPadding = 3;

    if (!self.imojiView) {
        self.imojiView = [UIImageView new];

        [self addSubview:self.imojiView];
        [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.height.width.equalTo(self.mas_height).multipliedBy(imageHeightRatio);
            make.top.equalTo(self.mas_top);
        }];
    }

    if (!self.titleView) {
        self.titleView = [UILabel new];
        self.titleView.adjustsFontSizeToFitWidth = YES;

        [self addSubview:self.titleView];
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.equalTo(self);
            make.height.equalTo(self.mas_height).multipliedBy(textHeightRatio);
            make.top.equalTo(self.imojiView.mas_bottom).offset(inBetweenPadding);
        }];
    }

    if (imojiImage) {
        self.imojiView.contentMode = UIViewContentModeScaleAspectFit;
        self.imojiView.image = imojiImage;
        self.imojiView.highlightedImage = [self tintImage:imojiImage withColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f]];
    } else {
        self.imojiView.contentMode = UIViewContentModeCenter;
        self.imojiView.image = [IMCollectionView placeholderImageWithRadius:20];
    }

    self.titleView.attributedText = [IMAttributeStringUtil attributedString:categoryTitle
                                                                   withFont:[IMAttributeStringUtil defaultFontWithSize:12.0f]
                                                                      color:[UIColor colorWithRed:60 / 255.f green:60 / 255.f blue:60 / 255.f alpha:1.f]
                                                               andAlignment:NSTextAlignmentCenter];
}

- (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGRect drawRect = CGRectMake(0, 0, image.size.width, image.size.height);
    [image drawInRect:drawRect];
    [tintColor set];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

@end
