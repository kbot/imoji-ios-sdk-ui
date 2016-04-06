//
//  ImojiSDKUI
//
//  Created by Nima Khoshini
//  Copyright (C) 2015 Imoji
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "IMSuggestionCategoryViewCell.h"
#import <Masonry/Masonry.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>

@implementation IMSuggestionCategoryViewCell {

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
            make.right.equalTo(titleContainer).offset(-10.f);
            make.top.height.equalTo(titleContainer);
            make.left.equalTo(titleContainer).offset(trendingImage.image.size.width);
        }];
    }

    return self;
}

@end
