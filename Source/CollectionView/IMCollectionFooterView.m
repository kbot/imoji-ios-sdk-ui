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

#import "IMCollectionFooterView.h"
#import "IMResourceBundleUtil.h"
#import "IMAttributeStringUtil.h"
#import "View+MASAdditions.h"
#import "IMArtistObject.h"

NSString *const IMCollectionFooterViewReuseId = @"IMCollectionFooterViewReuseId";

@implementation IMCollectionFooterView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];

    if (self) {
        self.imageBundle = [IMResourceBundleUtil assetsBundle];
    }

    return self;
}

- (void)setup {
    if(!self.container) {
        self.container = [[UIView alloc] init];

        self.artistPicture = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_reactions.png", self.imageBundle.bundlePath]]];

        self.artistHeader = [[UILabel alloc] init];
        self.artistHeader.attributedText = [IMAttributeStringUtil attributedString:@"About the Artist"
                                                                          withFont:[IMAttributeStringUtil defaultFontWithSize:14.0f]
                                                                             color:[UIColor grayColor]
                                                                      andAlignment:NSTextAlignmentLeft];

        self.artistName = [[UILabel alloc] init];
        self.artistName.attributedText = [IMAttributeStringUtil attributedString:@"MY GOODIES OHHH"
                                                                        withFont:[IMAttributeStringUtil defaultFontWithSize:18.0f]
                                                                           color:[UIColor blackColor]
                                                                    andAlignment:NSTextAlignmentLeft];

        self.artistDescription = [[UILabel alloc] init];
        self.artistDescription.attributedText = [IMAttributeStringUtil attributedString:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec aliquam dignissim magna, quis faucibus eros porta in."
                                                                               withFont:[IMAttributeStringUtil defaultFontWithSize:13.0f]
                                                                                  color:[UIColor lightGrayColor]
                                                                           andAlignment:NSTextAlignmentLeft];
        self.artistDescription.lineBreakMode = NSLineBreakByWordWrapping;
        self.artistDescription.numberOfLines = 2;

        [self addSubview:self.container];

        [self.container addSubview:self.artistPicture];
        [self.container addSubview:self.artistHeader];
        [self.container addSubview:self.artistName];
        [self.container addSubview:self.artistDescription];

        [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self);
            make.left.equalTo(self).offset(20.0f);
            make.right.equalTo(self).offset(-20.0f);
        }];

        [self.artistPicture mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.equalTo(self.container);
            make.width.and.height.equalTo(@65.0f);
        }];

        [self.artistHeader mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).offset(10.0f);
            make.left.equalTo(self.artistPicture.mas_right).offset(7.5f);
        }];

        [self.artistName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistHeader.mas_bottom);
            make.left.equalTo(self.artistPicture.mas_right).offset(7.5f);
        }];

        [self.artistDescription mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistPicture.mas_bottom);
            make.height.equalTo(@(self.frame.size.height - 65.0f));
            make.left.and.right.equalTo(self.container);
        }];
    } else {
        self.container = self.subviews.firstObject;
    }
}

- (void)setupWithArtist:(IMArtistObject *)artist {
    if(!self.container) {
        self.container = [[UIView alloc] init];

        self.artistPicture = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_reactions.png", self.imageBundle.bundlePath]]];

        self.artistHeader = [[UILabel alloc] init];
        self.artistHeader.attributedText = [IMAttributeStringUtil attributedString:@"About the Artist"
                                                                          withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:14.0f]
                                                                             color:[UIColor colorWithRed:35.0f / 255.0f green:31.0f / 255.0f blue:32.0f / 255.0f alpha:0.6f]
                                                                      andAlignment:NSTextAlignmentLeft];

        self.artistName = [[UILabel alloc] init];
        self.artistName.attributedText = [IMAttributeStringUtil attributedString:artist.name
                                                                        withFont:[IMAttributeStringUtil imojiRegularFontWithSize:19.0f]
                                                                           color:[UIColor colorWithRed:35.0f / 255.0f green:31.0f / 255.0f blue:32.0f / 255.0f alpha:0.8f]
                                                                    andAlignment:NSTextAlignmentLeft];

        self.artistDescription = [[UILabel alloc] init];
        self.artistDescription.attributedText = [IMAttributeStringUtil attributedString:artist.description
                                                                               withFont:[IMAttributeStringUtil sfUIDisplayLightFontWithSize:12.0f]
                                                                                  color:[UIColor colorWithRed:35.0f / 255.0f green:31.0f / 255.0f blue:32.0f / 255.0f alpha:0.5f]
                                                                           andAlignment:NSTextAlignmentNatural];
        self.artistDescription.lineBreakMode = NSLineBreakByWordWrapping;
        self.artistDescription.numberOfLines = 2;

        [self addSubview:self.container];

        [self.container addSubview:self.artistPicture];
        [self.container addSubview:self.artistHeader];
        [self.container addSubview:self.artistName];
        [self.container addSubview:self.artistDescription];

        [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self);
            make.left.equalTo(self).offset(20.0f);
            make.right.equalTo(self).offset(-20.0f);
        }];

        [self.artistPicture mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.equalTo(self.container);
            make.width.and.height.equalTo(@65.0f);
        }];

        [self.artistHeader mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.container).offset(10.0f);
            make.left.equalTo(self.artistPicture.mas_right).offset(20.0f);
        }];

        [self.artistName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistHeader.mas_bottom);
            make.left.equalTo(self.artistPicture.mas_right).offset(20.0f);
        }];

        [self.artistDescription mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistPicture.mas_bottom);
            make.height.equalTo(@(self.frame.size.height - 65.0f));
            make.left.and.right.equalTo(self.container);
        }];
    } else {
        self.container = self.subviews.firstObject;
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:242.0f / 255.0f green:242.0f / 255.0f blue:242.0f / 255.0f alpha:1.0f].CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 0);
    CGContextFillRect(context, self.bounds);

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:0.08f].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, 2.0f));

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(0, self.frame.size.height - 2.0f, self.frame.size.width, 2.0f));
}

@end
