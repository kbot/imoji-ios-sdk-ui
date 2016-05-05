//
//  ImojiSDKUI
//
//  Created by Alex Hoang
//  Copyright (C) 2016 Imoji
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

#import "SampleAppCollectionTableViewCell.h"
#import "View+MASAdditions.h"
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>

NSString *const SampleAppCollectionTableViewCellReuseId = @"SampleAppCollectionTableViewCellReuseId";

@interface SampleAppCollectionTableViewCell ()
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *iconImageView;
@end

@implementation SampleAppCollectionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [IMAttributeStringUtil montserratLightFontWithSize:18.0f];
        self.titleLabel.textColor = [UIColor colorWithRed:57.0f / 255.0f green:61.0f / 255.0f blue:73.0f / 255.0f alpha:1.0f];

        self.iconImageView = [[UIImageView alloc] init];

        [self addSubview:self.titleLabel];
        [self addSubview:self.iconImageView];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(60.0f);
            make.centerY.equalTo(self);
        }];

        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-60.0f);
            make.centerY.equalTo(self);
        }];
    }

    return self;
}

- (void)setupWithTitle:(NSString *)title iconImage:(SampleAppCollectionIconType)iconType {
    self.titleLabel.text = title;

    switch(iconType) {
        case SampleAppCollectionIconTypeForward:
            self.iconImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_menu_forward.png", [IMResourceBundleUtil assetsBundle].bundlePath]];
            break;
        case SampleAppCollectionIconTypeSettings:
            self.iconImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_menu_settings.png", [IMResourceBundleUtil assetsBundle].bundlePath]];
            break;
        default:
            break;
    }
}


//- (void)awakeFromNib {
//    [super awakeFromNib];
//    // Initialization code
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
