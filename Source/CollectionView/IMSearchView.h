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

#import <UIKit/UIKit.h>

extern const CGFloat IMSearchViewIconWidthHeight;
extern const CGFloat IMSearchViewContainerDefaultHeight;
extern const CGFloat IMSearchViewDefaultLeftOffset;
extern const CGFloat IMSearchViewDefaultRightOffset;

@protocol IMSearchViewDelegate;

@interface IMSearchView : UIView

@property(nonatomic, strong, readonly) UITextField *searchTextField;
@property(nonatomic, copy, readonly) NSString *previousSearchTerm;
@property(nonatomic) BOOL cancelButtonEnabled;
@property(nonatomic, weak) id <IMSearchViewDelegate> delegate;

+ (instancetype)imojiSearchView;

@end

@protocol IMSearchViewDelegate <NSObject>

@optional

- (void)userDidBeginSearchFromSearchView:(IMSearchView *)searchView;

- (void)userDidChangeTextFieldFromSearchView:(IMSearchView *)searchView;

- (void)userDidEndSearchFromSearchView:(IMSearchView *)searchView;

- (void)userDidPressReturnKeySearchView:(IMSearchView *)searchView;

- (void)userShouldBeginSearchFromSearchView:(IMSearchView *)searchView;

@end
