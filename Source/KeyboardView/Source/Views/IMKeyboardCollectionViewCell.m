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
#import "IMKeyboardCollectionViewCell.h"
#import "IMCollectionView.h"
#import "IMResourceBundleUtil.h"


@implementation IMKeyboardCollectionViewCell {

}


- (void)loadImojiImage:(UIImage *)imojiImage {
    if (!self.imojiView) {
        self.imojiView = [UIImageView new];

        [self addSubview:self.imojiView];
        [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.and.height.equalTo(self).multipliedBy(.85f);
        }];
    }

    if (imojiImage) {
        self.imojiView.contentMode = UIViewContentModeScaleAspectFit;
        self.imojiView.image = imojiImage;
        self.imojiView.highlightedImage = [self tintImage:imojiImage withColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f]];
    } else {
        self.imojiView.contentMode = UIViewContentModeCenter;
        self.imojiView.image = [IMResourceBundleUtil loadingPlaceholderImageWithRadius:20];
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

- (void)performAnimation {
    // grow image
    [UIView animateWithDuration:0.15 animations:^{
                self.imojiView.transform = CGAffineTransformMakeScale(1.2, 1.2);
            }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.15 animations:^{
                             self.imojiView.transform = CGAffineTransformMakeScale(1, 1);
                         }];
                     }];
}

@end
