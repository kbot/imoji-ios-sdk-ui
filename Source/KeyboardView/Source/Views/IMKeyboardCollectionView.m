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

    if (cellContent == self.noResultsIndicatorObject || cellContent == self.loadingIndicatorObject) {
        if (cellContent == self.loadingIndicatorObject) {
            IMCollectionViewStatusCell *cell = [self dequeueReusableCellWithReuseIdentifier:IMCollectionViewStatusCellReuseId forIndexPath:indexPath];
            [cell showLoading];
            cell.title.text = @"";

            // iOS 7 does not support collectionView:willDisplayCell:forItemAtIndexPath, fetch next page when displaying cell
            if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0.0" options:NSNumericSearch] == NSOrderedAscending) {
                [self loadNextPageOfImojisFromSearch];
            }

            return cell;
        } else {
            IMKeyboardCollectionViewSplashCell *splashCell = [self dequeueReusableCellWithReuseIdentifier:IMKeyboardCollectionViewSplashCellReuseId forIndexPath:indexPath];

            [splashCell setupSplashCellWithType:IMKeyboardCollectionViewSplashCellNoResults andImageBundle:self.imagesBundle];
            self.noResultsTapGesture.enabled = YES;
            return splashCell;
        }
    } else if(self.contentType == ImojiCollectionViewContentTypeCollectionSplash) {
        IMKeyboardCollectionViewSplashCell *splashCell = [self dequeueReusableCellWithReuseIdentifier:IMKeyboardCollectionViewSplashCellReuseId forIndexPath:indexPath];

        [splashCell setupSplashCellWithType:IMKeyboardCollectionViewSplashCellCollection andImageBundle:self.imagesBundle];
        return splashCell;
    } else if(self.contentType == ImojiCollectionViewContentTypeRecentsSplash) {
        IMKeyboardCollectionViewSplashCell *splashCell = [self dequeueReusableCellWithReuseIdentifier:IMKeyboardCollectionViewSplashCellReuseId forIndexPath:indexPath];

        [splashCell setupSplashCellWithType:IMKeyboardCollectionViewSplashCellRecents andImageBundle:self.imagesBundle];
        return splashCell;
    } else if(self.contentType == ImojiCollectionViewContentTypeNoConnectionSplash) {
        IMKeyboardCollectionViewSplashCell *splashCell = [self dequeueReusableCellWithReuseIdentifier:IMKeyboardCollectionViewSplashCellReuseId forIndexPath:indexPath];

        [splashCell setupSplashCellWithType:IMKeyboardCollectionViewSplashCellNoConnection andImageBundle:self.imagesBundle];
        return splashCell;
    } else if(self.contentType == ImojiCollectionViewContentTypeEnableFullAccessSplash) {
        IMKeyboardCollectionViewSplashCell *splashCell = [self dequeueReusableCellWithReuseIdentifier:IMKeyboardCollectionViewSplashCellReuseId forIndexPath:indexPath];

        [splashCell setupSplashCellWithType:IMKeyboardCollectionViewSplashCellEnableFullAccess andImageBundle:self.imagesBundle];
        return splashCell;
    } else if (self.contentType == ImojiCollectionViewContentTypeImojiCategories) {
        self.doubleTapFolderGesture.enabled = NO;
        IMImojiCategoryObject *categoryObject = cellContent;
        IMKeyboardCategoryCollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId forIndexPath:indexPath];

        [cell loadImojiCategory:categoryObject.title imojiImojiImage:nil];

        [self.session renderImoji:categoryObject.previewImoji
                          options:self.renderingOptions
                         callback:^(UIImage *image, NSError *error) {
                             if (!error) {
                                 [cell loadImojiCategory:categoryObject.title imojiImojiImage:image];
                             }
                         }];
        return cell;
    } else {
        self.doubleTapFolderGesture.enabled = YES;
        IMKeyboardCollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:IMCollectionViewCellReuseId forIndexPath:indexPath];
        [cell loadImojiImage:nil];

        if ([cellContent isKindOfClass:[IMImojiObject class]]) {
            [self.session renderImoji:cellContent
                              options:self.renderingOptions
                             callback:^(UIImage *image, NSError *error) {
                                 if (!error) {
                                     [cell loadImojiImage:image];
                                 }
                             }];
        }

        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.content[(NSUInteger) indexPath.row];

    // take appropriate action on the cell
    if (self.contentType == ImojiCollectionViewContentTypeImojiCategories) {
        [self userDidSelectCategory:cellContent];
    } else {
        IMImojiObject *imojiObject = cellContent;

        [self userDidBeginDownloadingImoji];

        IMImojiObjectRenderingOptions *renderOptions = [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeFullResolution];
        renderOptions.aspectRatio = [NSValue valueWithCGSize:CGSizeMake(16.0f, 9.0f)];
        renderOptions.maximumRenderSize = [NSValue valueWithCGSize:CGSizeMake(1000.0f, 1000.0f)];

        [self.session renderImoji:imojiObject
                          options:renderOptions
                         callback:^(UIImage *image, NSError *error) {
                             if (error) {
                                 NSLog(@"Error: %@", error);
                                 [self imojiDidFinishDownloadingWithMessage:@"UNABLE TO DOWNLOAD IMOJI"];
                             } else {
                                 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                 pasteboard.persistent = YES;
                                 [pasteboard setImage:image];

                                 [self imojiDidFinishDownloadingWithMessage:@"COPIED TO CLIPBOARD"];

                             }
                         }];

        // save to recents
        [self saveToRecents:imojiObject];
    }

    if (self.contentType == ImojiCollectionViewContentTypeImojiCategories) {
        IMKeyboardCategoryCollectionViewCell *cell = (IMKeyboardCategoryCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];

        cell.imojiView.highlighted = NO;
    } else {
        IMKeyboardCollectionViewCell *cell = (IMKeyboardCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];

        cell.imojiView.highlighted = NO;
        [self processCellAnimations:indexPath];
    }

    return;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape = self.frame.size.width != (screenW * (screenW < screenH)) + (screenH * (screenW > screenH));

    id cellContent = self.content[(NSUInteger) indexPath.row];

    // Make splash pages and the first loading cell occupy the whole frame
    if(cellContent == self.noResultsIndicatorObject || (cellContent == self.loadingIndicatorObject && indexPath.row == 0) ||
            self.contentType == ImojiCollectionViewContentTypeEnableFullAccessSplash  || self.contentType == ImojiCollectionViewContentTypeRecentsSplash ||
            self.contentType == ImojiCollectionViewContentTypeCollectionSplash || self.contentType == ImojiCollectionViewContentTypeNoConnectionSplash) {
        return self.frame.size;
    } else if(cellContent == self.loadingIndicatorObject) {
        return CGSizeMake(100.f, self.frame.size.height);
    } else if (isLandscape) {
        return CGSizeMake(100.f, self.frame.size.height / 1.3f);
    } else {
        return CGSizeMake(100.f, self.frame.size.height / 2.f);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (void)loadRecentImojis {
    self.contentType = ImojiCollectionViewContentTypeImojis;
    [self.content removeAllObjects];
    [self reloadData];

    if(![IMConnectivityUtil sharedInstance].hasConnectivity) {
        self.contentType = ImojiCollectionViewContentTypeNoConnectionSplash;
        [self.content addObject:[NSNull null]];
    } else {
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:self.appGroup];
        NSArray *savedArrayOfRecents = [shared objectForKey:@"recentImojis"];

        if(!savedArrayOfRecents) {
            self.contentType = ImojiCollectionViewContentTypeRecentsSplash;
            [self.content addObject:[NSNull null]];
        } else {
            for (NSUInteger i = 0; i < savedArrayOfRecents.count; ++i) {
                [self.content addObject:[NSNull null]];
            }

            [self.session fetchImojisByIdentifiers:savedArrayOfRecents
                           fetchedResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
                               if (!error) {
                                   NSUInteger offsetValue = 0;

                                   self.content[offsetValue + index] = imoji;

                                   [self reloadItemsAtIndexPaths:@[
                                           [NSIndexPath indexPathForItem:offsetValue + index inSection:0]
                                   ]];

                                   if(self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(imojiCollectionViewDidFinishSearching:)]) {
                                       [self.collectionViewDelegate imojiCollectionViewDidFinishSearching:self];
                                   }

                                   // append the loading indicator to the content to fetch the next set of results
                                   if (index + 1 == self.numberOfImojisToLoad) {
                                       //[self.content addObject:self.loadingIndicatorObject];

                                       [self reloadData];

                                   }
                               }
                           }];
        }
    }
}

