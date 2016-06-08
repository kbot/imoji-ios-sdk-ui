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

#import "IMSearchView.h"
#import "IMResourceBundleUtil.h"
#import "IMAttributeStringUtil.h"
#import "View+MASAdditions.h"

#if __has_include(<ImojiGraphics/ImojiGraphics.h>) && __has_include(<ImojiSDKUI/IMCreateImojiViewController.h>) && !defined(IMOJI_APP_EXTENSION)
#define IMOJI_EDITOR_ENABLED 1
#else
#define IMOJI_EDITOR_ENABLED 0
#endif


CGFloat const IMSearchViewIconWidthHeight = 26.0f;
CGFloat const IMSearchViewBackButtonSearchIconOffset = 18.0f;
CGFloat const IMSearchViewCreateRecentsIconWidthHeight = 36.0f;
CGFloat const IMSearchViewContainerDefaultHeight = 44.0f;
CGFloat const IMSearchViewContainerDefaultLeftOffset = 15.0f;
CGFloat const IMSearchViewContainerDefaultRightOffset = 9.0f;

@interface IMSearchView () <UITextFieldDelegate>

@property(nonatomic, strong) UIView *searchViewContainer;
@property(nonatomic, strong) UIImageView *searchIconImageView;
@property(nonatomic, strong) UITextField *searchTextField;

@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) UIButton *clearButton;
@property(nonatomic, strong) UIButton *recentsButton;
@property(nonatomic, strong) UIButton *createButton;
@property(nonatomic, copy) NSString *previousSearchTerm;

@end

@implementation IMSearchView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSearchView];
    }

    return self;
}

- (void)setupSearchView {
    self.backgroundColor = [UIColor whiteColor];

    self.searchViewContainer = [[UIView alloc] init];
    self.searchViewContainer.backgroundColor = [UIColor clearColor];

    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    self.searchIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_search.png", [IMResourceBundleUtil assetsBundle].bundlePath]]];
    self.searchIconImageView.userInteractionEnabled = YES;
    [self.searchIconImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchIconTapped)]];

    self.searchTextField = [[UITextField alloc] init];
    self.searchTextField.font = [IMAttributeStringUtil montserratLightFontWithSize:20.f];
    self.searchTextField.textColor = [UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f];
    self.searchTextField.attributedPlaceholder = [IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionViewControllerSearchStickers"]
                                                                                withFont:[IMAttributeStringUtil montserratLightFontWithSize:20.f]
                                                                                   color:[UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]
                                                                            andAlignment:NSTextAlignmentLeft];
    self.searchTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    self.searchTextField.enablesReturnKeyAutomatically = NO;
    self.searchTextField.delegate = self;

    self.clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clearButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_clearfield.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                      forState:UIControlStateNormal];
    [self.clearButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_clearfield_downstate.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                      forState:UIControlStateHighlighted];
    [self.clearButton addTarget:self action:@selector(clearButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    self.searchTextField.rightView = self.clearButton;
    self.searchTextField.rightViewMode = UITextFieldViewModeAlways;
    self.searchTextField.rightView.hidden = YES;
    [self.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Cancel"
                                                                         withFont:[IMAttributeStringUtil montserratLightFontWithSize:16.0f]
                                                                            color:[UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]]
                                 forState:UIControlStateNormal];
    self.cancelButton.hidden = YES;
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.searchViewContainer];

    [self.searchViewContainer addSubview:self.searchIconImageView];
    [self.searchViewContainer addSubview:self.searchTextField];
    [self.searchViewContainer addSubview:self.cancelButton];

    [self.searchViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.left.equalTo(self).offset(IMSearchViewContainerDefaultLeftOffset);
        make.right.equalTo(self).offset(-IMSearchViewContainerDefaultRightOffset);
    }];

    [self.searchIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchViewContainer);
        make.centerY.equalTo(self.searchViewContainer);
        make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
    }];

    [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(IMSearchViewIconWidthHeight));
        make.left.equalTo(self.searchIconImageView.mas_right).offset(7.0f);
        make.right.and.centerY.equalTo(self.searchViewContainer);
    }];

    [self.searchTextField.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
    }];

    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.and.right.equalTo(self.searchViewContainer);
        make.width.equalTo(@([self.cancelButton.currentAttributedTitle size].width));
    }];
}

