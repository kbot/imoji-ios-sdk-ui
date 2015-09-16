//
// Created by Nima on 7/20/15.
// Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import "IMCollectionViewCell.h"
#import <Masonry/View+MASAdditions.h>
#import "IMCollectionView.h"

NSString *const IMCollectionViewCellReuseId = @"ImojiCollectionViewCellReuseId";

@implementation IMCollectionViewCell {

}

- (void)loadImojiImage:(UIImage *)imojiImage {
    [self loadImojiImage:imojiImage animated:YES];
}

- (void)loadImojiImage:(UIImage *)imojiImage animated:(BOOL)animated {
    if (!self.imojiView) {
        self.imojiView = [UIImageView new];

        [self addSubview:self.imojiView];
        [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.and.height.equalTo(self).multipliedBy(.8f);
        }];
    }
    
    BOOL showAnimations = animated && imojiImage != nil && !_hasImojiImage;

    if (imojiImage) {
        self.imojiView.image = imojiImage;
        self.imojiView.highlightedImage = [self tintImage:imojiImage withColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f]];
        self.imojiView.contentMode = UIViewContentModeScaleAspectFit;
        _hasImojiImage = YES;

        if (showAnimations) {
            self.imojiView.transform = CGAffineTransformMakeScale(.2f, .2f);
        }
    } else {
        self.imojiView.image = [IMCollectionView placeholderImageWithRadius:30];
        self.imojiView.contentMode = UIViewContentModeCenter;
        _hasImojiImage = NO;
    }
    
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

- (void)performGrowAnimation {
    [CATransaction begin];
    [self.imojiView.layer removeAllAnimations];
    [CATransaction commit];
    self.imojiView.alpha = 1.0;
    
    // grow image
    [UIView animateWithDuration:0.1 animations:^{
        self.imojiView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        
    }
                     completion:^(BOOL finished){
                         if (!finished) {
                             return;
                         }
                         [UIView animateWithDuration:0.1f
                                               delay:1.2f
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              self.imojiView.transform = CGAffineTransformMakeScale(1, 1);
                                          } completion:^(BOOL finished) {}];
                     }];
}

- (void)performTranslucentAnimation {
    [UIView animateWithDuration:0.1 animations:^{
        self.imojiView.alpha = 0.5;
    }
                     completion:^(BOOL finished){
                         if (!finished) {
                             return;
                         }
                         [UIView animateWithDuration:0.1f
                                               delay:1.2f
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              self.imojiView.alpha = 1;
                                          } completion:^(BOOL finished) {}];
                     }];
}

@end

