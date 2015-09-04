//
// Created by Nima on 4/7/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <ImojiSDK/ImojiSDK.h>
#import "IMCollectionView.h"
#import "IMCollectionViewCell.h"
#import "IMCategoryCollectionViewCell.h"
#import "IMCollectionViewStatusCell.h"

typedef NS_ENUM(NSUInteger, ImojiCollectionViewContentType) {
    ImojiCollectionViewContentTypeImojis,
    ImojiCollectionViewContentTypeImojiCategories
};

NSUInteger const IMCollectionViewNumberOfItemsToLoad = 60;
CGFloat const IMCollectionViewImojiCategoryLeftRightInset = 10.0f;

@interface IMCollectionView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) NSMutableArray *images;
@property(nonatomic, strong) NSMutableArray *reloadPaths;
@property(nonatomic) ImojiCollectionViewContentType contentType;

@property(nonatomic, strong) NSObject *loadingIndicatorObject;
@property(nonatomic, strong) NSObject *noResultsIndicatorObject;
@property(nonatomic, copy) NSString *currentSearchTerm;

@property(nonatomic, strong) NSOperation *imojiOperation;
@property(nonatomic) BOOL runningBatchUpdates;
@property(nonatomic) NSUInteger renderCount;
@end

@implementation IMCollectionView {

}

