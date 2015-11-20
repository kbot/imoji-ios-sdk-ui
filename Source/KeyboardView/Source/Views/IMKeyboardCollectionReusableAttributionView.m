//
//  ImojiSDKUI
//
//  Created by Alex Hoang
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

#import "IMKeyboardCollectionReusableAttributionView.h"
#import "View+MASAdditions.h"

CGFloat const IMKeyboardCollectionReusableAttributionViewOffsetFromHeader = 10.0f;

@implementation IMKeyboardCollectionReusableAttributionView

- (void)setupWithAttribution:(IMCategoryAttribution *)attribution {
    if(!self.footerView) {
        [super setupWithAttribution:attribution];

        [self.artistContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self).offset(IMCollectionReusableAttributionViewContainerOffset);
            make.right.equalTo(self).offset(-IMCollectionReusableAttributionViewContainerOffset);
            make.height.equalTo(@(self.frame.size.height - IMCollectionReusableAttributionViewURLContainerHeight));
        }];

        [self.urlContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistContainer.mas_bottom).offset(12.0f);
            make.left.equalTo(self).offset(IMCollectionReusableAttributionViewContainerOffset);
            make.right.equalTo(self).offset(-IMCollectionReusableAttributionViewContainerOffset);
            make.bottom.equalTo(self);
        }];

        [self.artistPicture mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistContainer).offset(IMKeyboardCollectionReusableAttributionViewOffsetFromHeader + 14.0f);
        }];

        [self.artistHeader mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistContainer).offset(IMKeyboardCollectionReusableAttributionViewOffsetFromHeader + 23.0f);
        }];

        [self.artistSummary mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.artistContainer);
        }];

        [self.attributionLinkImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.equalTo(self.urlContainer);
        }];

        [self.attributionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.attributionLinkImage.mas_right).offset(9.0f);
            make.centerY.equalTo(self.attributionLinkImage);
        }];
    }
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 0);

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:0.08f].CGColor);
    CGContextFillRect(context, CGRectMake(
            0,
            IMKeyboardCollectionReusableAttributionViewOffsetFromHeader,
            IMCollectionReusableAttributionViewSeparatorSize,
            self.frame.size.height - IMKeyboardCollectionReusableAttributionViewOffsetFromHeader)
    );

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(
            self.frame.size.width - IMCollectionReusableAttributionViewSeparatorSize,
            IMKeyboardCollectionReusableAttributionViewOffsetFromHeader,
            IMCollectionReusableAttributionViewSeparatorSize,
            self.frame.size.height - IMKeyboardCollectionReusableAttributionViewOffsetFromHeader)
    );
}

@end