- (void)loadFavoriteImojis {
    self.contentType = ImojiCollectionViewContentTypeImojis;
    [self.content removeAllObjects];
    [self reloadData];

    if(![IMConnectivityUtil sharedInstance].hasConnectivity) {
        self.contentType = ImojiCollectionViewContentTypeNoConnectionSplash;
        [self.content addObject:[NSNull null]];
    } else if (self.session.sessionState == IMImojiSessionStateConnectedSynchronized) {
//        [self.activityView startAnimating];

        [self.session getImojisForAuthenticatedUserWithResultSetResponseCallback:^(NSNumber *resultCount, NSError *error) {
//            [self.activityView stopAnimating];

            if (!error) {
                [self prepareResultsFromServerResponse:resultCount];
            }
        }                                                  imojiResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
            if (!error) {
                [self displayResultFromServerResponse:imoji index:index offset:nil];
            }
        }];

    } else {
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:self.appGroup];
        NSArray *savedArrayOfFavorites = [shared objectForKey:@"favoriteImojis"];

        if (!savedArrayOfFavorites) {
            self.contentType = ImojiCollectionViewContentTypeCollectionSplash;
            [self.content addObject:[NSNull null]];
        } else {
            for (NSUInteger i = 0; i < savedArrayOfFavorites.count; ++i) {
                [self.content addObject:[NSNull null]];
            }

            [self.session fetchImojisByIdentifiers:savedArrayOfFavorites
                           fetchedResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
                               if (!error) {
                                   NSUInteger offsetValue = 0;

                                   self.content[offsetValue + index] = imoji;

                                   [self reloadItemsAtIndexPaths:@[
                                           [NSIndexPath indexPathForItem:offsetValue + index inSection:0]
                                   ]];

                                   if(self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(imojiCollectionViewDidFinishSearching:)]) {
                                       [self.collectionViewDelegate imojiCollectionViewDidFinishSearching:self];
                                   }

                                   // append the loading indicator to the content to fetch the next set of results
                                   if (index + 1 == self.numberOfImojisToLoad) {
                                       //[self.content addObject:self.loadingIndicatorObject];

                                       [self reloadData];

                                   }
                               }
                           }];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(imojiCollectionView: userDidScroll:)]) {
        [self.collectionViewDelegate imojiCollectionView:self userDidScroll:scrollView];
    }
}

