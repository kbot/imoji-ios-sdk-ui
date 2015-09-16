//
// Created by Nima on 4/8/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <ImojiSDK/ImojiSDK.h>
#import <Masonry/Masonry.h>
#import <ImojiSDKUI/IMCollectionView.h>

#import "ImojiResultsView.h"
#import "ImojiDetailsView.h"

CGFloat ImojiResultsViewButtonWidth = 35.0f;

@interface ImojiResultsView () <IMCollectionViewDelegate>
@property(nonatomic, strong) UIButton *closeButton;
@property(nonatomic, strong) ImojiDetailsView *detailsView;
@end

@implementation ImojiResultsView {

}

- (instancetype)initWithSession:(IMImojiSession *)session {
    self = [super initWithFrame:CGRectZero];

    if (self) {
        self.collectionView = [IMCollectionView imojiCollectionViewWithSession:session];
        self.detailsView = [ImojiDetailsView detailsViewWithSession:session];
        self.closeButton = [UIButton new];

        [self.closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];

        self.collectionView.layer.borderColor = [UIColor colorWithWhite:.2f alpha:1.0f].CGColor;
        self.collectionView.layer.borderWidth = 1.0f;
        self.collectionView.layer.cornerRadius = 9.0f;
        self.collectionView.clipsToBounds = YES;

        self.detailsView.hidden = YES;
        [self.detailsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(closeButtonTapped)]];

        self.collectionView.collectionViewDelegate = self;

        [self addSubview:self.collectionView];
        [self addSubview:self.detailsView];
        [self addSubview:self.closeButton];

        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.height.equalTo(self).multipliedBy(.9f);
        }];

        [self.detailsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.collectionView).offset(ImojiResultsViewButtonWidth / -4.0f);
            make.right.equalTo(self.collectionView).offset(ImojiResultsViewButtonWidth / 4.0f);
            make.width.and.height.equalTo(@(ImojiResultsViewButtonWidth));
        }];

        [self.closeButton setImage:[ImojiResultsView drawCloseButton:CGSizeMake(ImojiResultsViewButtonWidth, ImojiResultsViewButtonWidth)]
                          forState:UIControlStateNormal];

        self.backgroundColor = [UIColor colorWithWhite:.2f alpha:.3f];
    }

    return self;
}

- (void)closeButtonTapped {
    if (!self.detailsView.hidden) {
        [UIView animateWithDuration:.24f
                         animations:^{
                             self.detailsView.layer.opacity = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             self.detailsView.hidden = YES;
                         }];
    } else if (self.dismissedCallback) {
        self.dismissedCallback();
    }
}

#pragma mark IMCollectionViewDelegate

- (void)userDidSelectImoji:(IMImojiObject *)imoji fromCollectionView:(IMCollectionView *)collectionView {
    self.detailsView.hidden = NO;
    self.detailsView.layer.opacity = 0.0f;
    self.detailsView.imoji = imoji;

    [UIView animateWithDuration:.5f
                     animations:^{
                         self.detailsView.layer.opacity = 1.0f;
                     }];
}

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category fromCollectionView:(IMCollectionView *)collectionView {
    [self.collectionView loadImojisFromSearch:category.identifier];
}

#pragma mark Initialization

+ (instancetype)resultsViewWithSession:(IMImojiSession *)session {
    return [[ImojiResultsView alloc] initWithSession:session];
}

+ (UIImage *)drawCloseButton:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:34 / 255 green:34 / 255 blue:34 / 255 alpha:.6f].CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 0);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, size.width, size.height));

    CGContextSetLineWidth(context, 3.5);

    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    // draw X
    CGFloat relativeFrameScaleFactor = 3;
    CGContextMoveToPoint(context, size.width / relativeFrameScaleFactor, size.height / relativeFrameScaleFactor);
    CGContextAddLineToPoint(context, size.width - size.width / relativeFrameScaleFactor, size.height - size.height / relativeFrameScaleFactor);

    CGContextMoveToPoint(context, size.width - size.width / relativeFrameScaleFactor, size.height / relativeFrameScaleFactor);
    CGContextAddLineToPoint(context, size.width / relativeFrameScaleFactor, size.height - size.height / relativeFrameScaleFactor);

    CGContextStrokePath(context);

    UIImage *layer = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return layer;
}

@end
