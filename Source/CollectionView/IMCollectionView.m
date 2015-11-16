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

#import <ImojiSDK/ImojiSDK.h>
#import "IMCollectionView.h"
#import "IMCollectionViewCell.h"
#import "IMCategoryCollectionViewCell.h"
#import "IMCollectionViewStatusCell.h"
#import "IMCollectionViewSplashCell.h"
#import "IMResourceBundleUtil.h"
#import "IMConnectivityUtil.h"
#import "IMCollectionFooterView.h"
#import "IMArtistObject.h"
#import "IMCollectionHeaderView.h"

NSUInteger const IMCollectionViewNumberOfItemsToLoad = 60;

@interface IMCollectionView ()

@property(nonatomic, strong) NSMutableArray *images;
@property(nonatomic, strong) NSMutableArray *content;
@property(nonatomic, strong) NSMutableArray *pendingCollectionViewUpdates;
@property(nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property(nonatomic, strong) NSObject *loadingIndicatorObject;
@property(nonatomic, strong) NSOperation *imojiOperation;

@property(nonatomic, copy) NSString *currentSearchTerm;
@property(nonatomic, copy) NSString *currentHeader;
@property(nonatomic, strong) UIImage *artistPicture;

@property(nonatomic) NSUInteger renderCount;

@end

@implementation IMCollectionView {

}

- (instancetype)initWithSession:(IMImojiSession *)session {
    self = [super initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    if (self) {
        _session = session;
        _loadingIndicatorObject = [NSObject new];
        _imagesBundle = [IMResourceBundleUtil assetsBundle];
        _renderingOptions = session.fetchRenderingOptions;
        _preferredImojiDisplaySize = CGSizeMake(100.f, 100.f);
        _animateSelection = YES;
        _isArtist = NO;
        _currentHeader = @"";

        self.dataSource = self;
        self.delegate = self;

        self.numberOfImojisToLoad = IMCollectionViewNumberOfItemsToLoad;

        self.backgroundColor = [UIColor whiteColor];

        self.content = [NSMutableArray array];
        self.images = [NSMutableArray array];
        self.pendingCollectionViewUpdates = [NSMutableArray array];
        self.renderCount = 0;

        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(userTappedSplashView:)];
        self.tapGesture.enabled = NO;
        [self addGestureRecognizer:self.tapGesture];


        [self registerClass:[IMCollectionViewCell class] forCellWithReuseIdentifier:IMCollectionViewCellReuseId];
        [self registerClass:[IMCategoryCollectionViewCell class] forCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId];
        [self registerClass:[IMCollectionViewStatusCell class] forCellWithReuseIdentifier:IMCollectionViewStatusCellReuseId];
        [self registerClass:[IMCollectionViewSplashCell class] forCellWithReuseIdentifier:IMCollectionViewSplashCellReuseId];
        [self registerClass:[IMCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:IMCollectionHeaderViewReuseId];
        [self registerClass:[IMCollectionFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:IMCollectionFooterViewReuseId];
    }

    return self;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.content.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if(kind == UICollectionElementKindSectionHeader) {
        IMCollectionHeaderView *headerView = (IMCollectionHeaderView *) [self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                 withReuseIdentifier:IMCollectionHeaderViewReuseId
                                                                                                        forIndexPath:indexPath];

        [headerView setupWithText:self.currentHeader];

        return headerView;
    } else if(kind == UICollectionElementKindSectionFooter) {
        IMCollectionFooterView *footerView = (IMCollectionFooterView *) [self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                                 withReuseIdentifier:IMCollectionFooterViewReuseId
                                                                                                        forIndexPath:indexPath];

        [footerView setup];
        footerView.artistPicture.image = self.artistPicture;

        return footerView;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if(self.currentHeader.length > 0) {
        return CGSizeMake(self.frame.size.width, 49.0f);
    }

    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (self.isArtist) {
        return CGSizeMake(self.frame.size.width, 120.0f);
    }

    return CGSizeZero;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.tapGesture.enabled = NO;

    id cellContent = self.content[(NSUInteger) indexPath.row];

    if (cellContent == self.loadingIndicatorObject) {
        IMCollectionViewStatusCell *cell =
                (IMCollectionViewStatusCell *) [self dequeueReusableCellWithReuseIdentifier:IMCollectionViewStatusCellReuseId forIndexPath:indexPath];

        if (cellContent == self.loadingIndicatorObject) {
            [cell showLoading];
        } else {
            [cell showNoResults];
        }

        return cell;

    } else if (self.contentType == IMCollectionViewContentTypeImojiCategories) {
        IMImojiCategoryObject *categoryObject = cellContent;
        IMCategoryCollectionViewCell *cell =
                (IMCategoryCollectionViewCell *) [self dequeueReusableCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId forIndexPath:indexPath];

        [cell loadImojiCategory:categoryObject.title imojiImojiImage:nil];

        id image = self.images[(NSUInteger) indexPath.item];
        if ([image isKindOfClass:[UIImage class]]) {
            [cell loadImojiCategory:categoryObject.title imojiImojiImage:image];
        }

        return cell;
    } else if (self.contentType == IMCollectionViewContentTypeCollectionSplash) {
        IMCollectionViewSplashCell *splashCell =
                (IMCollectionViewSplashCell *) [self dequeueReusableCellWithReuseIdentifier:IMCollectionViewSplashCellReuseId forIndexPath:indexPath];
        self.tapGesture.enabled = YES;

        [splashCell showSplashCellType:IMCollectionViewSplashCellCollection withImageBundle:self.imagesBundle];
        return splashCell;
    } else if (self.contentType == IMCollectionViewContentTypeRecentsSplash) {
        IMCollectionViewSplashCell *splashCell =
                (IMCollectionViewSplashCell *) [self dequeueReusableCellWithReuseIdentifier:IMCollectionViewSplashCellReuseId forIndexPath:indexPath];
        self.tapGesture.enabled = YES;

        [splashCell showSplashCellType:IMCollectionViewSplashCellRecents withImageBundle:self.imagesBundle];
        return splashCell;
    } else if (self.contentType == IMCollectionViewContentTypeNoConnectionSplash) {
        IMCollectionViewSplashCell *splashCell =
                (IMCollectionViewSplashCell *) [self dequeueReusableCellWithReuseIdentifier:IMCollectionViewSplashCellReuseId forIndexPath:indexPath];
        self.tapGesture.enabled = YES;

        [splashCell showSplashCellType:IMCollectionViewSplashCellNoConnection withImageBundle:self.imagesBundle];
        return splashCell;
    } else if (self.contentType == IMCollectionViewContentTypeNoResultsSplash) {
        IMCollectionViewSplashCell *splashCell =
                (IMCollectionViewSplashCell *) [self dequeueReusableCellWithReuseIdentifier:IMCollectionViewSplashCellReuseId forIndexPath:indexPath];
        self.tapGesture.enabled = YES;

        [splashCell showSplashCellType:IMCollectionViewSplashCellNoResults withImageBundle:self.imagesBundle];
        return splashCell;
    } else {
        IMCollectionViewCell *cell =
                (IMCollectionViewCell *) [self dequeueReusableCellWithReuseIdentifier:IMCollectionViewCellReuseId forIndexPath:indexPath];
        [cell loadImojiImage:nil];

        id imojiImage = self.images[(NSUInteger) indexPath.row];
        if ([imojiImage isKindOfClass:[UIImage class]]) {
            [cell loadImojiImage:((UIImage *) imojiImage)];
        }

        return cell;
    }
}

#pragma mark UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.content[(NSUInteger) indexPath.row];
    return cellContent && ![cellContent isKindOfClass:[NSNull class]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.content[(NSUInteger) indexPath.row];

    if ([cellContent isKindOfClass:[IMImojiObject class]]) {
        if ([self.collectionViewDelegate respondsToSelector:@selector(userDidSelectImoji:fromCollectionView:)]) {
            [self.collectionViewDelegate userDidSelectImoji:cellContent
                                         fromCollectionView:self];
        }

        IMCollectionViewCell *cell = (IMCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        cell.imojiView.highlighted = NO;

        if (self.animateSelection) {
            [self processCellAnimations:indexPath];
        }

    } else if ([cellContent isKindOfClass:[IMImojiCategoryObject class]]) {
        if ([self.collectionViewDelegate respondsToSelector:@selector(userDidSelectCategory:fromCollectionView:)]) {
            [self.collectionViewDelegate userDidSelectCategory:cellContent
                                            fromCollectionView:self];
        }

        IMCategoryCollectionViewCell *cell = (IMCategoryCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
        cell.imojiView.highlighted = NO;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // check to see if the user is at the end of the scrollview
    // this is a iOS 7 safe approach since collectionView:willDisplayCell:forItemAtIndexPath:indexPath
    // is not supported`
    if (self.content.count > 1 && [self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]) {
        NSUInteger loadingPosition = [self.content indexOfObject:self.loadingIndicatorObject];

        if (loadingPosition != NSNotFound) {
            UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *) self.collectionViewLayout;

            CGSize loadingCellSize = [self collectionView:self
                                                   layout:flowLayout
                                   sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:loadingPosition inSection:0]];

            BOOL userIsAtEndOfList;
            if (flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
                userIsAtEndOfList = self.contentOffset.x + self.frame.size.width >= self.contentSize.width - loadingCellSize.width;
            } else {
                userIsAtEndOfList = self.contentOffset.y + self.frame.size.height >= self.contentSize.height - loadingCellSize.height;
            }

            if (userIsAtEndOfList) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadNextPageOfImojisFromSearch];
                });
            }
        }
    }

    if (self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(imojiCollectionViewDidScroll:)]) {
        [self.collectionViewDelegate imojiCollectionViewDidScroll:self];
    }
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    UIEdgeInsets insets = [self collectionView:collectionView
                                        layout:collectionViewLayout
                        insetForSectionAtIndex:indexPath.section];

    CGSize availableSize = CGSizeMake(
            self.frame.size.width - insets.right - insets.left - self.contentInset.left - self.contentInset.right,
            self.frame.size.height - insets.top - insets.bottom - self.contentInset.top - self.contentInset.bottom
    );

    // splash views occupy the full screen
    switch (self.contentType) {
        case IMCollectionViewContentTypeRecentsSplash:
        case IMCollectionViewContentTypeCollectionSplash:
        case IMCollectionViewContentTypeNoConnectionSplash:
        case IMCollectionViewContentTypeEnableFullAccessSplash:
        case IMCollectionViewContentTypeNoResultsSplash: {

            return availableSize;
        }
        default: {
            if ([self isPathShowingLoadingIndicator:indexPath]) {
                if (self.content.count == 1) {
                    return availableSize;
                } else {
                    return CGSizeMake(availableSize.width, self.preferredImojiDisplaySize.height);
                }
            }

            // ensure the Imoji stickers take up the entire view space so that they
            // do not get aligned to the edges when not using maxium space

            CGFloat numberOfImagesPerRow = floorf(availableSize.width / self.preferredImojiDisplaySize.width);
            CGFloat paddedSpace =
                    self.preferredImojiDisplaySize.width * (
                            availableSize.width / self.preferredImojiDisplaySize.width -
                                    numberOfImagesPerRow
                    ) / numberOfImagesPerRow;

            return CGSizeMake(
                    floorf(self.preferredImojiDisplaySize.width + paddedSpace),
                    floorf(self.preferredImojiDisplaySize.height + paddedSpace)
            );
        }
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    if (self.contentType == IMCollectionViewContentTypeImojiCategories) {
        return UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
    }

    return UIEdgeInsetsZero;
}

- (CGFloat)          collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (self.contentType == IMCollectionViewContentTypeImojiCategories) {
        return 15.0f;
    }

    return 0;
}

