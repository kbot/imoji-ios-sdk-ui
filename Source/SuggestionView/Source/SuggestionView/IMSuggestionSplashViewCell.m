//
// Created by Nima on 10/12/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "IMSuggestionSplashViewCell.h"
#import "View+MASAdditions.h"

@implementation IMSuggestionSplashViewCell {

}

- (void)showSplashCellType:(IMCollectionViewSplashCellType)splashCellType withImageBundle:(NSBundle *__nonnull)imageBundle {
    [super showSplashCellType:splashCellType withImageBundle:imageBundle];

    self.splashGraphic.hidden = YES;
    self.splashText.numberOfLines = 1;

    [self.splashText mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

@end
