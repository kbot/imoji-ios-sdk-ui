//
// Created by Nima on 4/7/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
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
    ImojiCollectionViewContentTypeEnableFullAccessSplash
};

@class IMImojiSession, IMImojiCategoryObject, IMImojiObject;

@protocol IMCollectionViewDelegate;

@interface IMCollectionView : UICollectionView

@property(nonatomic, strong) void(^categorySelectedCallback)(IMImojiCategoryObject * category);
@property(nonatomic, strong) void(^imojiSelectedCallback)(IMImojiObject * imoji);
@property(nonatomic, strong, readonly) IMImojiSession *session;
@property(nonatomic, strong) NSMutableArray *content;
@property(nonatomic) ImojiCollectionViewContentType contentType;
@property(nonatomic, strong, readonly) NSObject *loadingIndicatorObject;
@property(nonatomic, strong, readonly) NSObject *noResultsIndicatorObject;

@property(nonatomic) NSUInteger numberOfImojisToLoad;
@property(nonatomic) CGFloat sideInsets;
@property(nonatomic, weak) id <IMCollectionViewDelegate> collectionViewDelegate;

- (instancetype)initWithSession:(IMImojiSession *)session;

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session;

+ (UIImage *)placeholderImageWithRadius:(CGFloat)radius;

- (void)loadFeaturedImojis;

- (void)loadImojiCategories:(IMImojiSessionCategoryClassification)classification;

- (void)loadImojisFromSearch:(NSString *)searchTerm;

- (void)loadUserCollectionImojis;

- (void)loadNextPageOfImojisFromSearch;

- (IMImojiObjectRenderingOptions *)renderingOptions;

@end

@protocol IMCollectionViewDelegate <NSObject>

@optional

- (void)imojiCollectionViewDidFinishSearching:(IMCollectionView *)collectionView;

- (void)imojiCollectionView:(IMCollectionView *)collectionView userDidScroll:(UIScrollView *)scrollView;

@end
