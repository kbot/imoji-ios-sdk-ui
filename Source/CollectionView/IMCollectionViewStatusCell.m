//
// Created by Nima on 7/20/15.
// Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import "IMCollectionViewStatusCell.h"

NSString *const IMCollectionViewStatusCellReuseId = @"IMCategoryCollectionViewCellReuseId";

@implementation IMCollectionViewStatusCell {

}

- (void)showLoading {
    [self setupViews];
    [self.activityIndicatorView startAnimating];
//    self.title.attributedText = [ImojiTextUtil attributedString:@"Loading"
//                                                   withFontSize:20.0f
//                                                      textColor:[UIColor blackColor]];
    self.activityIndicatorView.hidden = NO;
}

- (void)showNoResults {
    [self setupViews];
//    self.title.attributedText = [ImojiTextUtil attributedString:@"No results found"
//                                                   withFontSize:20.0f
//                                                      textColor:[UIColor blackColor]];
    self.activityIndicatorView.hidden = YES;
}

- (void)setupViews {
    if (!self.title) {
        self.title = [UILabel new];
        [self addSubview:self.title];

        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-10.0f);
        }];
    }

    if (!self.activityIndicatorView) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        [self addSubview:self.activityIndicatorView];
        [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.title.mas_bottom).offset(10.0f);
        }];
    } else {
        [self.activityIndicatorView stopAnimating];
    }
}

@end
