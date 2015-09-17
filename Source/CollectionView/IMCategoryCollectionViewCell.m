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

#import "IMCategoryCollectionViewCell.h"
#import <Masonry/View+MASAdditions.h>
#import "IMCollectionView.h"

NSString *const IMCategoryCollectionViewCellReuseId = @"IMCategoryCollectionViewCellReuseId";

@implementation IMCategoryCollectionViewCell {

}

- (void)loadImojiCategory:(NSString *)categoryTitle imojiImojiImage:(UIImage *)imojiImage {
    [self loadImojiCategory:categoryTitle imojiImojiImage:imojiImage animated:YES];
}

- (void)loadImojiCategory:(NSString *)categoryTitle imojiImojiImage:(UIImage *)imojiImage animated:(BOOL)animated {
    if (!self.imojiView) {
        self.imojiView = [UIImageView new];

        [self addSubview:self.imojiView];
        [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.centerY.equalTo(self);
            make.height.width.equalTo(self.mas_height).multipliedBy(.75f);
        }];
    }

    if (!self.titleView) {
        self.titleView = [UILabel new];

        [self addSubview:self.titleView];

        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.centerY.equalTo(self);
            make.left.equalTo(self.imojiView.mas_right).offset(10);
        }];
    }

    BOOL showAnimations = animated && imojiImage != nil && !self.imojiView.image;
    
    if (imojiImage) {
        self.imojiView.image = imojiImage;
        self.imojiView.highlightedImage = [self tintImage:imojiImage withColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f]];
        self.imojiView.contentMode = UIViewContentModeScaleAspectFit;
        
        if (showAnimations) {
            self.imojiView.transform = CGAffineTransformMakeScale(.2f, .2f);
        }
    } else {
        self.imojiView.image = [IMCollectionView placeholderImageWithRadius:30];
        self.imojiView.contentMode = UIViewContentModeCenter;
    }

    self.titleView.text = categoryTitle;
    
    if (showAnimations) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.5f
                                  delay:0
                 usingSpringWithDamping:1.0f
                  initialSpringVelocity:1.0f
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.imojiView.transform = CGAffineTransformIdentity;
                             }
                             completion:nil];
        });
    }
}


- (UIImage *)tintImage:(UIImage*)image withColor:(UIColor *)tintColor {
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
