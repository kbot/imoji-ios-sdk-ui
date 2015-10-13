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

#import "IMCollectionViewSplashCell.h"
#import "IMAttributeStringUtil.h"
#import "IMResourceBundleUtil.h"
#import <Masonry/Masonry.h>

NSString *const IMCollectionViewSplashCellReuseId = @"IMCollectionViewSplashCellReuseId";

@implementation IMCollectionViewSplashCell {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.splashGraphic = [UIImageView new];
        self.splashText = [UILabel new];

        self.splashText.lineBreakMode = NSLineBreakByWordWrapping;
        self.splashText.numberOfLines = 2;

        [self addSubview:self.splashGraphic];
        [self addSubview:self.splashText];
    }

    return self;
}

- (void)showSplashCellType:(IMCollectionViewSplashCellType)splashCellType withImageBundle:(NSBundle *)imageBundle {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    switch (splashCellType) {
        case IMCollectionViewSplashCellNoConnection:
            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashNoConnection"]
                                                                                    withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:14.0f]
                                                                                       color:[UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1]
                                                                                andAlignment:NSTextAlignmentCenter]];

            [self loadSplashCellWithText:attributedString imageName:@"collection_view_splash_noconnection" andImageBundle:imageBundle];
            break;
        case IMCollectionViewSplashCellEnableFullAccess:
            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashEnableFullAccess"]
                                                                                    withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:14.0f]
                                                                                       color:[UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1]
                                                                                andAlignment:NSTextAlignmentCenter]];

            [self loadSplashCellWithText:attributedString imageName:@"collection_view_splash_enableaccess" andImageBundle:imageBundle];
            break;
        case IMCollectionViewSplashCellNoResults: {
            NSArray *textArray = [[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashNoResults"] componentsSeparatedByString:@"|"];
            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:textArray[0]
                                                                                    withFont:[IMAttributeStringUtil sfUIDisplayLightFontWithSize:19.0f]
                                                                                       color:[UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1]
                                                                                andAlignment:NSTextAlignmentCenter]];
            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:textArray[1]
                                                                                    withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:16.0f]
                                                                                       color:[UIColor colorWithRed:56.0f / 255.0f green:124.0f / 255.0f blue:169.0f / 255.0f alpha:1]
                                                                                andAlignment:NSTextAlignmentCenter]];

            [self loadSplashCellWithText:attributedString imageName:@"collection_view_splash_noresults" andImageBundle:imageBundle];
            break;
        }
        case IMCollectionViewSplashCellCollection:{
            NSArray *textArray = [[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashCollection"] componentsSeparatedByString:@"|"];
            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:textArray[0]
                                                                                    withFont:[IMAttributeStringUtil sfUIDisplayMediumFontWithSize:15.0f]
                                                                                       color:[UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1]
                                                                                andAlignment:NSTextAlignmentCenter]];
            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:textArray[1]
                                                                                    withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:15.0f]
                                                                                       color:[UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1]
                                                                                andAlignment:NSTextAlignmentCenter]];

            [self loadSplashCellWithText:attributedString imageName:@"collection_view_splash_collection" andImageBundle:imageBundle];
            break;
        }
        case IMCollectionViewSplashCellRecents:
            [attributedString appendAttributedString:[IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionViewSplashRecents"]
                                                                                    withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:15.0f]
                                                                                       color:[UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1]
                                                                                andAlignment:NSTextAlignmentCenter]];

            [self loadSplashCellWithText:attributedString imageName:@"collection_view_splash_recents" andImageBundle:imageBundle];
            break;
        default:
            break;
    }
}

- (void)loadSplashCellWithText:(NSAttributedString *)text
                     imageName:(NSString *)imageName
                andImageBundle:(NSBundle *)imageBundle {
    self.splashGraphic.image = [UIImage imageNamed:imageName inBundle:imageBundle compatibleWithTraitCollection:nil];
    self.splashText.attributedText = text;

    [self.splashGraphic mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-(self.splashGraphic.image.size.height / 2.0f));
    }];

    [self.splashText mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splashGraphic.mas_bottom).offset(13.0f);
        make.width.and.centerX.equalTo(self);
    }];
}

@end
