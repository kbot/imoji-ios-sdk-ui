//
// Created by Nima on 7/30/15.
// Copyright (c) 2015 Jeff. All rights reserved.
//

#import <Masonry/Masonry.h>
#import "IMKeyboardCollectionViewCell.h"
#import "IMCollectionView.h"


@implementation IMKeyboardCollectionViewCell {

}


- (void)loadImojiImage:(UIImage *)imojiImage {
    if (!self.imojiView) {
        self.imojiView = [UIImageView new];

        [self addSubview:self.imojiView];
        [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.and.height.equalTo(self).multipliedBy(.8f);
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
