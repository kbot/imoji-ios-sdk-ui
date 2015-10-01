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
#import "IMCreateImojiUITheme.h"

@interface IMTagCollectionViewCell ()

@end

@implementation IMTagCollectionViewCell

- (void)setTagContents:(NSString *)tagContents {
    _tagContents = tagContents;

    if (!self.textView) {
        _textView = [UILabel new];
        _removeButton = [UIButton new];

        [self.removeButton setImage:[IMCreateImojiUITheme instance].tagScreenRemoveTagIcon forState:UIControlStateNormal];

        [self addSubview:self.textView];
        [self addSubview:self.removeButton];

        [self.removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-[IMCreateImojiUITheme instance].tagScreenTagItemViewInsets.right);
            make.centerY.equalTo(self);
        }];

        [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset([IMCreateImojiUITheme instance].tagScreenTagItemViewInsets.left);
            make.centerY.equalTo(self);
            make.right.equalTo(self.removeButton.mas_left).offset(-[IMCreateImojiUITheme instance].tagScreenTagItemTextButtonSpacing);
        }];
    }

    self.textView.attributedText = [[NSAttributedString alloc] initWithString:tagContents
                                                                   attributes:@{NSFontAttributeName : [IMCreateImojiUITheme instance].tagScreenTagFont}];
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
    CGSize textSize = [tag sizeWithAttributes:@{NSFontAttributeName : [IMCreateImojiUITheme instance].tagScreenTagFont}];
    CGSize removeIconSize = [IMCreateImojiUITheme instance].tagScreenRemoveTagIcon.size;

    return CGSizeMake(
            MIN(textSize.width, size.width) + removeIconSize.width +
                    [IMCreateImojiUITheme instance].tagScreenTagItemViewInsets.left +
                    [IMCreateImojiUITheme instance].tagScreenTagItemViewInsets.right +
                    [IMCreateImojiUITheme instance].tagScreenTagItemTextButtonSpacing * 2.f,

            MIN(MAX(textSize.height, removeIconSize.height), size.height) +
                    [IMCreateImojiUITheme instance].tagScreenTagItemViewInsets.top +
                    [IMCreateImojiUITheme instance].tagScreenTagItemViewInsets.bottom
    );
}

@end