- (CGFloat)               collectionView:(UICollectionView *)collectionView
                                  layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark Imoji Loading

- (void)loadImojiCategories:(IMImojiSessionCategoryClassification)classification {
    switch(classification) {
        case IMImojiSessionCategoryClassificationTrending:
            self.currentHeader = @"Trending";
            break;
        case IMImojiSessionCategoryClassificationGeneric:
            self.currentHeader = @"Reactions";
            break;
        case IMImojiSessionCategoryClassificationArtist:
            self.currentHeader = @"Artist";
            break;
        default:
            break;
    }

    if (![IMConnectivityUtil sharedInstance].hasConnectivity) {
        self.contentType = IMCollectionViewContentTypeNoConnectionSplash;
        return;
    }

    self.contentType = IMCollectionViewContentTypeImojiCategories;
    [self generateNewResultSetOperationWithSearchOffset:nil];

    __block NSOperation *operation;
    self.imojiOperation = operation =
            [self.session getImojiCategoriesWithClassification:classification
                                                      callback:^(NSArray *imojiCategories, NSError *error) {
                                                          if (error) {
                                                              return;
                                                          }

                                                          [self.content removeAllObjects];
                                                          [self.content addObjectsFromArray:imojiCategories];
                                                          for (int i = 0; i < imojiCategories.count; ++i) {
                                                              [self.images addObject:[NSNull null]];
                                                          }

                                                          [self reloadData];

                                                          for (IMImojiCategoryObject *category in imojiCategories) {
                                                              if (operation.isCancelled) {
                                                                  break;
                                                              }

                                                              NSUInteger index = [imojiCategories indexOfObject:category];
                                                              [self renderImojiResult:category.previewImoji
                                                                              content:category
                                                                              atIndex:index
                                                                               offset:0
                                                                            operation:operation];
                                                          }

                                                          if (!operation.isCancelled && self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(imojiCollectionView:didFinishLoadingContentType:)]) {
                                                              [self.collectionViewDelegate imojiCollectionView:self didFinishLoadingContentType:self.contentType];
                                                          }
                                                      }];
}