- (void)resetSearchView {
    self.searchTextField.text = @"";
    self.searchTextField.rightView = self.clearButton;
    self.searchTextField.rightView.hidden = YES;
    self.searchIconImageView.hidden = NO;

    if (![self.searchIconImageView isDescendantOfView:self.searchViewContainer]) {
        [self.searchViewContainer addSubview:self.searchIconImageView];

        [self.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.searchViewContainer);
            make.centerY.equalTo(self.searchViewContainer);
            make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
        }];
    }

    [self.searchTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(IMSearchViewIconWidthHeight));
        make.left.equalTo(self.searchIconImageView.mas_right).offset(7.0f);
        make.centerY.equalTo(self.searchViewContainer);

        if([self.searchTextField isFirstResponder]) {
            make.right.equalTo(self.cancelButton.mas_left).offset(-14.0f);
        } else {
            make.right.equalTo(self.searchViewContainer);
        }
    }];

    if (self.createAndRecentsEnabled) {
        self.recentsButton.selected = NO;
        self.recentsButton.hidden = [self.searchTextField isFirstResponder];
        self.createButton.hidden = [self.searchTextField isFirstResponder];

        [self.recentsButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.equalTo(@(IMSearchViewCreateRecentsIconWidthHeight));
#if IMOJI_EDITOR_ENABLED
            make.right.equalTo(self.createButton.mas_left).offset(-4.0f);
#else
            make.right.equalTo(self.searchViewContainer).offset(-1.0f);
#endif
            make.centerY.equalTo(self.searchViewContainer);
        }];
    }
}

- (void)backButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapBackButtonFromSearchView:)]) {
        [self.delegate userDidTapBackButtonFromSearchView:self];
    }
}

- (void)cancelButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapCancelButtonFromSearchView:)]) {
        [self.delegate userDidTapCancelButtonFromSearchView:self];
    }

    self.searchTextField.text = self.recentsButton.selected ? [IMResourceBundleUtil localizedStringForKey:@"collectionReusableHeaderViewRecents"]: self.previousSearchTerm;

    [self.searchTextField endEditing:YES];
}

- (void)clearButtonTapped {
    [self resetSearchView];

    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidClearTextFieldFromSearchView:)]) {
        [self.delegate userDidClearTextFieldFromSearchView:self];
    }
}

- (void)createButtonTapped {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapCreateButtonFromSearchView:)]) {
        [self.delegate userDidTapCreateButtonFromSearchView:self];
    }
}

- (void)recentsButtonTapped {
    self.searchTextField.text = [IMResourceBundleUtil localizedStringForKey:@"collectionReusableHeaderViewRecents"];
    self.searchTextField.rightView.hidden = NO;
    [self.searchTextField resignFirstResponder];

    self.recentsButton.selected = YES;

    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapRecentsButtonFromSearchView:)]) {
        [self.delegate userDidTapRecentsButtonFromSearchView:self];
    }
}

- (void)searchIconTapped {
    [self.searchTextField becomeFirstResponder];
}

