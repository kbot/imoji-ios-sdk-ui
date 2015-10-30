//
// Created by Nima on 10/12/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "ImojiSuggestionCollectionView.h"
#import "ImojiSuggestionLoadingViewCell.h"
#import "ImojiSuggestionSplashViewCell.h"
#import "IMCollectionViewCell.h"
#import "ImojiSuggestionViewCell.h"
#import "ImojiSuggestionCategoryViewCell.h"


@implementation ImojiSuggestionCollectionView {

}

- (instancetype)initWithSession:(nonnull IMImojiSession *)session {
    self = [super initWithSession:session];
    if (self) {
        [self registerClass:[ImojiSuggestionLoadingViewCell class] forCellWithReuseIdentifier:IMCollectionViewStatusCellReuseId];
        [self registerClass:[ImojiSuggestionSplashViewCell class] forCellWithReuseIdentifier:IMCollectionViewSplashCellReuseId];
        [self registerClass:[ImojiSuggestionViewCell class] forCellWithReuseIdentifier:IMCollectionViewCellReuseId];
        [self registerClass:[ImojiSuggestionCategoryViewCell class] forCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId];

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


@end