- (void)loadFeaturedImojis {
    if (![IMConnectivityUtil sharedInstance].hasConnectivity) {
        self.contentType = IMCollectionViewContentTypeNoConnectionSplash;
        return;
    }

    self.contentType = IMCollectionViewContentTypeImojis;
    [self generateNewResultSetOperationWithSearchOffset:nil];

    __block NSOperation *operation;
    self.imojiOperation = operation =
            [self.session getFeaturedImojisWithNumberOfResults:@(self.numberOfImojisToLoad)
                                     resultSetResponseCallback:^(NSNumber *resultCount, NSError *error) {
                                         if (!operation.isCancelled) {
                                             [self prepareViewForImojiResultSet:resultCount
                                                                         offset:0
                                                                          error:error
                                                        emptyResultsContentType:IMCollectionViewContentTypeNoResultsSplash];
                                         }
                                     }
                                         imojiResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
                                             if (!operation.isCancelled && !error) {
                                                 [self renderImojiResult:imoji
                                                                 content:imoji
                                                                 atIndex:index
                                                                  offset:0
                                                               operation:operation];
                                             }
                                         }];
}

- (void)loadImojisFromSearch:(NSString *)searchTerm {
    if (![IMConnectivityUtil sharedInstance].hasConnectivity) {
        self.contentType = IMCollectionViewContentTypeNoConnectionSplash;
        return;
    }

    self.currentHeader = self.isCategory ? self.currentHeader : searchTerm;
    self.currentSearchTerm = searchTerm;
    [self loadImojisFromSearch:searchTerm offset:nil];
}

