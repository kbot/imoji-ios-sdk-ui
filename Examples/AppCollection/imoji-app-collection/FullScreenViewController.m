//
//  FullScreenViewController.m
//  Collection
//
//  Created by Alex Hoang on 4/26/16.
//  Copyright © 2016 Imoji. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <ImojiSDK/ImojiSDK.h>
#import <ImojiSDKUI/IMCollectionViewController.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import "FullScreenViewController.h"

@interface FullScreenViewController () <IMCollectionViewControllerDelegate>

@property(nonatomic, strong) IMImojiSession *imojiSession;

@end

@implementation FullScreenViewController

- (instancetype)initWithSession:(IMImojiSession *__nonnull)session {
    self = [super initWithSession:session];
    if (self) {
        self.title = @"Full Screen";
        self.collectionViewControllerDelegate = self;

        self.collectionView.infiniteScroll = YES;
    }

    return self;
}


- (void)loadView {
    [super loadView];

    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.backButton.hidden = NO;
    [self.backButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_close.png", [IMResourceBundleUtil assetsBundle].bundlePath]] forState:UIControlStateNormal];

    self.topToolbar.barTintColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];

    [self.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
}

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category fromCollectionView:(IMCollectionView *)collectionView {
    [collectionView loadImojisFromCategory:category];
}

- (void)userDidSelectImoji:(IMImojiObject *__nonnull)imoji fromCollectionView:(IMCollectionView *__nonnull)collectionView {
    IMImojiObjectRenderingOptions *renderingOptions =
            [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeFullResolution];
    renderingOptions.aspectRatio = [NSValue valueWithCGSize:CGSizeMake(16.0f, 9.0f)];

    [self.imojiSession renderImoji:imoji
                           options:renderingOptions
                          callback:^(UIImage *image, NSError *error) {
                              NSArray *sharingItems = @[image];
                              UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems
                                                                                                               applicationActivities:nil];
                              activityController.excludedActivityTypes = @[
                                      UIActivityTypePrint,
                                      UIActivityTypeCopyToPasteboard,
                                      UIActivityTypeAssignToContact,
                                      UIActivityTypeSaveToCameraRoll,
                                      UIActivityTypeAddToReadingList,
                                      UIActivityTypePostToFlickr,
                                      UIActivityTypePostToVimeo
                              ];

                              [self presentViewController:activityController animated:YES completion:nil];
                          }];
}

- (void)userDidSelectSplash:(IMCollectionViewSplashCellType)splashType fromCollectionView:(IMCollectionView *)collectionView {
    if (splashType == IMCollectionViewSplashCellNoResults) {
        [self.searchView.searchTextField becomeFirstResponder];
    }
}

- (void)userDidSelectToolbarButton:(IMToolbarButtonType)buttonType {
    switch (buttonType) {
        case IMToolbarButtonBack:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;

        default:
            break;
    }
}

- (void)userDidSelectAttributionLink:(NSURL *)attributionLink fromCollectionView:(IMCollectionView *)collectionView {
    [[UIApplication sharedApplication] openURL:attributionLink];
}

- (void)userDidPerformEmptySearchFromCollectionViewController:(nonnull UIViewController *)collectionViewController {
    [self.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


@end
