//
// Created by Nima on 7/20/15.
// Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const IMCollectionViewCellReuseId;

@interface IMCollectionViewCell : UICollectionViewCell

- (void)loadImojiImage:(UIImage *)imojiImage;

- (void)loadImojiImage:(UIImage *)imojiImage animated:(BOOL)animated;

- (void)performGrowAnimation;

- (void)performTranslucentAnimation;

@property(nonatomic, strong) UIImageView *imojiView;
@property(nonatomic, readonly) BOOL hasImojiImage;

@end