- (instancetype)initWithSession:(IMImojiSession *)session {
    self = [super initWithFrame:CGRectZero collectionViewLayout:[UICollectionViewFlowLayout new]];
    if (self) {
        _session = session;

        self.dataSource = self;
        self.delegate = self;
        self.noResultsIndicatorObject = [NSObject new];
        self.loadingIndicatorObject = [NSObject new];

        self.numberOfImojisToLoad = IMCollectionViewNumberOfItemsToLoad;
        self.sideInsets = IMCollectionViewImojiCategoryLeftRightInset;


        self.backgroundColor = [UIColor whiteColor];

        self.content = [NSMutableArray array];
        self.images = [NSMutableArray array];
        self.reloadPaths = [NSMutableArray array];
        self.runningBatchUpdates = NO;
        self.renderCount = 0;

        [self registerClass:[IMCollectionViewCell class] forCellWithReuseIdentifier:IMCollectionViewCellReuseId];
        [self registerClass:[IMCategoryCollectionViewCell class] forCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId];
        [self registerClass:[IMCollectionViewStatusCell class] forCellWithReuseIdentifier:IMCollectionViewStatusCellReuseId];
    }

    return self;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.content.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.content[(NSUInteger) indexPath.row];

    if (cellContent == self.noResultsIndicatorObject || cellContent == self.loadingIndicatorObject) {
        IMCollectionViewStatusCell *cell = [self dequeueReusableCellWithReuseIdentifier:IMCollectionViewStatusCellReuseId forIndexPath:indexPath];

        if (cellContent == self.loadingIndicatorObject) {
            [cell showLoading];

            // iOS 7 does not support collectionView:willDisplayCell:forItemAtIndexPath, fetch next page when displaying cell
            if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0.0" options:NSNumericSearch] == NSOrderedAscending) {
                [self loadNextPageOfImojisFromSearch];
            }

        } else {
            [cell showNoResults];
        }

        return cell;

    } else if (self.contentType == ImojiCollectionViewContentTypeImojiCategories) {
        IMImojiCategoryObject *categoryObject = cellContent;
        IMCategoryCollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId forIndexPath:indexPath];

        id image = self.images[(NSUInteger) indexPath.item];

        [cell loadImojiCategory:categoryObject.title imojiImojiImage:([image isKindOfClass:[UIImage class]] ? image : nil)];

        return cell;
    } else {
        IMCollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:IMCollectionViewCellReuseId forIndexPath:indexPath];
        BOOL hasImage = cell.hasImojiImage;
        [cell loadImojiImage:nil];

        id imojiImage = self.images[(NSUInteger) indexPath.row];
        if ([imojiImage isKindOfClass:[UIImage class]]) {
            [cell loadImojiImage:((UIImage *) imojiImage)];

            // animate in the results
            if (!hasImage) {
                cell.imojiView.transform = CGAffineTransformMakeScale(.1f, .1f);
                [UIView animateWithDuration:.5f
                                      delay:0
                     usingSpringWithDamping:1.0f
                      initialSpringVelocity:1.0f
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     cell.imojiView.transform = CGAffineTransformIdentity;
                                 }
                                 completion:nil];
            }
        }

        return cell;
    }
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 0) {
        id content = self.content[(NSUInteger) indexPath.row];
        if (content == self.loadingIndicatorObject) {
            [self loadNextPageOfImojisFromSearch];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.content[(NSUInteger) indexPath.row];
    return cellContent && ![cellContent isKindOfClass:[NSNull class]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.content[(NSUInteger) indexPath.row];

    if ([cellContent isKindOfClass:[IMImojiObject class]] && self.imojiSelectedCallback) {
        self.imojiSelectedCallback(cellContent);
    } else if ([cellContent isKindOfClass:[IMImojiCategoryObject class]] && self.categorySelectedCallback) {
        self.categorySelectedCallback(cellContent);
    }
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id content = self.content[(NSUInteger) indexPath.row];
    if (self.content.count == 1) {
        if (content == self.loadingIndicatorObject || content == self.noResultsIndicatorObject) {
            return CGSizeMake(self.frame.size.width, self.frame.size.height);
        }
    } else if (content == self.loadingIndicatorObject) {
        // loading indicator at the bottom of the results
        return CGSizeMake(self.frame.size.width, 100.0f);
    }

    if (self.contentType == ImojiCollectionViewContentTypeImojis) {
        return CGSizeMake(self.frame.size.width / 3.0f, 100.0f);
    }

    return CGSizeMake(self.frame.size.width - (self.sideInsets * 2.0f), 100.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.contentType == ImojiCollectionViewContentTypeImojis) {
        return UIEdgeInsetsZero;
    }

    return UIEdgeInsetsMake(0, self.sideInsets, 0, self.sideInsets);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark Imoji Loading

- (void)loadImojiCategories:(IMImojiSessionCategoryClassification)classification {
    self.contentType = ImojiCollectionViewContentTypeImojiCategories;
    [self generateNewResultSetOperationWithSearchOffset:nil];

    __block NSOperation *operation;
    self.imojiOperation = operation =
            [self.session getImojiCategoriesWithClassification:classification
                                                      callback:^(NSArray *imojiCategories, NSError *error) {
                                                          if (!operation.isCancelled) {
                                                              [self.content addObjectsFromArray:imojiCategories];

                                                              for (int i = 0; i < imojiCategories.count; ++i) {
                                                                  [self.images addObject:[NSNull null]];
                                                              }

                                                              [self reloadData];

                                                              for (IMImojiCategoryObject *category in imojiCategories) {
                                                                  NSUInteger index = [imojiCategories indexOfObject:category];
                                                                  [self renderImojiResult:category.previewImoji
                                                                                  content:category
                                                                                  atIndex:index
                                                                                   offset:0
                                                                                operation:operation];
                                                              }
                                                          }
                                                      }];
}

- (void)loadFeaturedImojis {
    self.contentType = ImojiCollectionViewContentTypeImojis;
    [self generateNewResultSetOperationWithSearchOffset:nil];

    __block NSOperation *operation;
    self.imojiOperation = operation =
            [self.session getFeaturedImojisWithNumberOfResults:@(self.numberOfImojisToLoad)
                                     resultSetResponseCallback:^(NSNumber *resultCount, NSError *error) {
                                         if (!operation.isCancelled) {
                                             [self prepareViewForImojiResultSet:resultCount offset:0 error:error];
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
    self.currentSearchTerm = searchTerm;
    [self loadImojisFromSearch:searchTerm offset:nil];
}

- (void)loadImojisFromSearch:(NSString *)searchTerm offset:(NSNumber *)offset {
    NSUInteger offsetValue = offset ? offset.unsignedIntegerValue - 1 : 0;

    if (!offset) {
        self.contentType = ImojiCollectionViewContentTypeImojis;
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
                                                          error:error];
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
                                 [self.content addObject:self.loadingIndicatorObject];
                                 [self reloadData];
                             }
                         }];
}

- (void)loadUserCollectionImojis {
    __block NSOperation *operation;
    self.imojiOperation = operation =
            [self.session getImojisForAuthenticatedUserWithResultSetResponseCallback:^(NSNumber *resultCount, NSError *error) {
                        if (!operation.isCancelled) {
                            [self prepareViewForImojiResultSet:resultCount
                                                        offset:0
                                                         error:error];
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


- (void)loadNextPageOfImojisFromSearch {
    // do not append the next set of imojis until the current set of them has completely rendered to avoid
    // mutating the data model while the collection view is reloading
    if (self.currentSearchTerm != nil && self.renderCount == 0) {
        [self.content removeObject:self.loadingIndicatorObject];
        [self loadImojisFromSearch:self.currentSearchTerm offset:@(self.content.count + 1)];
    }
}

- (IMImojiObjectRenderingOptions *)renderingOptions {
    return [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail];
}

- (void)generateNewResultSetOperationWithSearchOffset:(NSNumber *)searchOffset {
    [self.reloadPaths removeAllObjects];

    if (!searchOffset) {
        self.renderCount = 0;
        [self.images removeAllObjects];
        [self.content removeAllObjects];

        // loading indicator exists already for results with an offset
        if (self.contentType == ImojiCollectionViewContentTypeImojis) {
            [self.content addObject:self.loadingIndicatorObject];
        }
    }

    if (self.imojiOperation) {
        [self.imojiOperation cancel];
        self.imojiOperation = nil;
    }

    [self reloadData];
}

- (void)prepareViewForImojiResultSet:(NSNumber *)resultCount offset:(NSUInteger)offset error:(NSError *)error {
    if (offset == 0) {
        [self.content removeAllObjects];
        [self.images removeAllObjects];
    }

    if (!error) {
        if (resultCount.unsignedIntegerValue > 0) {
            for (NSUInteger i = 0; i < resultCount.unsignedIntValue; ++i) {
                [self.content addObject:[NSNull null]];
                [self.images addObject:[NSNull null]];
            }
        } else {
            [self.content addObject:self.noResultsIndicatorObject];
        }

        [self reloadData];
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

                         if (operation && !operation.isCancelled) {
                             self.images[index + offset] = image ? image : [NSNull null];
                             [self.reloadPaths addObject:[NSIndexPath indexPathForItem:(index + offset) inSection:0]];
                             [self runBatchUpdate];
                         }
                     }];
}

- (void)runBatchUpdate {
    // queue up update to avoid iOS 7's restrictions
    if (self.reloadPaths.count > 0 && !self.runningBatchUpdates) {
        __block NSArray *paths = [NSArray arrayWithArray:self.reloadPaths];
        self.runningBatchUpdates = YES;
        [self performBatchUpdates:^{
                    [self reloadItemsAtIndexPaths:paths];
                }
                       completion:^(BOOL finished) {
                           [self.reloadPaths removeObjectsInArray:paths];
                           self.runningBatchUpdates = NO;

                           [self runBatchUpdate];
                       }];
    }
}

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session {
    return [[IMCollectionView alloc] initWithSession:session];
}

+ (UIImage *)placeholderImageWithRadius:(CGFloat)radius {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius, radius), NO, 0.f);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:.3f].CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 0);
    CGContextFillEllipseInRect(context, CGRectMake(0, 0, radius, radius));

    UIImage *layer = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return layer;
}

@end