- (void)saveToRecents:(IMImojiObject *)imojiObject {
    NSUInteger arrayCapacity = 20;
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:self.appGroup];
    NSArray *savedArrayOfRecents = [shared objectForKey:@"recentImojis"];
    NSMutableArray *arrayOfRecents = [NSMutableArray arrayWithCapacity:arrayCapacity];

    if (!savedArrayOfRecents || savedArrayOfRecents.count == 0) {
        [arrayOfRecents addObject:imojiObject.identifier];
    } else {
        [arrayOfRecents addObjectsFromArray:savedArrayOfRecents];

        if ([arrayOfRecents containsObject:imojiObject.identifier]) {
            [arrayOfRecents removeObject:imojiObject.identifier];
        }
        [arrayOfRecents insertObject:imojiObject.identifier atIndex:0];

        while (arrayOfRecents.count > arrayCapacity) {
            [arrayOfRecents removeLastObject];
        }
    }

    [shared setObject:arrayOfRecents forKey:@"recentImojis"];
    [shared synchronize];
}

- (void)saveToFavorites:(IMImojiObject *)imojiObject {
    if (self.session.sessionState == IMImojiSessionStateConnectedSynchronized) {
        [self.session addImojiToUserCollection:imojiObject
                                      callback:^(BOOL successful, NSError *error) {

                                      }];
    } else {
        NSUInteger arrayCapacity = 20;
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:self.appGroup];
        NSArray *savedArrayOfFavorites = [shared objectForKey:@"favoriteImojis"];
        NSMutableArray *arrayOfFavorites = [NSMutableArray arrayWithCapacity:arrayCapacity];

        if (!savedArrayOfFavorites || savedArrayOfFavorites.count == 0) {
            [arrayOfFavorites addObject:imojiObject.identifier];
        } else {
            [arrayOfFavorites addObjectsFromArray:savedArrayOfFavorites];

            if ([arrayOfFavorites containsObject:imojiObject.identifier]) {
                [arrayOfFavorites removeObject:imojiObject.identifier];
            }
            [arrayOfFavorites insertObject:imojiObject.identifier atIndex:0];

            while (arrayOfFavorites.count > arrayCapacity) {
                [arrayOfFavorites removeLastObject];
            }
        }

        [shared setObject:arrayOfFavorites forKey:@"favoriteImojis"];
        [shared synchronize];
    }
}

