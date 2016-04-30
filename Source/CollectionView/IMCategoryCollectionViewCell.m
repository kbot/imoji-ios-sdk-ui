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
#import <YYImage/YYAnimatedImageView.h>
#import "IMResourceBundleUtil.h"
#import "IMAttributeStringUtil.h"

NSString *const IMCategoryCollectionViewCellReuseId = @"IMCategoryCollectionViewCellReuseId";

@implementation IMCategoryCollectionViewCell {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.placeholderView = [[UIImageView alloc] init];

        self.imojiView = [[UIView alloc] init];

        self.imojiImageView = [YYAnimatedImageView new];

        self.titleView = [UILabel new];
        self.titleView.font = [IMAttributeStringUtil montserratLightFontWithSize:14.0f];
        self.titleView.textColor = [UIColor colorWithRed:57.0f / 255.0f green:61.0f / 255.0f blue:73.0f / 255.0f alpha:1.0f];
        self.titleView.numberOfLines = 2;
        self.titleView.textAlignment = NSTextAlignmentCenter;
        self.titleView.lineBreakMode = NSLineBreakByWordWrapping;

        [self addSubview:self.placeholderView];
        [self addSubview:self.imojiView];

        [self.imojiView addSubview:self.imojiImageView];
        [self.imojiView addSubview:self.titleView];

        [self.placeholderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.and.height.equalTo(@100.0f);
        }];

        [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self.imojiImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imojiView).offset(6.0f);
            make.centerX.equalTo(self.imojiView);
//            make.height.width.equalTo(self.mas_height).multipliedBy(.70f);
            make.width.and.height.equalTo(@70.0f);
        }];

        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@100.0f);//.multipliedBy(.75f);
            make.centerX.equalTo(self.imojiView);
            make.top.equalTo(self.imojiImageView.mas_bottom).offset(6.0f);
            make.height.equalTo(@(self.titleView.font.lineHeight * 2.0f + 1.0f));
        }];
    }

    return self;
}

- (void)loadImojiCategory:(NSString *)categoryTitle imojiImojiImage:(UIImage *)imojiImage {
    [self loadImojiCategory:categoryTitle imojiImojiImage:imojiImage animated:YES];
}

- (void)loadImojiCategory:(NSString *)categoryTitle imojiImojiImage:(UIImage *)imojiImage animated:(BOOL)animated {
    BOOL showAnimations = animated && imojiImage != nil && !_hasImojiImage;

    if (imojiImage) {
        self.imojiImageView.image = imojiImage;
        self.imojiImageView.highlightedImage = [self tintImage:imojiImage withColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f]];
        self.imojiImageView.contentMode = UIViewContentModeScaleAspectFit;

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
        self.placeholderView.image = [[IMResourceBundleUtil loadingPlaceholderImageWithRadius:80.0f] copy];
        self.placeholderView.highlightedImage = self.placeholderView.image;
        self.placeholderView.contentMode = UIViewContentModeCenter;

        _hasImojiImage = NO;

        [self performLoadedAnimation];
    }

    self.titleView.text = categoryTitle;
}

- (void)performLoadedAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @0.0f;
    animation.toValue = @1.0f;
    animation.duration = 0.7f;
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.3f :0.14f :0.36f :1.36f];

    if (self.hasImojiImage) {
        [self.imojiView.layer addAnimation:animation forKey:@"layerAnimation"];
        self.imojiView.layer.transform = CATransform3DIdentity;
    } else {
        [self.placeholderView.layer addAnimation:animation forKey:@"layerAnimation"];
        self.placeholderView.layer.transform = CATransform3DIdentity;
    }
}

- (void)performRetractAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = @1.0f;
    animation.toValue = @0.0f;
    animation.duration = 1.0f;

    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25f :0.1f :0.25f :1.0f];

    [self.placeholderView.layer addAnimation:animation forKey:@"retract"];
    self.placeholderView.layer.transform = CATransform3DMakeScale(0.0f, 0.0f, 0.0f);
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
