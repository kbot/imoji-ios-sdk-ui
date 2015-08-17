//
//  ImojiCollectionView.m
//  imoji-keyboard
//
//  Created by Jeff on 6/7/15.
//  Copyright (c) 2015 Jeff. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "ImojiCollectionView.h"
#import "ImojiTextUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "IMKeyboardCategoryCollectionViewCell.h"
#import "IMKeyboardCollectionViewCell.h"

typedef NS_ENUM(NSUInteger, ImojiCollectionViewContentType) {
    ImojiCollectionViewContentTypeImojis,
    ImojiCollectionViewContentTypeImojiCategories
};


NSUInteger const ImojiCollectionViewNumberOfItemsToLoad = 30;

@interface ImojiCollectionView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) IMImojiSession *session;
@property(nonatomic, strong) NSMutableArray *content;
@property(nonatomic) ImojiCollectionViewContentType contentType;
@property(nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation ImojiCollectionView {
    
}

- (instancetype)initWithSession:(IMImojiSession *)session {
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self = [super initWithFrame:CGRectZero collectionViewLayout:layout];
    if (self) {
        self.session = session;
        self.dataSource = self;
        self.delegate = self;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.content = [NSMutableArray arrayWithCapacity:ImojiCollectionViewNumberOfItemsToLoad];
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:self.activityView];
        [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self);
        }];
        
        self.doubleTapFolderGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
        self.doubleTapFolderGesture.delaysTouchesBegan = YES;
        [self.doubleTapFolderGesture setNumberOfTapsRequired:2];
        [self.doubleTapFolderGesture setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:self.doubleTapFolderGesture];
        
        [self registerClass:[IMKeyboardCategoryCollectionViewCell class] forCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId];
        [self registerClass:[IMKeyboardCollectionViewCell class] forCellWithReuseIdentifier:IMCollectionViewCellReuseId];
    }
    
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.content.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.content[(NSUInteger) indexPath.row];

    if (self.contentType == ImojiCollectionViewContentTypeImojiCategories) {
        self.doubleTapFolderGesture.enabled = NO;
        IMImojiCategoryObject *categoryObject = cellContent;
        IMKeyboardCategoryCollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:IMCategoryCollectionViewCellReuseId forIndexPath:indexPath];
        
        [cell loadImojiCategory:categoryObject.title imojiImojiImage:nil];
        //NSLog(@"loading category: %@", categoryObject.title);
    
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
                                 } else {
                                     [cell loadImojiImage:nil];
                                 }
                             }];
        } else {
            [cell loadImojiImage:nil];
        }
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.contentType == ImojiCollectionViewContentTypeImojiCategories) {
        IMKeyboardCategoryCollectionViewCell *cell = (IMKeyboardCategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];

        cell.imojiView.highlighted = YES;
    } else {
        IMKeyboardCollectionViewCell *cell = (IMKeyboardCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        
        cell.imojiView.highlighted = YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.contentType == ImojiCollectionViewContentTypeImojiCategories) {
        IMKeyboardCategoryCollectionViewCell *cell = (IMKeyboardCategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        
        cell.imojiView.highlighted = NO;
    } else {
        IMKeyboardCollectionViewCell *cell = (IMKeyboardCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        
        cell.imojiView.highlighted = NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id cellContent = self.content[(NSUInteger) indexPath.row];
    
    // take appropriate action on the cell
    if (self.contentType == ImojiCollectionViewContentTypeImojiCategories) {
        IMImojiCategoryObject *categoryObject = cellContent;
        
        [self loadImojisFromSearch:categoryObject.identifier offset:nil];
    } else {
        IMImojiObject *imojiObject = cellContent;
        
        self.showDownloadingCallback();

        IMImojiObjectRenderingOptions* renderOptions = [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeFullResolution];
        renderOptions.aspectRatio = [NSValue valueWithCGSize:CGSizeMake(16.0f, 9.0f)];
        renderOptions.maximumRenderSize = [NSValue valueWithCGSize:CGSizeMake(1000.0f, 1000.0f)];
        
        [self.session renderImoji:imojiObject
                          options:renderOptions
                         callback:^(UIImage *image, NSError *error) {
                             if (error) {
                                 NSLog(@"Error: %@", error);
                                 self.showCopiedCallback(@"UNABLE TO DOWNLOAD IMOJI");
                             } else {
                                 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                 pasteboard.persistent = YES;
                                 [pasteboard setImage:image];

                                 self.showCopiedCallback(@"COPIED TO CLIPBOARD");
                                 
                             }
                         }];
        
        // save to recents
        [self saveToRecents:imojiObject];
    }
    
    if (self.contentType == ImojiCollectionViewContentTypeImojiCategories) {
        IMKeyboardCategoryCollectionViewCell *cell = (IMKeyboardCategoryCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        
        cell.imojiView.highlighted = NO;
    } else {
        IMKeyboardCollectionViewCell *cell = (IMKeyboardCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
        
        cell.imojiView.highlighted = NO;
        [self processCellAnimations:indexPath];
    }
    

    return;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape =  !(self.frame.size.width == (screenW*(screenW<screenH))+(screenH*(screenW>screenH)));
    
    if (isLandscape) {
        return CGSizeMake(100.f, self.frame.size.height / 1.3f);
    } else {
        return CGSizeMake(100.f, self.frame.size.height / 2.f);
    }

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"rotate");
    [self performBatchUpdates:nil completion:nil];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


- (void)loadRecentImojis {
    self.contentType = ImojiCollectionViewContentTypeImojis;
    //[self.content addObject:self.loadingIndicatorObject];
    [self.content removeAllObjects];
    [self reloadData];
    
    NSUserDefaults *shared = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.imoji.keyboard"];
    NSArray *savedArrayOfRecents = [shared objectForKey:@"recentImojis"];
    //NSLog(@"%@", savedArrayOfRecents);

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
                           self.setProgressCallback((self.contentOffset.x + self.frame.size.width)/self.collectionViewLayout.collectionViewContentSize.width);
                           
                           // append the loading indicator to the content to fetch the next set of results
                           if (index + 1 == ImojiCollectionViewNumberOfItemsToLoad) {
                               //[self.content addObject:self.loadingIndicatorObject];
                               
                               [self reloadData];
                               
                           }
                       }
                   }];
}

- (void)loadFavoriteImojis {
    self.contentType = ImojiCollectionViewContentTypeImojis;
    //[self.content addObject:self.loadingIndicatorObject];
    [self.content removeAllObjects];
    [self reloadData];
    
    NSUserDefaults *shared = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.imoji.keyboard"];
    NSArray *savedArrayOfFavorites = [shared objectForKey:@"favoriteImojis"];
    
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
                           self.setProgressCallback((self.contentOffset.x + self.frame.size.width)/self.collectionViewLayout.collectionViewContentSize.width);
                           
                           // append the loading indicator to the content to fetch the next set of results
                           if (index + 1 == ImojiCollectionViewNumberOfItemsToLoad) {
                               //[self.content addObject:self.loadingIndicatorObject];
                               
                               [self reloadData];
                               
                           }
                       }
                   }];
}


