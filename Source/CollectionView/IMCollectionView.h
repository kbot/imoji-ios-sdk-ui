//
// Created by Nima on 4/7/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ImojiSDK/IMImojiSession.h>

typedef NS_ENUM(NSUInteger, ImojiCollectionViewContentType) {
    ImojiCollectionViewContentTypeImojis,
    ImojiCollectionViewContentTypeImojiCategories
};

@class IMImojiSession, IMImojiCategoryObject, IMImojiObject;

@interface IMCollectionView : UICollectionView

@property(nonatomic, strong) void(^categorySelectedCallback)(IMImojiCategoryObject * category);
@property(nonatomic, strong) void(^imojiSelectedCallback)(IMImojiObject * imoji);
@property(nonatomic, strong, readonly) IMImojiSession *session;
@property(nonatomic, strong) NSMutableArray *content;
@property(nonatomic) ImojiCollectionViewContentType contentType;

@property(nonatomic) NSUInteger numberOfImojisToLoad;
@property(nonatomic) CGFloat sideInsets;

- (instancetype)initWithSession:(IMImojiSession *)session;

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session;

+ (UIImage *)placeholderImageWithRadius:(CGFloat)radius;

- (void)loadFeaturedImojis;

- (void)loadImojiCategories:(IMImojiSessionCategoryClassification)classification;

- (void)loadImojisFromSearch:(NSString *)searchTerm;

- (void)loadUserCollectionImojis;

- (void)loadNextPageOfImojisFromSearch;

- (IMImojiObjectRenderingOptions *)renderingOptions;

- (NSObject *)getNoResultsIndicatorObject;

- (NSObject *)getLoadingIndicatorObject;

@end