- (void)loadImojisFromSentence:(NSString *)sentence {
    if (![IMConnectivityUtil sharedInstance].hasConnectivity) {
        self.contentType = IMCollectionViewContentTypeNoConnectionSplash;
        return;
    }

    self.currentSearchTerm = nil;
    self.contentType = IMCollectionViewContentTypeImojis;
    [self generateNewResultSetOperationWithSearchOffset:nil];

    __block NSOperation *operation;
    self.imojiOperation = operation =
            [self.session searchImojisWithSentence:sentence
                                   numberOfResults:@(self.numberOfImojisToLoad)
                         resultSetResponseCallback:^(NSNumber *resultCount, NSError *error) {
                             if (!operation.isCancelled) {
                                 [self prepareViewForImojiResultSet:resultCount
                                                             offset:0
                                                              error:error
                                            emptyResultsContentType:IMCollectionViewContentTypeNoResultsSplash];
                             }
                         }
                             imojiResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
                                 if (!operation.isCancelled && !error) {
                                     [self renderImojiResult:imoji
                                                     content:imoji
                                                     atIndex:index
                                                      offset:0
                                                   operation:operation];
                                 }
                             }];
}

- (void)loadImojisFromIdentifiers:(NSArray *)imojiIdentifiers {
    if (![IMConnectivityUtil sharedInstance].hasConnectivity) {
        self.contentType = IMCollectionViewContentTypeNoConnectionSplash;
        return;
    }

    self.contentType = IMCollectionViewContentTypeImojis;
    [self generateNewResultSetOperationWithSearchOffset:nil];

    // allow the loading indicator to display by calling generateNewResultSetOperationWithSearchOffset:
    // before we reload the views
    dispatch_async(dispatch_get_main_queue(), ^{
        [self prepareViewForImojiResultSet:@(imojiIdentifiers.count)
                                    offset:0
                                     error:nil
                   emptyResultsContentType:IMCollectionViewContentTypeNoResultsSplash];

        __block NSOperation *operation;
        self.imojiOperation = operation =
                [self.session fetchImojisByIdentifiers:imojiIdentifiers
                               fetchedResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
                                   if (!operation.isCancelled && !error) {
                                       [self renderImojiResult:imoji
                                                       content:imoji
                                                       atIndex:index
                                                        offset:0
                                                     operation:operation];
                                   }
                               }];
    });
}

