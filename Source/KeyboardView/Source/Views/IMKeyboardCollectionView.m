//
//  ImojiSDKUI
//
//  Created by Jeff Wang
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

#import "IMKeyboardCollectionView.h"
#import "IMKeyboardCategoryCollectionViewCell.h"
#import "IMKeyboardCollectionViewCell.h"
#import "IMCollectionViewStatusCell.h"
#import "IMCollectionViewSplashCell.h"
#import "IMKeyboardView.h"
#import "IMKeyboardCollectionReusableAttributionView.h"

@interface IMKeyboardCollectionView ()

@property(nonatomic) UITapGestureRecognizer *doubleTapFolderGesture;

@end

@implementation IMKeyboardCollectionView {

}

@dynamic collectionViewDelegate;

- (instancetype)initWithSession:(IMImojiSession *)session {
    self = [super initWithSession:session];
    if (self) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionViewLayout = layout;
        self.backgroundColor = [UIColor clearColor];

        self.doubleTapFolderGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
        self.doubleTapFolderGesture.delaysTouchesBegan = YES;
        [self.doubleTapFolderGesture setNumberOfTapsRequired:2];
        [self.doubleTapFolderGesture setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:self.doubleTapFolderGesture];

        [self registerClass:[IMKeyboardCategoryCollectionViewCell class] forCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId];
        [self registerClass:[IMKeyboardCollectionViewCell class] forCellWithReuseIdentifier:IMCollectionViewCellReuseId];
        [self registerClass:[IMKeyboardCollectionReusableAttributionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:IMCollectionReusableAttributionViewReuseId];
    }

    return self;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize footerSize = [super collectionView:collectionView layout:collectionViewLayout referenceSizeForFooterInSection:section];

    // Check if shouldShowAttribution by checking footerSize is equal to CGSizeZero
    if(footerSize.width == CGSizeZero.width && footerSize.height == CGSizeZero.height) {
        return CGSizeZero;
    } else {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat screenH = screenSize.height;
        CGFloat screenW = screenSize.width;
        BOOL isLandscape = self.frame.size.width != (screenW * (screenW < screenH)) + (screenH * (screenW > screenH));

        if(isLandscape) {
            return CGSizeMake(self.frame.size.width, self.frame.size.height);
        } else {
            return footerSize;
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isPathShowingLoadingIndicator:indexPath]) {
        IMCollectionViewStatusCell *cell = (IMCollectionViewStatusCell *) [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
        cell.title.text = @""; // hide 'loading' text for keyboard
        return cell;
    } else if (self.contentType == IMCollectionViewContentTypeEnableFullAccessSplash) {
        IMCollectionViewSplashCell *splashCell =
                (IMCollectionViewSplashCell *) [self dequeueReusableCellWithReuseIdentifier:IMCollectionViewSplashCellReuseId forIndexPath:indexPath];

        [splashCell showSplashCellType:IMCollectionViewSplashCellEnableFullAccess withImageBundle:self.imagesBundle];
        return splashCell;
    } else {
        self.doubleTapFolderGesture.enabled = self.contentType == IMCollectionViewContentTypeImojis;
        return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape = self.frame.size.width != (screenW * (screenW < screenH)) + (screenH * (screenW > screenH));

    switch (self.contentType) {
        case IMCollectionViewContentTypeImojis:
        case IMCollectionViewContentTypeImojiCategories:
            if ([self isPathShowingLoadingIndicator:indexPath]) {

                // full sized loading indicator
                if (indexPath.row == 0) {
                    return self.frame.size;
                } else {
                    return CGSizeMake(100.f, self.frame.size.height);
                }
            } else if (isLandscape) {
                return CGSizeMake(100.f, self.frame.size.height / 1.3f);

            } else {
                return CGSizeMake(100.f, self.frame.size.height / 2.f);
            }

        default:
            return self.frame.size;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (void)loadRecentImojis:(NSArray *)recents {
    if (!recents || recents.count == 0) {
        [self displaySplashOfType:IMCollectionViewSplashCellRecents];
    } else {
        [self loadImojisFromIdentifiers:recents];
    }
}

- (void)processDoubleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [sender locationInView:self];
        NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
        if (indexPath && self.contentType == IMCollectionViewContentTypeImojis) {
            id cellContent = [super contentForIndexPath:indexPath];

            if (self.collectionViewDelegate &&
                    [self.collectionViewDelegate respondsToSelector:@selector(userDidDoubleTapImoji:fromCollectionView:)]) {

                [self.collectionViewDelegate userDidDoubleTapImoji:cellContent
                                                fromCollectionView:self];
            }

            [self processCellAnimations:indexPath];
        }
    }
}

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session {
    return [[IMKeyboardCollectionView alloc] initWithSession:session];
}

@end
