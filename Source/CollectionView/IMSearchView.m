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
#import "NSString+Utils.h"

@interface IMSearchView () <UITextFieldDelegate>

@property(nonatomic, strong) UIImageView *searchIconImageView;
@property(nonatomic, strong) UITextField *searchTextField;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, copy) NSString *previousSearchTerm;

@end

@implementation IMSearchView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.searchIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_search.png", [IMResourceBundleUtil assetsBundle].bundlePath]]];

        self.searchTextField = [[UITextField alloc] init];
        self.searchTextField.font = [IMAttributeStringUtil montserratLightFontWithSize:20.f];
        self.searchTextField.textColor = [UIColor colorWithRed:38.0f / 255.0f green:40.0f / 255.0f blue:50.0f / 255.0f alpha:1.0f];
        self.searchTextField.attributedPlaceholder = [IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionViewControllerSearchStickers"]
                                                                                    withFont:[IMAttributeStringUtil montserratLightFontWithSize:20.f]
                                                                                       color:[UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]
                                                                                andAlignment:NSTextAlignmentLeft];
        self.searchTextField.spellCheckingType = UITextSpellCheckingTypeNo;
        self.searchTextField.enablesReturnKeyAutomatically = NO;
        self.searchTextField.delegate = self;

        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_clearfield.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                     forState:UIControlStateNormal];
        [clearButton addTarget:self action:@selector(textFieldShouldClear:) forControlEvents:UIControlEventTouchUpInside];

        self.searchTextField.rightView = clearButton;
        self.searchTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        self.searchTextField.rightView.hidden = YES;
        [self.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.cancelButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Cancel"
                                                                             withFont:[IMAttributeStringUtil montserratLightFontWithSize:16.0f]
                                                                                color:[UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]]
                                     forState:UIControlStateNormal];
        self.cancelButton.hidden = YES;
        [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:self.searchIconImageView];
        [self addSubview:self.searchTextField];
        [self addSubview:self.cancelButton];

        [self.searchIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.and.left.equalTo(self);
            make.width.and.height.equalTo(@26.0f);
        }];

        [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(self);
            make.left.equalTo(self.searchIconImageView.mas_right).offset(7.0f);
            make.right.equalTo(self.cancelButton.mas_left).offset(-14.0f);
        }];

        [self.searchTextField.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.equalTo(@26.0f);
        }];

        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.and.right.equalTo(self);
        }];
    }

    return self;
}

- (void)cancelButtonTapped {
    self.searchTextField.text = self.previousSearchTerm;
    [self.searchTextField endEditing:YES];
}

- (void)textFieldDidChange:(UITextField *)sender {
    self.searchTextField.rightView.hidden = [self.searchTextField.text isEqualToString:@""];

    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidChangeTextFieldFromSearchView:)]) {
        [self.delegate userDidChangeTextFieldFromSearchView:self];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.previousSearchTerm = self.searchTextField.text;
    self.searchTextField.attributedPlaceholder = [IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionViewControllerSearchStickers"]
                                                                                withFont:[IMAttributeStringUtil montserratLightFontWithSize:20.f]
                                                                                   color:[UIColor colorWithRed:204.0f / 255.0f green:204.0f / 255.0f blue:204.0f / 255.0f alpha:1.0f]
                                                                            andAlignment:NSTextAlignmentLeft];
    self.searchTextField.textColor = [UIColor colorWithRed:38.0f / 255.0f green:40.0f / 255.0f blue:50.0f / 255.0f alpha:1.0f];
    self.cancelButton.hidden = NO;

    if (![self.cancelButton isDescendantOfView:self]) {
        [self addSubview:self.cancelButton];
    }

    [self.searchTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self);
        make.left.equalTo(self.searchIconImageView.mas_right).offset(7.0f);
        make.right.equalTo(self.cancelButton.mas_left).offset(-14.0f);
    }];

    [self.cancelButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.and.right.equalTo(self);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.searchTextField.attributedPlaceholder = [IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"collectionViewControllerSearchStickers"]
                                                                                withFont:[IMAttributeStringUtil montserratLightFontWithSize:20.f]
                                                                                   color:[UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f]
                                                                            andAlignment:NSTextAlignmentLeft];
    self.searchTextField.textColor = [UIColor colorWithRed:10.0f / 255.0f green:140.0f / 255.0f blue:255.0f / 255.0f alpha:1.0f];
    self.cancelButton.hidden = YES;

    if (self.searchTextField.text.length > 0) {
        [self.cancelButton removeFromSuperview];

        [self.searchTextField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-5.0f);
        }];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.searchTextField.text = @"";
    self.searchTextField.rightView.hidden = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchTextField endEditing:YES];
    return YES;
}

@end