- (void)loadUserCollectionImojis {
    if (![IMConnectivityUtil sharedInstance].hasConnectivity) {
        self.contentType = IMCollectionViewContentTypeNoConnectionSplash;
        return;
    }

    self.contentType = IMCollectionViewContentTypeImojis;
    [self generateNewResultSetOperationWithSearchOffset:nil];

    __block NSOperation *operation;
    self.imojiOperation = operation =
            [self.session getImojisForAuthenticatedUserWithResultSetResponseCallback:^(NSNumber *resultCount, NSError *error) {
                        if (!operation.isCancelled) {
                            [self prepareViewForImojiResultSet:resultCount
                                                        offset:0
                                                         error:error
                                       emptyResultsContentType:IMCollectionViewContentTypeCollectionSplash];
                        }
                    }
                                                               imojiResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
                                                                   if (!operation.isCancelled && !error) {
                                                                       [self renderImojiResult:imoji
                                                                                       content:imoji
                                                                                       atIndex:index
                                                                                        offset:0
                                                                                     operation:operation];
                                                                   }
                                                               }];
}

- (void)loadImojisFromCategory:(nonnull IMImojiCategoryObject *)category {
    self.isArtist = NO;
    self.isCategory = YES;
    if(category) {//.artist) {
        self.isArtist = YES;
    }

    self.artistPicture = self.images[[self.content indexOfObject:category]];
    self.currentHeader = category.title;

    [self loadImojisFromSearch:category.identifier];
}

