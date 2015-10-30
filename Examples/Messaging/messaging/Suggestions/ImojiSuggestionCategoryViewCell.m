//
// Created by Nima on 10/29/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "ImojiSuggestionCategoryViewCell.h"
#import <Masonry/Masonry.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>

@implementation ImojiSuggestionCategoryViewCell {

}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.imojiView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.height.width.equalTo(self);
        }];

        self.titleView.adjustsFontSizeToFitWidth = YES;
        self.titleView.font = [IMAttributeStringUtil defaultFontWithSize:12.0f];
        self.titleView.textColor = [UIColor colorWithRed:22.0f / 255.0f green:137.0f / 255.0f blue:251.0f / 255.0f alpha:1.0f];

        UIImageView *trendingImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchTrending"]];
        UIView *titleContainer = [UIView new];
        titleContainer.layer.borderColor = [UIColor colorWithWhite:207.f / 255.f alpha:1.f].CGColor;
        titleContainer.layer.borderWidth = 1.f;
        titleContainer.layer.cornerRadius = 4.f;
        titleContainer.backgroundColor = [UIColor colorWithWhite:1.f alpha:.8f];

        [self insertSubview:titleContainer belowSubview:self.titleView];
        [titleContainer addSubview:trendingImage];

        [titleContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.centerX.equalTo(self);
            make.bottom.equalTo(self.imojiView);
            make.height.equalTo(@(self.titleView.font.lineHeight * 2.f + 1.0f));
        }];
        [trendingImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(titleContainer);
            make.left.equalTo(titleContainer).offset(2.f);
        }];

        [self.titleView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.height.right.equalTo(titleContainer);
            make.left.equalTo(titleContainer).offset(trendingImage.image.size.width);
        }];
    }

    return self;
}

@end
