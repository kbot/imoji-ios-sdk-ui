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

#import "IMSuggestionSplashViewCell.h"
#import "View+MASAdditions.h"
#import "IMSuggestionView.h"
#import "IMAttributeStringUtil.h"
#import "IMResourceBundleUtil.h"

@implementation IMSuggestionSplashViewCell {

}

- (void)layoutSubviews {
    [super layoutSubviews];

    if(self.splashType == IMCollectionViewSplashCellNoResults) {
        [self setupSplashCellWithText:[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashNoResults"]];
    } else if(self.splashType == IMCollectionViewSplashCellRecents) {
        [self setupSplashCellWithText:[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashRecents"]];
    }
}

- (void)setupSplashCellWithText:(NSString *)text {
    self.splashGraphic.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_noresults_graphic_small.png", [IMResourceBundleUtil assetsBundle].bundlePath]];
    self.splashText.attributedText = [IMAttributeStringUtil attributedString:text
                                                                    withFont:[IMAttributeStringUtil montserratLightFontWithSize:16.0f]
                                                                       color:[UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.24f]
                                                                andAlignment:NSTextAlignmentCenter];

    if (self.frame.size.height > IMSuggestionViewDefaultHeight) {
        self.splashGraphic.hidden = NO;

        [self.splashContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.equalTo(@119.0f);
            make.center.equalTo(self);
        }];

        [self.splashGraphic mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.centerX.equalTo(self.splashContainer);
        }];

        [self.splashText mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.splashGraphic.mas_bottom).offset(12.0f);
            make.width.and.centerX.equalTo(self.splashContainer);
        }];
    } else {
        self.splashGraphic.hidden = YES;

        [self.splashContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [self.splashText mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.splashContainer).offset(-10.f);
            make.centerY.equalTo(self.splashContainer);
        }];
    }
}

@end