- (void)displaySplashOfType:(IMCollectionViewSplashCellType)splashType {
    switch (splashType) {
        case IMCollectionViewSplashCellNoConnection:
            self.contentType = IMCollectionViewContentTypeNoConnectionSplash;
            break;

        case IMCollectionViewSplashCellEnableFullAccess:
            self.contentType = IMCollectionViewContentTypeEnableFullAccessSplash;
            break;

        case IMCollectionViewSplashCellNoResults:
            self.contentType = IMCollectionViewContentTypeNoResultsSplash;
            break;

        case IMCollectionViewSplashCellRecents:
            self.contentType = IMCollectionViewContentTypeRecentsSplash;
            break;

        case IMCollectionViewSplashCellCollection:
            self.contentType = IMCollectionViewContentTypeCollectionSplash;
            break;

        default:
            break;
    }
}

#pragma mark Private Imoji Loading Methods

- (void)loadImojisFromSearch:(NSString *)searchTerm offset:(NSNumber *)offset {
    NSUInteger offsetValue = offset ? offset.unsignedIntegerValue - 1 : 0;

    if (!offset) {
        self.contentType = IMCollectionViewContentTypeImojis;
        [self generateNewResultSetOperationWithSearchOffset:offset];
    }

    __block NSOperation *operation;
    self.imojiOperation = operation =
            [self.session searchImojisWithTerm:searchTerm
                                        offset:offset
                               numberOfResults:@(self.numberOfImojisToLoad)
                     resultSetResponseCallback:^(NSNumber *resultCount, NSError *error) {
                         if (!operation.isCancelled) {
                             [self prepareViewForImojiResultSet:resultCount
                                                         offset:offsetValue
                                                          error:error
                                        emptyResultsContentType:IMCollectionViewContentTypeNoResultsSplash];
                         }
                     }
                         imojiResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
                             if (!operation.isCancelled && !error) {
                                 [self renderImojiResult:imoji
                                                 content:imoji
                                                 atIndex:index
                                                  offset:offsetValue
                                               operation:operation];
                             }

                             // append the loading indicator to the content to fetch the next set of results
                             if (index + 1 == self.numberOfImojisToLoad) {
                                 [self performBatchUpdates:^{
                                             [self.content addObject:self.loadingIndicatorObject];
                                             [self insertItemsAtIndexPaths:@[
                                                     [NSIndexPath indexPathForItem:self.content.count - 1
                                                                         inSection:0]
                                             ]];
                                         }
                                                completion:nil];
                             }
                         }];
}

- (void)loadNextPageOfImojisFromSearch {
    // do not append the next set of imojis until the current set of them has completely rendered to avoid
    // mutating the data model while the collection view is reloading
    if (self.currentSearchTerm != nil && self.renderCount == 0) {
        [self performBatchUpdates:^{
                    [self.content removeObject:self.loadingIndicatorObject];

                    [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.content.count inSection:0]]];
                }
                       completion:^(BOOL finished) {
                           [self loadImojisFromSearch:self.currentSearchTerm offset:@(self.content.count + 1)];
                       }];


    }
}

- (void)generateNewResultSetOperationWithSearchOffset:(NSNumber *)searchOffset {
    if (!searchOffset) {
        self.renderCount = 0;
        [self.images removeAllObjects];
        [self.content removeAllObjects];
        [self.pendingCollectionViewUpdates removeAllObjects];

        self.contentOffset = CGPointMake(-self.contentInset.left, -self.contentInset.top);

        // loading indicator exists already for results with an offset
        if (self.contentType == IMCollectionViewContentTypeImojis || self.contentType == IMCollectionViewContentTypeImojiCategories) {
            [self.content addObject:self.loadingIndicatorObject];
        }
    }

    if (self.imojiOperation && !self.imojiOperation.isCancelled) {
        [self.imojiOperation cancel];
    }

    [self reloadData];
}