- (void)prepareResultsFromServerResponse:(NSNumber *)resultCount {
    [self.content removeAllObjects];

    NSUInteger count = resultCount.unsignedIntegerValue;
    if (count > 0) {
        for (NSUInteger i = 0; i < count; ++i) {
            [self.content addObject:[NSNull null]];
        }
    } else if (self.content.count == 0) {
        //[self.content addObject:self.noResultsIndicatorObject];
    }

    [self reloadData];

    if(self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(imojiCollectionViewDidFinishSearching:)]) {
        [self.collectionViewDelegate imojiCollectionViewDidFinishSearching:self];
    }
}

- (void)displayResultFromServerResponse:(IMImojiObject *)imoji
                                  index:(NSUInteger)index
                                 offset:(NSNumber *)offset {
    NSUInteger offsetValue = 0;
    if (offset) {
        offsetValue = offset.unsignedIntegerValue - 1;
    }

    self.content[offsetValue + index] = imoji;

    [self reloadItemsAtIndexPaths:@[
            [NSIndexPath indexPathForItem:offsetValue + index inSection:0]
    ]];

    // append the loading indicator to the content to fetch the next set of results
    if (index + 1 == self.numberOfImojisToLoad) {
        //[self.content addObject:self.loadingIndicatorObject];

        [self reloadData];
    }
}

- (void)processCellAnimations:(NSIndexPath *)currentIndexPath {

    for (UICollectionViewCell *cell in self.visibleCells) {
        NSIndexPath *indexPath = [self indexPathForCell:cell];

        if (currentIndexPath.row == indexPath.row) {
            [(IMKeyboardCollectionViewCell *) cell performGrowAnimation];
        } else {
            [(IMKeyboardCollectionViewCell *) cell performTranslucentAnimation];
        }

    }
}

- (void)processDoubleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [sender locationInView:self];
        NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
        if (indexPath) {
            id cellContent = self.content[(NSUInteger) indexPath.row];
            if (self.contentType == ImojiCollectionViewContentTypeImojis) {
                IMImojiObject *imojiObject = cellContent;
                // save to favorites
                [self saveToFavorites:imojiObject];

                [self userDidAddImojiToCollection];
                [self processCellAnimations:indexPath];
            }
        }
    }
}

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category {
    if (self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(userDidSelectCategory:)]) {
        [self.collectionViewDelegate userDidSelectCategory:category];
    }
}

- (void)userDidBeginDownloadingImoji {
    if (self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(userDidBeginDownloadingImoji)]) {
        [self.collectionViewDelegate userDidBeginDownloadingImoji];
    }
}

- (void)imojiDidFinishDownloadingWithMessage:(NSString *)message {
    if (self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(imojiDidFinishDownloadingWithMessage:)]) {
        [self.collectionViewDelegate imojiDidFinishDownloadingWithMessage:message];
    }
}

- (void)userDidAddImojiToCollection {
    if (self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(userDidAddImojiToCollection)]) {
        [self.collectionViewDelegate userDidAddImojiToCollection];
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
