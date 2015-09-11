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

#import <Masonry/Masonry.h>
#import "IMTagCollectionViewCell.h"
#import "IMTagCollectionView.h"

UIEdgeInsets const IMTagCollectionViewCellContentInsets = {7.5, 7.5, 7.5, 7.5};

@interface IMTagCollectionViewCell ()

@end

@implementation IMTagCollectionViewCell

- (void)setTagContents:(NSString *)tagContents {
    _tagContents = tagContents;

    if (!self.textView) {
        _textView = [UILabel new];
        _removeButton = [UIButton new];

        [self.removeButton setImage:[IMTagCollectionView removeIcon] forState:UIControlStateNormal];

        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:.15f];
        self.layer.borderWidth = 1.0f;
        self.layer.cornerRadius = 7.5f;
        self.layer.borderColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:.5f].CGColor;

        [self addSubview:self.textView];
        [self addSubview:self.removeButton];

        [self.removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-IMTagCollectionViewCellContentInsets.right);
            make.centerY.equalTo(self);
        }];

        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(IMTagCollectionViewCellContentInsets.left);
            make.centerY.equalTo(self);
            make.right.equalTo(self.removeButton.mas_left);
        }];
    }

    self.textView.attributedText = [[NSAttributedString alloc] initWithString:tagContents
                                                                   attributes:@{NSFontAttributeName : [IMTagCollectionView textFont]}];
}

+ (IMTagCollectionViewCell *)instance {
    static IMTagCollectionViewCell *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

+ (CGSize)sizeThatFitsTag:(NSString *)tag andSize:(CGSize)size {
    CGSize textSize = [tag sizeWithAttributes:@{NSFontAttributeName : [IMTagCollectionView textFont]}];
    CGSize removeIconSize = [IMTagCollectionView removeIcon].size;

    return CGSizeMake(
            MIN(textSize.width, size.width) + removeIconSize.width + IMTagCollectionViewCellContentInsets.left + IMTagCollectionViewCellContentInsets.right + 5,
            MIN(MAX(textSize.height, removeIconSize.height), size.height) + IMTagCollectionViewCellContentInsets.top + IMTagCollectionViewCellContentInsets.bottom
    );
}

@end