- (void)prepareViewForImojiResultSet:(NSNumber *)resultCount
                              offset:(NSUInteger)offset
                               error:(NSError *)error
             emptyResultsContentType:(IMCollectionViewContentType)emptyResultsContentType {
    __block NSUInteger loadingOffset = [self.content indexOfObject:self.loadingIndicatorObject];

    if (offset == 0) {
        [self.content removeAllObjects];
        [self.images removeAllObjects];
        [self.pendingCollectionViewUpdates removeAllObjects];

        self.contentOffset = CGPointMake(-self.contentInset.left, -self.contentInset.top);

        if (resultCount.unsignedIntegerValue == 0) {
            self.contentType = emptyResultsContentType;
            return;
        }
    }

    if (!error) {
        __block NSMutableArray *insertedPaths = [NSMutableArray arrayWithCapacity:MAX(resultCount.unsignedIntegerValue, 1)];
        if (resultCount.unsignedIntegerValue > 0) {
            [self.content removeObject:self.loadingIndicatorObject];

            for (NSUInteger i = 0; i < resultCount.unsignedIntValue; ++i) {
                [self.content addObject:[NSNull null]];
                [self.images addObject:[NSNull null]];

                [insertedPaths addObject:[NSIndexPath indexPathForRow:i + offset inSection:0]];
            }
        }

        if (insertedPaths.count > 0 || loadingOffset != NSNotFound) {
            // TODO: address assertion issue with insert/removal that occurs when a user quickly switches from categories to imojis
            if (offset == 0) {
                [self reloadData];
            } else {
                [self performBatchUpdates:^{
                            if (loadingOffset != NSNotFound) {
                                [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:loadingOffset inSection:0]]];
                            }

                            if (insertedPaths.count > 0) {
                                [self insertItemsAtIndexPaths:insertedPaths];
                            }
                        }
                               completion:nil];
            }
        }

        if (self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(imojiCollectionView:didFinishLoadingContentType:)]) {
            [self.collectionViewDelegate imojiCollectionView:self didFinishLoadingContentType:self.contentType];
        }
    }
}

- (void)renderImojiResult:(IMImojiObject *)imoji
                  content:(id)content
                  atIndex:(NSUInteger)index
                   offset:(NSUInteger)offset
                operation:(NSOperation *)operation {
    self.renderCount++;
    self.content[index + offset] = content;
    [self.session renderImoji:imoji
                      options:self.renderingOptions
                     callback:^(UIImage *image, NSError *renderError) {
                         if (self.renderCount > 0) {
                             self.renderCount--;
                         }

                         if (!operation.isCancelled) {
                             self.images[index + offset] = image ? image : [NSNull null];
                             NSIndexPath *newPath = [NSIndexPath indexPathForItem:(index + offset) inSection:0];

                             // immediately reload cells for iOS 8 and later, for iOS 7, we need to batch the updates
                             if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
                                 BOOL doReload = self.pendingCollectionViewUpdates.count == 0;
                                 [self.pendingCollectionViewUpdates addObject:newPath];

                                 // if the pending collection view list was empty, go ahead and call the reload method, otherwise, allow
                                 // the method to perform the reload after the last batch update completes
                                 
                                 if (doReload) {
                                     [self reloadPendingUpdatesWithOperation:operation];
                                 }
                             } else {
                                 [self performBatchUpdates:^{
                                     [self reloadItemsAtIndexPaths:@[newPath]];
                                 } completion:nil];
                             }
                         }
                     }];
}

- (void)reloadPendingUpdatesWithOperation:(NSOperation *)operation {
    if (self.pendingCollectionViewUpdates.count > 0) {
        __block NSOrderedSet *updates = [NSOrderedSet orderedSetWithArray:self.pendingCollectionViewUpdates];
        [self performBatchUpdates:^{
            if (!operation.isCancelled) {
                [self reloadItemsAtIndexPaths:updates.array];
            }
        }              completion:^(BOOL finished) {
            [self.pendingCollectionViewUpdates removeObjectsInArray:updates.array];
            // recurse in case there are new items to reload
            [self reloadPendingUpdatesWithOperation:operation];
        }];
    }
}

