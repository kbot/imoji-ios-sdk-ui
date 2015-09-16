//
// Created by Nima on 7/20/15.
// Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const IMCategoryCollectionViewCellReuseId;

@interface IMCategoryCollectionViewCell : UICollectionViewCell

- (void)loadImojiCategory:(NSString *)categoryTitle imojiImojiImage:(UIImage *)imojiImage;

- (void)loadImojiCategory:(NSString *)categoryTitle imojiImojiImage:(UIImage *)imojiImage animated:(BOOL)animated;

@property(nonatomic, strong) UIImageView *imojiView;
@property(nonatomic, strong) UILabel *titleView;

@end
