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

typedef NS_ENUM(NSUInteger, IMSearchViewBackButtonType) {
    IMSearchViewBackButtonTypeDismiss,
    IMSearchViewBackButtonTypeBack,
    IMSearchViewBackButtonTypeDisabled
};

extern CGFloat const IMSearchViewIconWidthHeight;
extern CGFloat const IMSearchViewBackButtonSearchIconOffset;
extern CGFloat const IMSearchViewCreateRecentsIconWidthHeight;
extern CGFloat const IMSearchViewContainerDefaultHeight;
extern CGFloat const IMSearchViewContainerDefaultLeftOffset;
extern CGFloat const IMSearchViewContainerDefaultRightOffset;

@protocol IMSearchViewDelegate;

@interface IMSearchView : UIView

@property(nonatomic) IMSearchViewBackButtonType backButtonType;
@property(nonatomic) BOOL createAndRecentsEnabled;

@property(nonatomic, strong, readonly) UIView *searchViewContainer;
@property(nonatomic, strong, readonly) UIImageView *searchIconImageView;
@property(nonatomic, strong, readonly) UITextField *searchTextField;
@property(nonatomic, strong, readonly) UIButton *cancelButton;
@property(nonatomic, strong, readonly) UIButton *createButton;
@property(nonatomic, strong, readonly) UIButton *recentsButton;
@property(nonatomic, strong, readonly) UIButton *backButton;

@property(nonatomic, copy, readonly) NSString *previousSearchTerm;
@property(nonatomic, weak) id <IMSearchViewDelegate> delegate;

- (void)resetSearchView;

- (void)showBackButton;

- (void)hideBackButton;

+ (instancetype)imojiSearchView;

@end

@protocol IMSearchViewDelegate <NSObject>

@optional

- (void)userDidBeginSearchFromSearchView:(IMSearchView *)searchView;

- (void)userDidChangeTextFieldFromSearchView:(IMSearchView *)searchView;

- (void)userDidClearTextFieldFromSearchView:(IMSearchView *)searchView;

- (void)userDidEndSearchFromSearchView:(IMSearchView *)searchView;

- (void)userDidPressReturnKeyFromSearchView:(IMSearchView *)searchView;

- (void)userDidTapBackButtonFromSearchView:(IMSearchView *)searchView;

- (void)userDidTapCancelButtonFromSearchView:(IMSearchView *)searchView;

- (void)userDidTapCreateButtonFromSearchView:(IMSearchView *)searchView;

- (void)userDidTapRecentsButtonFromSearchView:(IMSearchView *)searchView;

- (void)userShouldBeginSearchFromSearchView:(IMSearchView *)searchView;

@end
