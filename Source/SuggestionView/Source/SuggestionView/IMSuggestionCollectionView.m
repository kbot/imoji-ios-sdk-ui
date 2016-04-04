//
// Created by Nima on 10/12/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "IMSuggestionCollectionView.h"
#import "IMSuggestionLoadingViewCell.h"
#import "IMSuggestionSplashViewCell.h"
#import "IMCollectionViewCell.h"
#import "IMSuggestionViewCell.h"
#import "IMSuggestionCategoryViewCell.h"


@implementation IMSuggestionCollectionView {

}

- (instancetype)initWithSession:(nonnull IMImojiSession *)session {
    self = [super initWithSession:session];
    if (self) {
        [self registerClass:[IMSuggestionLoadingViewCell class] forCellWithReuseIdentifier:IMCollectionViewStatusCellReuseId];
        [self registerClass:[IMSuggestionSplashViewCell class] forCellWithReuseIdentifier:IMCollectionViewSplashCellReuseId];
        [self registerClass:[IMSuggestionViewCell class] forCellWithReuseIdentifier:IMCollectionViewCellReuseId];
        [self registerClass:[IMSuggestionCategoryViewCell class] forCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId];

        self.scrollsToTop = NO;
    }

    return self;
}

- (void)processCellAnimations:(nonnull NSIndexPath *)currentIndexPath {
    // only animate the current selection
    UICollectionViewCell *viewCell = [self cellForItemAtIndexPath:currentIndexPath];
    if (viewCell) {
        [(IMCollectionViewCell *) viewCell performGrowAnimation];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

@end
