//
//  ImojiSDKUI
//
//  Created by Jeff Wang
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
#import <Foundation/Foundation.h>
#import <ImojiSDK/ImojiSDK.h>
#import "IMCollectionView.h"

@class IMImojiSession;

@protocol IMKeyboardCollectionViewDelegate;

@interface IMKeyboardCollectionView : IMCollectionView

@property(nonatomic) UITapGestureRecognizer *doubleTapFolderGesture;
@property(nonatomic) UITapGestureRecognizer *noResultsTapGesture;
@property(nonatomic, strong) NSString *appGroup;
@property(nonatomic, weak) id <IMKeyboardCollectionViewDelegate> collectionViewDelegate;

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session;

- (void)loadRecentImojis;

- (void)loadFavoriteImojis;

@end

@protocol IMKeyboardCollectionViewDelegate <IMCollectionViewDelegate>

@optional

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category;

- (void)userDidTapNoResultsView;

- (void)userDidBeginDownloadingImoji;

- (void)imojiDidFinishDownloadingWithMessage:(NSString *)message;

- (void)userDidAddImojiToCollection;

@end

