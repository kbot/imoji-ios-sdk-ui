//
//  ImojiSDKUI
//
//  Created by Alex Hoang
//  Copyright (C) 2016 Imoji
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
#import <ImojiSDK/IMImojiObject.h>
#import <ImojiSDKUI/IMCollectionViewController.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import "FullScreenViewController.h"
#import "AppDelegate.h"

@interface FullScreenViewController () <IMCollectionViewControllerDelegate>

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

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:((AppDelegate *)[UIApplication sharedApplication].delegate).appGroup];
    self.searchView.createAndRecentsEnabled = [shared boolForKey:@"createAndRecents"];

    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    self.backButton.hidden = NO;
    [self.backButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_close.png", [IMResourceBundleUtil assetsBundle].bundlePath]] forState:UIControlStateNormal];

    self.topToolbar.barTintColor = [UIColor colorWithRed:250.0f / 255.0f green:250.0f / 255.0f blue:250.0f / 255.0f alpha:1.0f];

    [self.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
}

- (void)userDidSelectImoji:(IMImojiObject *__nonnull)imoji fromCollectionView:(IMCollectionView *__nonnull)collectionView {
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:((AppDelegate *)[UIApplication sharedApplication].delegate).appGroup];

    IMImojiObjectRenderingOptions *renderingOptions = [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeFullResolution
                                                                                               borderStyle:(IMImojiObjectBorderStyle) [shared integerForKey:@"stickerBorders"]];
    renderingOptions.aspectRatio = [NSValue valueWithCGSize:CGSizeMake(16.0f, 9.0f)];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.session markImojiUsageWithIdentifier:imoji.identifier originIdentifier:@"imoji kit full screen: imoji selected"];
    });

    [self.session renderImoji:imoji
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

- (void)userDidTapBackButtonFromSearchView:(IMSearchView *)searchView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidSelectAttributionLink:(NSURL *)attributionLink fromCollectionView:(IMCollectionView *)collectionView {
    [[UIApplication sharedApplication] openURL:attributionLink];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


@end
