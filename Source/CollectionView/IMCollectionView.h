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

typedef NS_ENUM(NSUInteger, ImojiCollectionViewContentType) {
    ImojiCollectionViewContentTypeImojis,
    ImojiCollectionViewContentTypeImojiCategories,
    ImojiCollectionViewContentTypeRecentsSplash,
    ImojiCollectionViewContentTypeCollectionSplash,
    ImojiCollectionViewContentTypeNoConnectionSplash,
    ImojiCollectionViewContentTypeEnableFullAccessSplash,
    ImojiCollectionViewContentTypeNoResultsSplash
};

@class IMImojiSession, IMImojiCategoryObject, IMImojiObject;

@protocol IMCollectionViewDelegate;

@interface IMCollectionView : UICollectionView <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property(nonatomic, strong, readonly) IMImojiSession *session;
@property(nonatomic, strong, readonly) NSObject *loadingIndicatorObject;

@property(nonatomic) ImojiCollectionViewContentType contentType;
@property(nonatomic, strong) NSBundle *imagesBundle;
@property(nonatomic) NSUInteger numberOfImojisToLoad;
@property(nonatomic) CGFloat sideInsets;

@property(nonatomic, weak) id <IMCollectionViewDelegate> collectionViewDelegate;

- (instancetype)initWithSession:(IMImojiSession *)session;

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session;

+ (UIImage *)placeholderImageWithRadius:(CGFloat)radius;

- (void)loadFeaturedImojis;

- (void)loadImojiCategories:(IMImojiSessionCategoryClassification)classification;

- (void)loadImojisFromSearch:(NSString *)searchTerm;

- (void)loadImojisFromIdentifiers:(NSArray *)imojiIdentifiers;

- (void)loadUserCollectionImojis;

- (void)processCellAnimations:(NSIndexPath *)currentIndexPath;

- (id)contentForIndexPath:(NSIndexPath *)path;

@end

@protocol IMCollectionViewDelegate <NSObject>

@optional

- (void)imojiCollectionViewDidFinishSearching:(IMCollectionView *)collectionView;

- (void)imojiCollectionView:(IMCollectionView *)collectionView userDidScroll:(UIScrollView *)scrollView;

- (void)userDidSelectImoji:(IMImojiObject *)imoji fromCollectionView:(IMCollectionView *)collectionView;

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category fromCollectionView:(IMCollectionView *)collectionView;

@end
