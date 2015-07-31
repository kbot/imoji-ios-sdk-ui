//
// Created by Nima on 7/20/15.
// Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import "IMCollectionViewCell.h"
#import <Masonry/View+MASAdditions.h>
#import "IMCollectionView.h"

NSString *const IMCollectionViewCellReuseId = @"ImojiCollectionViewCellReuseId";

@implementation IMCollectionViewCell {

}

- (void)loadImojiImage:(UIImage *)imojiImage {
    if (!self.imojiView) {
        self.imojiView = [UIImageView new];

        [self addSubview:self.imojiView];
        [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.and.height.equalTo(self).multipliedBy(.8f);
        }];
    }

    if (imojiImage) {
        self.imojiView.image = imojiImage;
        self.imojiView.contentMode = UIViewContentModeScaleAspectFit;
        _hasImojiImage = YES;
    } else {
        self.imojiView.image = [IMCollectionView placeholderImageWithRadius:30];
        self.imojiView.contentMode = UIViewContentModeCenter;
        _hasImojiImage = NO;
    }
}


@end
