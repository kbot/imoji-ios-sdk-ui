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

@class IMImojiSession;

@protocol IMKeyboardCollectionViewDelegate;

@interface IMKeyboardCollectionView : UICollectionView

@property(nonatomic, strong) void(^categoryShowCallback) (NSString *title);
@property(nonatomic, strong) void(^setProgressCallback) (float progress);
@property(nonatomic, strong) void(^showDownloadingCallback) ();
@property(nonatomic, strong) void(^showCopiedCallback) (NSString *message);
@property(nonatomic, strong) void(^showFavoritedCallback) ();
@property(nonatomic) IMImojiSessionCategoryClassification currentCategoryClassification;
@property(nonatomic) UITapGestureRecognizer *doubleTapFolderGesture;
@property(nonatomic) UITapGestureRecognizer *noResultsTapGesture;
@property(nonatomic, strong) NSString *appGroup;

+ (instancetype)imojiCollectionViewWithSession:(IMImojiSession *)session;

- (void)loadImojiCategories:(IMImojiSessionCategoryClassification)classification;

- (void)loadRecentImojis;

- (void)loadFavoriteImojis;

- (void)loadImojisFromSearch:(NSString *)searchTerm offset:(NSNumber *)offset;

@property(nonatomic, strong) id <IMKeyboardCollectionViewDelegate> keyboardDelegate;

@end

@protocol IMKeyboardCollectionViewDelegate <NSObject>

@optional

- (void)selectedNoResultsView;

@end