- (void)textFieldDidChange:(UITextField *)textField {
    self.searchTextField.rightView.hidden = [self.searchTextField.text isEqualToString:@""];
    self.createButton.hidden = YES;
    self.recentsButton.hidden = YES;

    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidChangeTextFieldFromSearchView:)]) {
        [self.delegate userDidChangeTextFieldFromSearchView:self];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.recentsButton.selected) {
        self.searchTextField.text = @"";
        self.searchIconImageView.hidden = NO;

        self.searchTextField.rightView = self.clearButton;


        [self.searchViewContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(IMSearchViewContainerDefaultLeftOffset);
        }];

        if (![self.searchIconImageView isDescendantOfView:self.searchViewContainer]) {
            [self.searchViewContainer addSubview:self.searchIconImageView];
        }
    } else {
        self.previousSearchTerm = self.searchTextField.text;
    }

    self.searchTextField.attributedPlaceholder = [IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionViewControllerSearchStickers"]
                                                                                withFont:[IMAttributeStringUtil montserratLightFontWithSize:20.f]
                                                                                   color:[UIColor colorWithRed:204.0f / 255.0f green:204.0f / 255.0f blue:204.0f / 255.0f alpha:1.0f]
                                                                            andAlignment:NSTextAlignmentLeft];
    self.searchTextField.textColor = [UIColor colorWithRed:38.0f / 255.0f green:40.0f / 255.0f blue:50.0f / 255.0f alpha:1.0f];
    self.searchTextField.rightView.hidden = [self.searchTextField.text isEqualToString:@""];

    self.cancelButton.hidden = NO;

    if (self.createAndRecentsEnabled) {
        self.recentsButton.hidden = YES;
        self.createButton.hidden = YES;
    }

    [self.searchTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.searchViewContainer);
        make.height.equalTo(@(IMSearchViewIconWidthHeight));
        make.left.equalTo(self.searchIconImageView.mas_right).offset(7.0f);
        make.right.equalTo(self.cancelButton.mas_left).offset(-14.0f);
    }];

    if(self.delegate && [self.delegate respondsToSelector:@selector(userDidBeginSearchFromSearchView:)]) {
        [self.delegate userDidBeginSearchFromSearchView:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.searchTextField.attributedPlaceholder = [IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionViewControllerSearchStickers"]
                                                                                withFont:[IMAttributeStringUtil montserratLightFontWithSize:20.f]
                                                                                   color:[UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]
                                                                            andAlignment:NSTextAlignmentLeft];
    self.searchTextField.textColor = [UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f];
    self.searchTextField.rightView.hidden = [self.searchTextField.text isEqualToString:@""];

    self.cancelButton.hidden = YES;

    [self.searchTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.searchViewContainer);
        make.height.equalTo(@(IMSearchViewIconWidthHeight));
        make.left.equalTo(self.searchIconImageView.mas_right).offset(7.0f);
        make.right.equalTo(self.searchViewContainer).offset(self.searchTextField.text.length > 0 ? -6.0f : 0.0f);
    }];

    if (self.createAndRecentsEnabled) {
        self.recentsButton.hidden = self.searchTextField.text.length > 0 && !self.recentsButton.selected;
        self.createButton.hidden = self.searchTextField.text.length > 0;

        if (self.recentsButton.selected) {
            [self recentsButtonTapped];
        } else {
            [self.recentsButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.and.height.equalTo(@(IMSearchViewCreateRecentsIconWidthHeight));
#if IMOJI_EDITOR_ENABLED
                make.right.equalTo(self.createButton.mas_left).offset(-4.0f);
#else
                make.right.equalTo(self.searchViewContainer).offset(-1.0f);
#endif
                make.centerY.equalTo(self.searchViewContainer);
            }];
        }
    }

    if(self.delegate && [self.delegate respondsToSelector:@selector(userDidEndSearchFromSearchView:)]) {
        [self.delegate userDidEndSearchFromSearchView:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.createAndRecentsEnabled) {
        self.recentsButton.selected = NO;
    }

    self.previousSearchTerm = textField.text;

    if(self.delegate && [self.delegate respondsToSelector:@selector(userDidPressReturnKeyFromSearchView:)]) {
        [self.delegate userDidPressReturnKeyFromSearchView:self];
    } else {
        [self.searchTextField endEditing:YES];
    }

    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(self.delegate && [self.delegate respondsToSelector:@selector(userShouldBeginSearchFromSearchView:)]) {
        [self.delegate userShouldBeginSearchFromSearchView:self];
    }

    return YES;
}

- (void)showBackButton {
    self.backButton.hidden = NO;

    [self.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backButton.mas_right).offset(IMSearchViewBackButtonSearchIconOffset);
        make.centerY.equalTo(self.searchViewContainer);
        make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
    }];
}

