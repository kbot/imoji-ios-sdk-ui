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

#import "IMCollectionReusableHeaderView.h"
#import "IMAttributeStringUtil.h"
#import "View+MASAdditions.h"

NSString *const IMCollectionReusableHeaderViewReuseId = @"IMCollectionReusableHeaderViewReuseId";

@interface IMCollectionReusableHeaderView ()

@property(nonatomic, strong) UILabel *title;

@end

@implementation IMCollectionReusableHeaderView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];

    if (self) {
        self.title = self.subviews.firstObject;
    }

    return self;
}

- (void)setupWithText:(NSString *)header {
    if (!self.title) {
        self.title = [[UILabel alloc] init];

        [self addSubview:self.title];

        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.equalTo(self);
        }];
    }

    self.title.attributedText = [IMAttributeStringUtil attributedString:[header uppercaseString]
                                                               withFont:[IMAttributeStringUtil imojiRegularFontWithSize:22.0f]
                                                                  color:[UIColor colorWithRed:188.0f / 255.0f green:190.0f / 255.0f blue:192.0f / 255.0f alpha:1.0f]
                                                           andAlignment:NSTextAlignmentCenter];
}

@end