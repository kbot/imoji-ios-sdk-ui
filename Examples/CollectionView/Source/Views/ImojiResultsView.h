//
// Created by Nima on 4/8/15.
// Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMImojiSession;
@class IMCollectionView;
@class ImojiDetailsView;

@interface ImojiResultsView : UIView

@property(nonatomic, strong) void (^dismissedCallback)();
@property(nonatomic, strong) IMCollectionView *collectionView;

+ (instancetype)resultsViewWithSession:(IMImojiSession *)session;

@end
