//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMCollectionView;
@class IMImojiSession;


@interface IMSuggestionView : UIView

@property(nonatomic, strong, readonly) IMCollectionView *collectionView;

/**
 * @abstract Creates a collection view with the specified Imoji session
 */
+ (nonnull instancetype)imojiSuggestionViewWithSession:(nonnull IMImojiSession *)session;

@end
