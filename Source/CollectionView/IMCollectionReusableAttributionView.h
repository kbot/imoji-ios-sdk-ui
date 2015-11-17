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

#import <UIKit/UIKit.h>
#import "IMCollectionView.h"

@class IMArtistObject;

@protocol IMCollectionReusableAttributionViewDelegate;

@interface IMCollectionReusableAttributionView : UICollectionReusableView

extern NSString *__nonnull const IMCollectionReusableAttributionViewReuseId;

@property(nonatomic, strong) UIImageView *artistPicture;
@property(nonatomic, strong) UIImageView *artistLinkImage;
@property(nonatomic, strong) UILabel *artistName;
@property(nonatomic, strong) UILabel *artistDescription;
@property(nonatomic, strong) UILabel *artistHeader;
@property(nonatomic, strong) UILabel *artistLink;

@property(nonatomic, strong) NSBundle *imageBundle;

@property(nonatomic, weak, nullable) id <IMCollectionReusableAttributionViewDelegate> attributionViewDelegate;

- (void)setupWithArtist:(IMArtistObject *)artist;

@end

@protocol IMCollectionReusableAttributionViewDelegate <NSObject>

@optional

- (void)userDidSelectArtistLink:(NSString *)packURL fromCollectionReusableView:(IMCollectionReusableAttributionView *)footerView;

@end