- (void)hideBackButton {
    self.backButton.hidden = YES;

    [self.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.centerY.equalTo(self.searchViewContainer);
        make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
    }];

    [self.searchTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(IMSearchViewIconWidthHeight));
        make.left.equalTo(self.searchIconImageView.mas_right).offset(7.0f);
        make.right.and.centerY.equalTo(self.searchViewContainer);
    }];
}

- (void)setBackButtonType:(IMSearchViewBackButtonType)backButtonType {
    _backButtonType = backButtonType;

    if (backButtonType == IMSearchViewBackButtonTypeDismiss) {
        [self.backButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_close.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                         forState:UIControlStateNormal];
        self.backButton.hidden = NO;

        if (![self.backButton isDescendantOfView:self.searchViewContainer]) {
            [self.searchViewContainer addSubview:self.backButton];
        }

        [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.centerY.equalTo(self.searchViewContainer);
            make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
        }];

        [self.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backButton.mas_right).offset(IMSearchViewBackButtonSearchIconOffset);
            make.centerY.equalTo(self.searchViewContainer);
            make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
        }];
    } else if(backButtonType == IMSearchViewBackButtonTypeBack) {
        [self.backButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_back.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                         forState:UIControlStateNormal];

        if (![self.backButton isDescendantOfView:self.searchViewContainer]) {
            [self.searchViewContainer addSubview:self.backButton];
        }

        [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.centerY.equalTo(self.searchViewContainer);
            make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
        }];

        if (self.searchTextField.text.length > 0) {
            [self showBackButton];
        } else {
            [self hideBackButton];
        }
    } else if (backButtonType == IMSearchViewBackButtonTypeDisabled) {
        [self.backButton removeFromSuperview];

        [self.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.searchViewContainer);
            make.centerY.equalTo(self.searchViewContainer);
            make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
        }];
    }
}


- (void)setCreateAndRecentsEnabled:(BOOL)createAndRecentsEnabled {
    _createAndRecentsEnabled = createAndRecentsEnabled;

    if (createAndRecentsEnabled) {
        if (![self.recentsButton isDescendantOfView:self.searchViewContainer]) {
            self.recentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.recentsButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_recents.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                                forState:UIControlStateNormal];
            [self.recentsButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_recents_active.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                                forState:UIControlStateHighlighted];
            [self.recentsButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_recents_active.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                                forState:UIControlStateSelected];
            [self.recentsButton addTarget:self action:@selector(recentsButtonTapped) forControlEvents:UIControlEventTouchUpInside];

            [self.searchViewContainer addSubview:self.recentsButton];
        }

#if IMOJI_EDITOR_ENABLED
        if (![self.createButton isDescendantOfView:self.searchViewContainer]) {
            self.createButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.createButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_create.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                               forState:UIControlStateNormal];
            [self.createButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_create_active.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                               forState:UIControlStateHighlighted];
            [self.createButton addTarget:self action:@selector(createButtonTapped) forControlEvents:UIControlEventTouchUpInside];

            [self.searchViewContainer addSubview:self.createButton];
        }

        [self.createButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.equalTo(@(IMSearchViewCreateRecentsIconWidthHeight));
            make.right.equalTo(self.searchViewContainer).offset(-1.0f);
            make.centerY.equalTo(self.searchViewContainer);
        }];
#endif

        [self.recentsButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.equalTo(@(IMSearchViewCreateRecentsIconWidthHeight));
#if IMOJI_EDITOR_ENABLED
            make.right.equalTo(self.createButton.mas_left).offset(-4.0f);
#else
            make.right.equalTo(self.searchViewContainer).offset(-1.0f);
#endif
            make.centerY.equalTo(self.searchViewContainer);
        }];
    } else {
        [self.recentsButton removeFromSuperview];
        [self.createButton removeFromSuperview];
    }
}

+ (instancetype)imojiSearchView {
    return [[IMSearchView alloc] initWithFrame:CGRectZero];
}

@end
