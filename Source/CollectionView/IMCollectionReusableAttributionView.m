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

#import "IMCollectionReusableAttributionView.h"
#import "IMResourceBundleUtil.h"
#import "IMAttributeStringUtil.h"
#import "View+MASAdditions.h"
#import "IMArtistObject.h"

NSString *const IMCollectionReusableAttributionViewReuseId = @"IMCollectionReusableAttributionViewReuseId";
CGFloat const IMCollectionReusableAttributionViewArtistContainerOffset = 30.0f;
CGFloat const IMCollectionReusableAttributionViewSeparatorHeight = 2.0f;
CGFloat const IMCollectionReusableAttributionViewArtistPictureWidthHeight = 60.0f;
CGFloat const IMCollectionReusableAttributionViewURLContainerHeight = 55.0f;

@interface IMCollectionReusableAttributionView ()

@property(nonatomic, strong) UIView *footerView;
@property(nonatomic, strong) UIView *urlContainer;
@property(nonatomic, strong) UIView *artistContainer;

@end

@implementation IMCollectionReusableAttributionView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];

    if (self) {
        self.opaque = NO;
        self.imageBundle = [IMResourceBundleUtil assetsBundle];
    }

    return self;
}

- (void)setupWithArtist:(IMArtistObject *)artist {
    if(!self.footerView) {
        // Setup views
        self.footerView = [[UIView alloc] init];

        self.urlContainer = [[UIView alloc] init];
        self.urlContainer.backgroundColor = [UIColor clearColor];
        [self.urlContainer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(urlContainerTapped)]];

        self.artistContainer = [[UIView alloc] init];

        // URL Container view
        self.artistLink = [[UILabel alloc] init];
        self.artistLink.attributedText = [IMAttributeStringUtil attributedString:artist.packURL
                                                                        withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:14.0f]
                                                                           color:[UIColor colorWithRed:10.0f / 255.0f green:149.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]
                                                                    andAlignment:NSTextAlignmentLeft];

        self.artistLinkImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/attribution_link_website.png", self.imageBundle.bundlePath]]];

        // Artist Container View
        self.artistPicture = [[UIImageView alloc] init];

        self.artistHeader = [[UILabel alloc] init];
        self.artistHeader.attributedText = [IMAttributeStringUtil attributedString:@"About the Artist"
                                                                          withFont:[IMAttributeStringUtil sfUIDisplayRegularFontWithSize:14.0f]
                                                                             color:[UIColor colorWithRed:35.0f / 255.0f green:31.0f / 255.0f blue:32.0f / 255.0f alpha:0.6f]
                                                                      andAlignment:NSTextAlignmentLeft];

        self.artistName = [[UILabel alloc] init];
        self.artistName.attributedText = [IMAttributeStringUtil attributedString:[artist.name uppercaseString]
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

        // Add subviews
        [self addSubview:self.footerView];

        [self.footerView addSubview:self.urlContainer];
        [self.footerView addSubview:self.artistContainer];

        [self.urlContainer addSubview:self.artistLink];
        [self.urlContainer addSubview:self.artistLinkImage];

        [self.artistContainer addSubview:self.artistPicture];
        [self.artistContainer addSubview:self.artistHeader];
        [self.artistContainer addSubview:self.artistName];
        [self.artistContainer addSubview:self.artistDescription];

        // View Constraints
        [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.equalTo(self);
        }];

        [self.urlContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(self.footerView);
            make.height.equalTo(@(IMCollectionReusableAttributionViewURLContainerHeight));
        }];

        [self.artistContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.urlContainer.mas_bottom).offset(IMCollectionReusableAttributionViewSeparatorHeight);
            make.left.equalTo(self.footerView).offset(IMCollectionReusableAttributionViewArtistContainerOffset);
            make.right.equalTo(self.footerView).offset(-IMCollectionReusableAttributionViewArtistContainerOffset);
            make.bottom.equalTo(self.footerView).offset(-IMCollectionReusableAttributionViewSeparatorHeight);
        }];

        // URL container subview constraints
        [self.artistLink mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.urlContainer).offset(18.0f);
            make.centerY.equalTo(self.urlContainer);
        }];

        [self.artistLinkImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.urlContainer);
            make.right.equalTo(self.artistLink.mas_left).offset(-9.0f);
        }];

        // Artist container subview constraints
        [self.artistPicture mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistContainer).offset(11.0f);
            make.left.equalTo(self.artistContainer);
            make.width.and.height.equalTo(@(IMCollectionReusableAttributionViewArtistPictureWidthHeight));
        }];

        [self.artistHeader mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistContainer).offset(20.0f);
            make.left.equalTo(self.artistPicture.mas_right).offset(11.0f);
        }];

        [self.artistName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistHeader.mas_bottom).offset(2.0f);
            make.left.equalTo(self.artistPicture.mas_right).offset(11.0f);
        }];

        [self.artistDescription mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.artistPicture.mas_bottom).offset(12.0f);
            make.bottom.equalTo(self.artistContainer).offset(-15.0f);
            make.left.and.right.equalTo(self.artistContainer);
        }];
    } else {
        self.footerView = self.subviews.firstObject;
    }
}

- (void)urlContainerTapped {
    if(self.attributionViewDelegate && [self.attributionViewDelegate respondsToSelector:@selector(userDidSelectArtistLink:fromCollectionReusableView:)]) {
        [self.attributionViewDelegate userDidSelectArtistLink:self.artistLink.attributedText.string fromCollectionReusableView:self];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:242.0f / 255.0f green:242.0f / 255.0f blue:242.0f / 255.0f alpha:1.0f].CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetLineWidth(context, 0);
    CGContextFillRect(context, CGRectMake(0, IMCollectionReusableAttributionViewURLContainerHeight, self.frame.size.width, self.frame.size.height - IMCollectionReusableAttributionViewURLContainerHeight));

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 / 255.0f green:0 / 255.0f blue:0 / 255.0f alpha:0.08f].CGColor);
    CGContextFillRect(context, CGRectMake(0, IMCollectionReusableAttributionViewURLContainerHeight, self.frame.size.width, IMCollectionReusableAttributionViewSeparatorHeight));

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:255.0f / 255.0f green:255.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(0, self.frame.size.height - 2.0f, self.frame.size.width, IMCollectionReusableAttributionViewSeparatorHeight));
}

@end
