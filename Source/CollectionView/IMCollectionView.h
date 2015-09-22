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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ImojiSDK/IMImojiSession.h>
#import "IMCollectionViewSplashCell.h"

typedef NS_ENUM(NSUInteger, IMCollectionViewContentType) {
    IMCollectionViewContentTypeImojis,
    IMCollectionViewContentTypeImojiCategories,
    IMCollectionViewContentTypeRecentsSplash,
    IMCollectionViewContentTypeCollectionSplash,
    IMCollectionViewContentTypeNoConnectionSplash,
    IMCollectionViewContentTypeEnableFullAccessSplash,
    IMCollectionViewContentTypeNoResultsSplash
};

extern NSUInteger const IMCollectionViewNumberOfItemsToLoad;

@class IMImojiSession, IMImojiCategoryObject, IMImojiObject;

@protocol IMCollectionViewDelegate;

/**
 * A resuable collection view for displaying stickers backed by the ImojiSDK.
 */
@interface IMCollectionView : UICollectionView <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

/**
* @abstract The current imoji session
*/
@property(nonatomic, strong, readonly) IMImojiSession *_Nonnull session;

/**
* @abstract The type of content currently displayed in collection view
*/
@property(nonatomic, readonly) IMCollectionViewContentType contentType;

/**
 * @abstract The number of Imoji stickers to load. Defaults to IMCollectionViewNumberOfItemsToLoad.
 */
@property(nonatomic) NSUInteger numberOfImojisToLoad;

@property(nonatomic) CGFloat sideInsets;

/**
 * @abstract The image bundle to use for displaying shared assets such as splash screen images. Defaults to
 * [IMResourceBundleUtil assetsBundle]
*/
@property(nonatomic, strong) NSBundle *_Nonnull imagesBundle;

/**
 * @abstract The default rendering options to use for displaying the stickers. Defaults to
 * [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail]
*/
@property(nonatomic, strong) IMImojiObjectRenderingOptions *_Nonnull renderingOptions;

@property(nonatomic, weak) id <IMCollectionViewDelegate> _Nullable collectionViewDelegate;

/**
 * @abstract Creates a collection view with the specified Imoji session
 */
- (instancetype _Nonnull)initWithSession:(IMImojiSession *_Nonnull)session;

/**
 * @abstract Creates a collection view with the specified Imoji session
 */
+ (instancetype _Nonnull)imojiCollectionViewWithSession:(IMImojiSession *_Nonnull)session;

@end

@interface IMCollectionView (ImojiLoading)

/**
 * @abstract Loads Imoji stickers into the collection view using getFeaturedImojisWithNumberOfResults from IMImojiSession
 */
- (void)loadFeaturedImojis;

/**
 * @abstract Loads Imoji categories into the collection view using getImojiCategoriesWithClassification from IMImojiSession
 */
- (void)loadImojiCategories:(IMImojiSessionCategoryClassification)classification;

/**
 * @abstract Loads Imoji from a given search term into the collection view using searchImojisWithTerm from IMImojiSession
 * The collection view will automatically scroll through multiple pages of stickers if they exist
 */
- (void)loadImojisFromSearch:(NSString *_Nullable)searchTerm;

/**
 * @abstract Parses a given sentence for popular Imoji stickers
 */
- (void)loadImojisFromSentence:(NSString *_Nonnull)sentence;

/**
 * @abstract Loads Imoji stickers into the collection view using fetchImojisByIdentifiers from IMImojiSession
 */
- (void)loadImojisFromIdentifiers:(NSArray *_Nonnull)imojiIdentifiers;

/**
 * @abstract Loads Imoji stickers for an authenticated user into the collection view using
 * getImojisForAuthenticatedUserWithResultSetResponseCallback from IMImojiSession
 */
- (void)loadUserCollectionImojis;

/**
 * @abstract Shows specified splash content in the collection view
 */
- (void)displaySplashOfType:(IMCollectionViewSplashCellType)splashType;

@end

@interface IMCollectionView (Override)

- (void)processCellAnimations:(NSIndexPath *_Nonnull)currentIndexPath;

- (id _Nullable)contentForIndexPath:(NSIndexPath *_Nonnull)path;

- (BOOL)isPathShowingLoadingIndicator:(NSIndexPath *_Nonnull)indexPath;

@end

@protocol IMCollectionViewDelegate <NSObject>

@optional

/**
 * @abstract Notified when the specified content has completed loading
 */
- (void)imojiCollectionView:(IMCollectionView *_Nonnull)collectionView didFinishLoadingContentType:(IMCollectionViewContentType)contentType;

/**
 * @abstract Notified when the user has tapped on the a given splash cell
 */
- (void)userDidSelectSplash:(IMCollectionViewSplashCellType)splashType fromCollectionView:(IMCollectionView *_Nonnull)collectionView;

/**
 * @abstract Notified when a user selected an imoji
 */
- (void)userDidSelectImoji:(IMImojiObject *_Nonnull)imoji fromCollectionView:(IMCollectionView *_Nonnull)collectionView;

/**
 * @abstract Notified when a user selected a category
 */
- (void)userDidSelectCategory:(IMImojiCategoryObject *_Nonnull)category fromCollectionView:(IMCollectionView *_Nonnull)collectionView;

- (void)imojiCollectionViewDidScroll:(IMCollectionView *_Nonnull)collectionView;

@end
