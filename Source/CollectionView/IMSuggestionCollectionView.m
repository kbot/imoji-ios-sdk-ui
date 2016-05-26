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

#import <ImojiSDKUI/IMCollectionLoadingView.h>
#import <ImojiSDKUI/IMCollectionViewCell.h>
#import <ImojiSDKUI/IMSuggestionView.h>
#import <ImojiSDKUI/IMSuggestionCategoryViewCell.h>
#import <ImojiSDKUI/IMSuggestionCollectionView.h>
#import <ImojiSDKUI/IMSuggestionCollectionReusableAttributionView.h>
#import <ImojiSDKUI/IMSuggestionCollectionReusableHeaderView.h>
#import <ImojiSDKUI/IMSuggestionLoadingViewCell.h>
#import <ImojiSDKUI/IMSuggestionSplashViewCell.h>
#import <ImojiSDKUI/IMSuggestionViewCell.h>
#import <Masonry/Masonry.h>

@implementation IMSuggestionCollectionView {

}

- (instancetype)initWithSession:(nonnull IMImojiSession *)session {
    self = [super initWithSession:session];
    if (self) {
        [self registerClass:[IMSuggestionLoadingViewCell class] forCellWithReuseIdentifier:IMCollectionViewStatusCellReuseId];
        [self registerClass:[IMSuggestionSplashViewCell class] forCellWithReuseIdentifier:IMCollectionViewSplashCellReuseId];
        [self registerClass:[IMSuggestionViewCell class] forCellWithReuseIdentifier:IMCollectionViewCellReuseId];
        [self registerClass:[IMSuggestionCategoryViewCell class] forCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId];
        [self registerClass:[IMSuggestionCollectionReusableHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:IMCollectionReusableHeaderViewReuseId];
        [self registerClass:[IMSuggestionCollectionReusableAttributionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:IMCollectionReusableAttributionViewReuseId];

        self.scrollsToTop = NO;
        self.showsHorizontalScrollIndicator = NO;

        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
            self.loadingView.title.hidden = YES;

            [self.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
                make.width.and.height.equalTo(self);
            }];

            [self.loadingView.activityIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
            }];
        }
    }

    return self;
}

- (void)processCellAnimations:(nonnull NSIndexPath *)currentIndexPath {
    // only animate the current selection
    UICollectionViewCell *viewCell = [self cellForItemAtIndexPath:currentIndexPath];
    if (viewCell) {
        [(IMCollectionViewCell *) viewCell performTappedAnimation];
    }
}

#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    if ([cell isKindOfClass:[IMSuggestionLoadingViewCell class]]) {
        if ([self isPathShowingLoadingIndicator:indexPath] && [self numberOfItemsInSection:indexPath.section] != 1) {
            ((IMSuggestionLoadingViewCell *) cell).activityIndicatorView.hidden = YES;
        }
    }

    return cell;
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return CGSizeZero;
    }

    return CGSizeMake(15.0f, self.frame.size.height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if(self.frame.size.height > IMSuggestionViewDefaultHeight) {
        CGSize footerSize = [super collectionView:collectionView layout:collectionViewLayout referenceSizeForFooterInSection:section];

        // Check if shouldShowAttribution by checking footerSize is equal to CGSizeZero
        if(footerSize.width == CGSizeZero.width && footerSize.height == CGSizeZero.height) {
            return CGSizeZero;
        } else {
            return self.frame.size;
        }
    }

    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIEdgeInsets insets = [self collectionView:collectionView
                                        layout:collectionViewLayout
                        insetForSectionAtIndex:indexPath.section];

    CGSize availableSize = CGSizeMake(
            self.frame.size.width - insets.left * 2.0f,
            self.frame.size.height
    );

    switch (self.contentType) {
        case IMCollectionViewContentTypeImojis:
        case IMCollectionViewContentTypeImojiCategories:
            if ([self isPathShowingLoadingIndicator:indexPath] && [self numberOfItemsInSection:indexPath.section] == 1) {
                return CGSizeMake(self.preferredImojiDisplaySize.width, availableSize.height);
            }

            return self.preferredImojiDisplaySize;

        default:
            return availableSize;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if(section == 0) {
        CGSize footerSize = [super collectionView:collectionView layout:collectionViewLayout referenceSizeForFooterInSection:section];

        // Check if shouldShowAttribution by checking footerSize is equal to CGSizeZero
        if(footerSize.width == CGSizeZero.width && footerSize.height == CGSizeZero.height) {
            return UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
        }

        return UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 10.0f);
    }

    return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 10.0f);
}

@end
