//
//  ImojiCollectionView.h
//  imoji-keyboard
//
//  Created by Jeff on 6/7/15.
//  Copyright (c) 2015 Jeff. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <ImojiSDK/ImojiSDK.h>

@class IMImojiSession;

@interface ImojiCollectionView : UICollectionView

@property(nonatomic, strong) void(^categoryShowCallback) (NSString *title);
@property(nonatomic, strong) void(^setProgressCallback) (float progress);
@property(nonatomic, strong) void(^showDownloadingCallback) ();
@property(nonatomic, strong) void(^showCopiedCallback) (NSString *message);
@property(nonatomic, strong) void(^showFavoritedCallback) ();
@property(nonatomic) IMImojiSessionCategoryClassification currentCategoryClassification;
@property(nonatomic) UITapGestureRecognizer *doubleTapFolderGesture;


+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session;

- (void)loadImojiCategories:(IMImojiSessionCategoryClassification)classification;

- (void)loadRecentImojis;

- (void)loadFavoriteImojis;

- (void)loadImojisFromSearch:(NSString *)searchTerm offset:(NSNumber *)offset;

@end
