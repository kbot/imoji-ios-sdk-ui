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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, IMCollectionViewSplashCellType) {
    IMCollectionViewSplashCellNoConnection = 1,
    IMCollectionViewSplashCellEnableFullAccess,
    IMCollectionViewSplashCellNoResults,
    IMCollectionViewSplashCellRecents,
    IMCollectionViewSplashCellCollection
};

extern NSString * __nonnull const IMCollectionViewSplashCellReuseId;

@interface IMCollectionViewSplashCell : UICollectionViewCell

@property(nonatomic, strong, nullable) UIView *splashContainer;
@property(nonatomic, strong, nullable) UIImageView *splashGraphic;
@property(nonatomic, strong, nullable) UILabel *splashText;
@property(nonatomic) IMCollectionViewSplashCellType splashType;

- (void)showSplashCellType:(IMCollectionViewSplashCellType)splashCellType withImageBundle:(NSBundle * __nonnull)imageBundle;

@end