- (void)userTappedSplashView:(UITapGestureRecognizer *)sender {
    if (self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(userDidSelectSplash:fromCollectionView:)]) {
        switch (self.contentType) {
            case IMCollectionViewContentTypeRecentsSplash:
                [self.collectionViewDelegate userDidSelectSplash:IMCollectionViewSplashCellRecents fromCollectionView:self];
                break;

            case IMCollectionViewContentTypeCollectionSplash:
                [self.collectionViewDelegate userDidSelectSplash:IMCollectionViewSplashCellCollection fromCollectionView:self];
                break;

            case IMCollectionViewContentTypeNoConnectionSplash:
                [self.collectionViewDelegate userDidSelectSplash:IMCollectionViewSplashCellNoConnection fromCollectionView:self];
                break;

            case IMCollectionViewContentTypeEnableFullAccessSplash:
                [self.collectionViewDelegate userDidSelectSplash:IMCollectionViewSplashCellEnableFullAccess fromCollectionView:self];
                break;

            case IMCollectionViewContentTypeNoResultsSplash:
                [self.collectionViewDelegate userDidSelectSplash:IMCollectionViewSplashCellNoResults fromCollectionView:self];
                break;

            default:
                break;
        }
    }
}

#pragma mark Public Overridable Methods

- (void)processCellAnimations:(NSIndexPath *)currentIndexPath {
    for (UICollectionViewCell *cell in self.visibleCells) {
        NSIndexPath *indexPath = [self indexPathForCell:cell];

        if (currentIndexPath.row == indexPath.row) {
            [(IMCollectionViewCell *) cell performGrowAnimation];
        } else {
            [(IMCollectionViewCell *) cell performTranslucentAnimation];
        }
    }
}

- (id)contentForIndexPath:(NSIndexPath *)path {
    return path.row > self.content.count ? nil : self.content[(NSUInteger) path.row];
}

- (BOOL)isPathShowingLoadingIndicator:(NSIndexPath *)indexPath {
    id cellContent = [self contentForIndexPath:indexPath];
    return (cellContent == self.loadingIndicatorObject);
}

#pragma mark Properties

- (void)setNumberOfImojisToLoad:(NSUInteger)numberOfImojisToLoad {
    _numberOfImojisToLoad = numberOfImojisToLoad;
    [self reloadData];
}

- (void)setPreferredImojiDisplaySize:(CGSize)preferredImojiDisplaySize {
    _preferredImojiDisplaySize = preferredImojiDisplaySize;
    [self reloadData];
}

- (void)setRenderingOptions:(IMImojiObjectRenderingOptions *)renderingOptions {
    _renderingOptions = renderingOptions;
    [self reloadData];
}

- (void)setImagesBundle:(NSBundle *)imagesBundle {
    _imagesBundle = imagesBundle;
    [self reloadData];
}

- (void)setContentType:(IMCollectionViewContentType)contentType {
    BOOL dirty = _contentType != contentType;
    _contentType = contentType;

    if (dirty) {
        switch (contentType) {
            case IMCollectionViewContentTypeRecentsSplash:
            case IMCollectionViewContentTypeCollectionSplash:
            case IMCollectionViewContentTypeNoConnectionSplash:
            case IMCollectionViewContentTypeEnableFullAccessSplash:
            case IMCollectionViewContentTypeNoResultsSplash:

                // add a filler object for rendering splashes
                [self.content removeAllObjects];
                [self.content addObject:[NSNull null]];
                break;

            default:
                break;
        }

        [self reloadData];
    }
}

#pragma mark Initialization

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session {
    return [[IMCollectionView alloc] initWithSession:session];
}

@end
