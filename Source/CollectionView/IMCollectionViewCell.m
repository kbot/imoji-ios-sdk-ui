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
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <YYImage/YYAnimatedImageView.h>
#import "IMCollectionViewCell.h"

NSString *const IMCollectionViewCellReuseId = @"ImojiCollectionViewCellReuseId";

@interface IMCollectionViewCell ()

@property(nonatomic, readonly) BOOL hasImojiImage;

@end

@implementation IMCollectionViewCell {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.placeholderView = [[UIImageView alloc] init];
        self.placeholderView.contentMode = UIViewContentModeCenter;

        self.imojiView = [YYAnimatedImageView new];

        [self addSubview:self.placeholderView];
        [self addSubview:self.imojiView];

        [self.placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.and.height.equalTo(@100.0f);
        }];

        [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
//            make.width.and.height.equalTo(self).multipliedBy(.8f);
            make.width.and.height.equalTo(@100.0f);
        }];
    }

    return self;
}

- (void)setupPlaceholderImageWithPosition:(NSUInteger)position {
    NSArray *placeholderImages = [IMResourceBundleUtil loadingPlaceholderImages];
    NSUInteger placeholderStartIndex = [IMResourceBundleUtil loadingPlaceholderStartIndex];

    self.placeholderView.image = placeholderImages[(placeholderStartIndex + position) % placeholderImages.count];
    self.placeholderView.highlightedImage = self.placeholderView.image;
    self.placeholderView.contentMode = UIViewContentModeCenter;
}

- (void)loadImojiImage:(UIImage *)imojiImage {
    [self loadImojiImage:imojiImage animated:YES];
}

- (void)loadImojiImage:(UIImage *)imojiImage animated:(BOOL)animated {
    if (imojiImage) {
        self.imojiView.image = imojiImage;
        self.imojiView.contentMode = UIViewContentModeScaleAspectFit;
        _hasImojiImage = YES;

        BOOL animateImmediately = ![self respondsToSelector:@selector(preferredLayoutAttributesFittingAttributes:)];

        if (animateImmediately) {
            [self performRetractAnimation];
            [self performLoadedAnimation];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performRetractAnimation];
                [self performLoadedAnimation];
            });
        }
    } else {
        self.imojiView.image = imojiImage;

        _hasImojiImage = NO;

        [self performLoadedAnimation];
    }
}

- (void)performLoadedAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @0.0f;
    animation.toValue = @1.0f;
    animation.duration = 0.7f;

    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.3f :0.14f :0.36f :1.36f];

    if(self.hasImojiImage) {
        [self.imojiView.layer addAnimation:animation forKey:@"loaded"];
        self.imojiView.layer.transform = CATransform3DIdentity;
    } else {
        [self.placeholderView.layer addAnimation:animation forKey:@"loaded"];
        self.placeholderView.layer.transform = CATransform3DIdentity;
    }
}

- (void)performPlaceholderRetractAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @1.0f;
    animation.toValue = @0.0f;
    animation.duration = 1.0f;

    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25f :0.1f :0.25f :1.0f];

    [self.placeholderView.layer addAnimation:animation forKey:@"retract"];
    self.placeholderView.layer.transform = CATransform3DMakeScale(0.0f, 0.0f, 0.0f);
}

- (void)performTappedAnimation {
    if (!self.hasImojiImage) {
        return;
    }

    [CATransaction begin];
    [self.imojiView.layer removeAllAnimations];
    [CATransaction commit];

    CABasicAnimation *contractAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    contractAnimation.fromValue = @1.0f;
    contractAnimation.toValue = @0.8f;
    contractAnimation.duration = 0.5f;

    CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    growAnimation.fromValue = @0.8f;
    growAnimation.toValue = @1.0f;
    growAnimation.duration = 0.5f;
    growAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.23f :0.09f :0.37f :1.36f];

    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    animationGroup.animations = @[contractAnimation, growAnimation];
    animationGroup.duration = 0.5f;

    [self.imojiView.layer addAnimation:animationGroup forKey:@"tapped"];
    self.imojiView.layer.transform = CATransform3DIdentity;
}

- (void)performGrowAnimation {
    if (!self.hasImojiImage) {
        return;
    }

    [CATransaction begin];
    [self.imojiView.layer removeAllAnimations];
    [CATransaction commit];

    CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    growAnimation.fromValue = @0.8f;
    growAnimation.toValue = @1.0f;
    growAnimation.duration = 0.5f;
    growAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.23f :0.09f :0.37f :1.16f];

    [self.imojiView.layer addAnimation:growAnimation forKey:@"grow"];
    self.imojiView.layer.transform = CATransform3DIdentity;
}

- (void)performShrinkAnimation {
    if (!self.hasImojiImage) {
        return;
    }

    [CATransaction begin];
    [self.imojiView.layer removeAllAnimations];
    [CATransaction commit];

    CABasicAnimation *contractAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    contractAnimation.fromValue = @1.0f;
    contractAnimation.toValue = @0.8f;
    contractAnimation.duration = 0.2f;

    [self.imojiView.layer addAnimation:contractAnimation forKey:@"shrink"];
    self.imojiView.layer.transform = CATransform3DMakeScale(0.8f, 0.8f, 0.8f);
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

//- (void)performGrowAnimation {
//    if (!self.hasImojiImage) {
//        return;
//    }
//
//    [CATransaction begin];
//    [self.imojiView.layer removeAllAnimations];
//    [CATransaction commit];
//    self.imojiView.alpha = 1.0;
//
//    // grow image
//    [UIView animateWithDuration:0.1 animations:^{
//                self.imojiView.transform = CGAffineTransformMakeScale(1.2, 1.2);
//            }
//                     completion:^(BOOL finished) {
//                         [UIView animateWithDuration:0.1f
//                                               delay:1.2f
//                                             options:UIViewAnimationOptionCurveLinear
//                                          animations:^{
//                                              self.imojiView.transform = CGAffineTransformMakeScale(1, 1);
//                                          } completion:nil];
//                     }];
//}
//
//- (void)performTranslucentAnimation {
//    if (!self.hasImojiImage) {
//        return;
//    }
//
//    [UIView animateWithDuration:0.1 animations:^{
//                self.imojiView.alpha = 0.5;
//            }
//                     completion:^(BOOL finished) {
//                         [UIView animateWithDuration:0.1f
//                                               delay:1.2f
//                                             options:UIViewAnimationOptionCurveLinear
//                                          animations:^{
//                                              self.imojiView.alpha = 1;
//                                          } completion:nil];
//                     }];
//}

@end

