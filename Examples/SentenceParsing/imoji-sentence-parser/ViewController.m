//
//  ViewController.m
//  imoji-sentence-parser
//
//  Created by Nima on 9/18/15.
//  Copyright © 2015 Imoji. All rights reserved.
//

#import "ViewController.h"
#import "IMCollectionView.h"

@interface ViewController () <IMCollectionViewControllerDelegate>

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    self.sentenceParseEnabled = YES;
    self.collectionViewControllerDelegate = self;
}

- (void)userDidSelectImoji:(IMImojiObject *__nonnull)imoji fromCollectionView:(IMCollectionView *__nonnull)collectionView {
    IMImojiObjectRenderingOptions *renderingOptions =
            [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeFullResolution];
    renderingOptions.aspectRatio = [NSValue valueWithCGSize:CGSizeMake(16.0f, 9.0f)];

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


@end