- (void)loadImojiCategories:(IMImojiSessionCategoryClassification) classification {
    self.contentType = ImojiCollectionViewContentTypeImojiCategories;
    [self.activityView startAnimating];
    [self.content removeAllObjects];
    [self reloadData];
    
    [self.session getImojiCategoriesWithClassification:classification
                                              callback:^(NSArray *imojiCategories, NSError *error) {
                                                  [self.content addObjectsFromArray:imojiCategories];
                                                  //NSLog(@"loading categories: %@", self.content);
                                                  [self.activityView stopAnimating];
                                                  [self reloadData];
                                                  self.currentCategoryClassification = classification;
                                                  self.setProgressCallback((self.contentOffset.x + self.frame.size.width)/self.collectionViewLayout.collectionViewContentSize.width);
                                              }];
}

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    self.setProgressCallback((scrollView.contentOffset.x + scrollView.frame.size.width)/scrollView.contentSize.width);
    
}

- (void)loadImojisFromSearch:(NSString *)searchTerm offset:(NSNumber *)offset {
    self.contentType = ImojiCollectionViewContentTypeImojis;
    [self.activityView startAnimating];
    [self.content removeAllObjects];
    [self reloadData];
    
    self.categoryShowCallback(searchTerm);
    
    [self.session searchImojisWithTerm:searchTerm
                                offset:offset
                       numberOfResults:@(ImojiCollectionViewNumberOfItemsToLoad)
             resultSetResponseCallback:^(NSNumber *resultCount, NSError *error) {
                 [self.activityView stopAnimating];
                 
                 if (!error) {
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
                     
                     self.setProgressCallback((self.contentOffset.x + self.frame.size.width)/self.collectionViewLayout.collectionViewContentSize.width);
                 }
             }
                 imojiResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
                     if (!error) {
                         NSUInteger offsetValue = 0;
                         if (offset) {
                             offsetValue = offset.unsignedIntegerValue - 1;
                         }
                         
                         self.content[offsetValue + index] = imoji;
                         
                         [self reloadItemsAtIndexPaths:@[
                                                         [NSIndexPath indexPathForItem:offsetValue + index inSection:0]
                                                         ]];
                         
                         // append the loading indicator to the content to fetch the next set of results
                         if (index + 1 == ImojiCollectionViewNumberOfItemsToLoad) {
                             //[self.content addObject:self.loadingIndicatorObject];
                             
                             [self reloadData];
                         }
                     }
                 }];
}

- (void) saveToRecents:(IMImojiObject *) imojiObject {
    int arrayCapacity = 20;
    NSUserDefaults *shared = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.imoji.keyboard"];
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
    NSLog(@"%@",arrayOfRecents);
    [shared setObject:arrayOfRecents forKey:@"recentImojis"];
    [shared synchronize];
}

- (void) saveToFavorites:(IMImojiObject *) imojiObject {
    int arrayCapacity = 20;
    NSUserDefaults *shared = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.imoji.keyboard"];
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

- (void) processCellAnimations:(NSIndexPath *)currentIndexPath {

    for(UICollectionView *cell in self.visibleCells){
        NSIndexPath *indexPath = [self indexPathForCell:(UICollectionViewCell*)cell];

        if (currentIndexPath.row == indexPath.row) {
            [(IMKeyboardCollectionViewCell*)cell performGrowAnimation];
        } else {
            [(IMKeyboardCollectionViewCell*)cell performTranslucentAnimation];
        }
        
    }
}

- (void) processDoubleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint point = [sender locationInView:self];
        NSIndexPath *indexPath = [self indexPathForItemAtPoint:point];
        if (indexPath)
        {
            id cellContent = self.content[(NSUInteger) indexPath.row];
            if (self.contentType == ImojiCollectionViewContentTypeImojis) {
                IMImojiObject *imojiObject = cellContent;
                // save to favorites
                [self saveToFavorites:imojiObject];
                
                self.showFavoritedCallback();
                [self processCellAnimations:indexPath];
            }
        }
        else
        {
           NSLog(@"Nothing double tapped");
        }
    }
}

- (IMImojiObjectRenderingOptions *)renderingOptions {
    return [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail];
}

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session {
    return [[ImojiCollectionView alloc] initWithSession:session];
}

@end