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
#import "IMKeyboardCollectionViewSplashCell.h"
#import "IMConnectivityUtil.h"

@interface IMKeyboardCollectionView ()

@property(nonatomic) UITapGestureRecognizer *doubleTapFolderGesture;
@property(nonatomic) UITapGestureRecognizer *noResultsTapGesture;
@property(nonatomic, strong) NSBundle *imagesBundle;

@end

@implementation IMKeyboardCollectionView {

}

- (instancetype)initWithSession:(IMImojiSession *)session {
    self = [super initWithSession:session];
    if (self) {
        self.imagesBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"ImojiKeyboardAssets" ofType:@"bundle"]];

        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionViewLayout = layout;
        self.backgroundColor = [UIColor clearColor];

        self.doubleTapFolderGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
        self.doubleTapFolderGesture.delaysTouchesBegan = YES;
        [self.doubleTapFolderGesture setNumberOfTapsRequired:2];
        [self.doubleTapFolderGesture setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:self.doubleTapFolderGesture];

        self.noResultsTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(userDidTapNoResultsView:)];
        self.noResultsTapGesture.enabled = NO;
        [self addGestureRecognizer:self.noResultsTapGesture];

        [self registerClass:[IMKeyboardCategoryCollectionViewCell class] forCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId];
        [self registerClass:[IMKeyboardCollectionViewCell class] forCellWithReuseIdentifier:IMCollectionViewCellReuseId];
        [self registerClass:[IMKeyboardCollectionViewSplashCell class] forCellWithReuseIdentifier:IMKeyboardCollectionViewSplashCellReuseId];
    }

    return self;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.noResultsTapGesture.enabled = NO;
    id cellContent = self.content[(NSUInteger) indexPath.row];

    if (cellContent == self.loadingIndicatorObject) {
        IMCollectionViewStatusCell *cell = (IMCollectionViewStatusCell *) [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
        cell.title.text = @""; // hide 'loading' text for keyboard
        return cell;
    } else if (cellContent == self.noResultsIndicatorObject) {
        IMKeyboardCollectionViewSplashCell *splashCell = [self dequeueReusableCellWithReuseIdentifier:IMKeyboardCollectionViewSplashCellReuseId forIndexPath:indexPath];

        [splashCell setupSplashCellWithType:IMKeyboardCollectionViewSplashCellNoResults andImageBundle:self.imagesBundle];
        self.noResultsTapGesture.enabled = YES;
        return splashCell;
    } else if (self.contentType == ImojiCollectionViewContentTypeCollectionSplash) {
        IMKeyboardCollectionViewSplashCell *splashCell = [self dequeueReusableCellWithReuseIdentifier:IMKeyboardCollectionViewSplashCellReuseId forIndexPath:indexPath];

        [splashCell setupSplashCellWithType:IMKeyboardCollectionViewSplashCellCollection andImageBundle:self.imagesBundle];
        return splashCell;
    } else if (self.contentType == ImojiCollectionViewContentTypeRecentsSplash) {
        IMKeyboardCollectionViewSplashCell *splashCell = [self dequeueReusableCellWithReuseIdentifier:IMKeyboardCollectionViewSplashCellReuseId forIndexPath:indexPath];

        [splashCell setupSplashCellWithType:IMKeyboardCollectionViewSplashCellRecents andImageBundle:self.imagesBundle];
        return splashCell;
    } else if (self.contentType == ImojiCollectionViewContentTypeNoConnectionSplash) {
        IMKeyboardCollectionViewSplashCell *splashCell = [self dequeueReusableCellWithReuseIdentifier:IMKeyboardCollectionViewSplashCellReuseId forIndexPath:indexPath];

        [splashCell setupSplashCellWithType:IMKeyboardCollectionViewSplashCellNoConnection andImageBundle:self.imagesBundle];
        return splashCell;
    } else if (self.contentType == ImojiCollectionViewContentTypeEnableFullAccessSplash) {
        IMKeyboardCollectionViewSplashCell *splashCell = [self dequeueReusableCellWithReuseIdentifier:IMKeyboardCollectionViewSplashCellReuseId forIndexPath:indexPath];

        [splashCell setupSplashCellWithType:IMKeyboardCollectionViewSplashCellEnableFullAccess andImageBundle:self.imagesBundle];
        return splashCell;
    } else {
        self.doubleTapFolderGesture.enabled = self.contentType == ImojiCollectionViewContentTypeImojis;
        return [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape = self.frame.size.width != (screenW * (screenW < screenH)) + (screenH * (screenW > screenH));

    id cellContent = self.content[(NSUInteger) indexPath.row];

    // Make splash pages and the first loading cell occupy the whole frame
    if (cellContent == self.noResultsIndicatorObject || (cellContent == self.loadingIndicatorObject && indexPath.row == 0) ||
            self.contentType == ImojiCollectionViewContentTypeEnableFullAccessSplash || self.contentType == ImojiCollectionViewContentTypeRecentsSplash ||
            self.contentType == ImojiCollectionViewContentTypeCollectionSplash || self.contentType == ImojiCollectionViewContentTypeNoConnectionSplash) {
        return self.frame.size;
    } else if (cellContent == self.loadingIndicatorObject) {
        return CGSizeMake(100.f, self.frame.size.height);
    } else if (isLandscape) {
        return CGSizeMake(100.f, self.frame.size.height / 1.3f);
    } else {
        return CGSizeMake(100.f, self.frame.size.height / 2.f);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (void)loadRecentImojis:(NSArray *)recents {
    self.contentType = ImojiCollectionViewContentTypeImojis;
    [self.content removeAllObjects];
    [self reloadData];

    if (![IMConnectivityUtil sharedInstance].hasConnectivity) {
        self.contentType = ImojiCollectionViewContentTypeNoConnectionSplash;
        [self.content addObject:[NSNull null]];
    } else {
        if (!recents || recents.count == 0) {
            self.contentType = ImojiCollectionViewContentTypeRecentsSplash;
            [self.content addObject:[NSNull null]];
        } else {
            [self loadImojisFromIdentifiers:recents];
        }
    }
}

- (void)loadFavoriteImojis:(NSArray *)favoritedImojis {
    self.contentType = ImojiCollectionViewContentTypeImojis;
    [self.content removeAllObjects];
    [self reloadData];

    if (![IMConnectivityUtil sharedInstance].hasConnectivity) {
        self.contentType = ImojiCollectionViewContentTypeNoConnectionSplash;
        [self.content addObject:[NSNull null]];
    } else if (self.session.sessionState == IMImojiSessionStateConnectedSynchronized) {
        [self loadUserCollectionImojis];
    } else {
        if (!favoritedImojis || favoritedImojis.count == 0) {
            self.contentType = ImojiCollectionViewContentTypeCollectionSplash;
            [self.content addObject:[NSNull null]];
        } else {
            [self loadImojisFromIdentifiers:favoritedImojis];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(imojiCollectionView: userDidScroll:)]) {
        [self.collectionViewDelegate imojiCollectionView:self userDidScroll:scrollView];
    }
}

- (void)processDoubleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [sender locationInView:self];
        NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
        if (indexPath) {
            id cellContent = self.content[(NSUInteger) indexPath.row];
            if (self.contentType == ImojiCollectionViewContentTypeImojis) {
                if (self.collectionViewDelegate &&
                        [self.collectionViewDelegate respondsToSelector:@selector(userDidDoubleTapImoji:fromCollectionView:)]) {

                    [self.collectionViewDelegate userDidDoubleTapImoji:cellContent
                                                    fromCollectionView:self];
                }

                [self processCellAnimations:indexPath];
            }
        }
    }
}

- (void)userDidTapNoResultsView:(UITapGestureRecognizer *)sender {
    if (self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(userDidTapNoResultsView)]) {
        [self.collectionViewDelegate userDidTapNoResultsView];
    }
}

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session {
    return [[IMKeyboardCollectionView alloc] initWithSession:session];
}

@end
