//
// Created by Nima on 7/20/15.
// Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import "IMCategoryCollectionViewCell.h"
#import <Masonry/View+MASAdditions.h>
#import "ImojiTextUtil.h"
#import "IMCollectionView.h"

NSString *const IMCategoryCollectionViewCellReuseId = @"IMCategoryCollectionViewCellReuseId";

@implementation IMCategoryCollectionViewCell {

}


- (void)loadImojiCategory:(NSString *)categoryTitle imojiImojiImage:(UIImage *)imojiImage {
    if (!self.imojiView) {
        self.imojiView = [UIImageView new];

        [self addSubview:self.imojiView];
        [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.centerY.equalTo(self);
            make.height.width.equalTo(self.mas_height).multipliedBy(.75f);
        }];
    }

    if (!self.titleView) {
        self.titleView = [UILabel new];

        [self addSubview:self.titleView];

        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.centerY.equalTo(self);
            make.left.equalTo(self.imojiView.mas_right).offset(10);
        }];
    }

    if (imojiImage) {
        self.imojiView.image = imojiImage;
        self.imojiView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        self.imojiView.image = [IMCollectionView placeholderImageWithRadius:30];
        self.imojiView.contentMode = UIViewContentModeCenter;
    }

    self.titleView.attributedText = [ImojiTextUtil attributedString:categoryTitle
                                                       withFontSize:20.0f
                                                          textColor:[UIColor blackColor]];
}

@end
