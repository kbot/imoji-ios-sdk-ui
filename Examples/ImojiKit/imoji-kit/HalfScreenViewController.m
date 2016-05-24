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

#import "HalfScreenViewController.h"
#import "MessageThreadView.h"
#import <ImojiSDK/IMImojiObject.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMCollectionView.h>
#import <ImojiSDKUI/IMCreateImojiViewController.h>
#import <ImojiSDKUI/IMHalfScreenView.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <ImojiSDKUI/IMToolbar.h>
#import <Masonry/Masonry.h>
#import "AppDelegate.h"

@interface HalfScreenViewController () <IMToolbarDelegate, IMSearchViewDelegate, UITextFieldDelegate,
        IMCollectionViewDelegate, IMStickerSearchContainerViewDelegate>

@property(nonatomic, strong) IMToolbar *topToolbar;
@property(nonatomic, strong) MessageThreadView *messageThreadView;
@property(nonatomic, strong) UITextField *inputField;
@property(nonatomic, strong) UIView *inputFieldContainer;
@property(nonatomic, strong) UIButton *actionButton;
@property(nonatomic, strong) UIButton *leftPlaceholderButton;
@property(nonatomic, strong) UIButton *sendButton;
@property(nonatomic, strong) IMHalfScreenView *halfScreenView;
@property(nonatomic) BOOL imojiSearchViewFocused;
@property(nonatomic) BOOL imojiSearchViewActionTapped;

@end

@implementation HalfScreenViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Half Screen";
    }

    return self;
}

- (void)loadView {
    [super loadView];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputFieldWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputFieldWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];

    // this essentially sets the status bar color since the view takes up the full screen
    // and the subviews are positioned below the status bar
    self.view.backgroundColor = [UIColor colorWithRed:248.0f / 255.0f green:248.0f / 255.0f blue:248.0f / 255.0f alpha:1.0f];

    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    self.topToolbar = [[IMToolbar alloc] init];
    UIButton *backButton = [self.topToolbar addToolbarButtonWithType:IMToolbarButtonBack].customView;
    [backButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_close.png", [IMResourceBundleUtil assetsBundle].bundlePath]] forState:UIControlStateNormal];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topToolbar);
        make.left.equalTo(self.topToolbar).offset(15.0f);
        make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
    }];
    self.topToolbar.delegate = self;

    // Message thread view setup
    self.messageThreadView = [[MessageThreadView alloc] init];
    self.messageThreadView.backgroundColor = [UIColor whiteColor];
    [self.messageThreadView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageThreadViewTapped)]];

    // Sticker search container view setup
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:((AppDelegate *)[UIApplication sharedApplication].delegate).appGroup];
    self.halfScreenView = [IMHalfScreenView imojiStickerSearchContainerViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
    self.halfScreenView.delegate = self;
    self.halfScreenView.searchView.createAndRecentsEnabled = [shared boolForKey:@"createAndRecents"];
    self.halfScreenView.imojiSuggestionView.collectionView.renderingOptions.borderStyle = (IMImojiObjectBorderStyle) [shared integerForKey:@"stickerBorders"];

    // Input field container setup
    self.inputFieldContainer = [UIView new];
    self.inputFieldContainer.backgroundColor = self.view.backgroundColor;
    self.inputFieldContainer.layer.borderColor = [UIColor colorWithWhite:207.f / 255.f alpha:0.6f].CGColor;
    self.inputFieldContainer.layer.borderWidth = 1.f;

    // Input field setup
    self.inputField = [[UITextField alloc] init];
    self.inputField.layer.cornerRadius = 4.f;
    self.inputField.layer.borderColor = [UIColor colorWithWhite:207.f / 255.f alpha:1.f].CGColor;
    self.inputField.layer.borderWidth = 1.f;
    self.inputField.backgroundColor = [UIColor colorWithWhite:1.f alpha:.9f];
    self.inputField.returnKeyType = UIReturnKeySend;
    self.inputField.rightViewMode = UITextFieldViewModeAlways;
    self.inputField.defaultTextAttributes = @{
            NSFontAttributeName : [IMAttributeStringUtil defaultFontWithSize:16.f],
            NSForegroundColorAttributeName : [UIColor colorWithWhite:.2f alpha:1.f]
    };
    self.inputField.delegate = self;

    // text indent
    self.inputField.leftView = [[UIView alloc] init];
    self.inputField.leftView.frame = CGRectMake(0, 0, 5.f, 5.f);
    self.inputField.leftViewMode = UITextFieldViewModeAlways;

    // input field right view setup
    self.actionButton = [[UIButton alloc] init];
    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_smiley_inactive.png", [IMResourceBundleUtil assetsBundle].bundlePath]];
    [self.actionButton setImage:image forState:UIControlStateNormal];
    [self.actionButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_smiley_active.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                       forState:UIControlStateSelected];
    [self.actionButton addTarget:self action:@selector(toggleSuggestions) forControlEvents:UIControlEventTouchUpInside];
    CGFloat buttonWidthHeight = image.size.width * 1.15f;
    self.actionButton.layer.cornerRadius = buttonWidthHeight / 2.0f;

    UIView *rightView = [[UIView alloc] init];
    rightView.frame = CGRectMake(0, 0, buttonWidthHeight + 10.f, buttonWidthHeight + 10.f);
    [rightView addSubview:self.actionButton];

    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(rightView);
        make.width.height.equalTo(@(buttonWidthHeight));
    }];

    self.inputField.rightView = rightView;

    // Send button
    self.sendButton = [[UIButton alloc] init];
    self.sendButton.enabled = NO;
    [self.sendButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"SEND"
                                                                       withFont:[IMAttributeStringUtil defaultFontWithSize:16.f]
                                                                          color:[UIColor colorWithRed:22.0f / 255.0f green:137.0f / 255.0f blue:251.0f / 255.0f alpha:1.0f]
                                                                   andAlignment:NSTextAlignmentCenter]
                               forState:UIControlStateNormal];
    [self.sendButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"SEND"
                                                                       withFont:[IMAttributeStringUtil defaultFontWithSize:16.f]
                                                                          color:[UIColor colorWithWhite:.8f alpha:1.f]
                                                                   andAlignment:NSTextAlignmentCenter]
                               forState:UIControlStateDisabled];
    [self.sendButton addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.topToolbar];
    [self.view addSubview:self.messageThreadView];
    [self.view addSubview:self.inputFieldContainer];
    [self.view addSubview:self.halfScreenView];

    [self.inputFieldContainer addSubview:self.leftPlaceholderButton];
    [self.inputFieldContainer addSubview:self.inputField];
    [self.inputFieldContainer addSubview:self.sendButton];

    [self.topToolbar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@44.0f);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];

    [self.messageThreadView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topToolbar.mas_bottom);
        make.bottom.equalTo(self.view);
    }];

    [self.inputFieldContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(50.0f));
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.halfScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.inputFieldContainer.mas_bottom);
        make.height.equalTo(@(IMHalfScreenViewDefaultHeight));
    }];

    [self.inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputFieldContainer).offset(5.0f);
        make.bottom.equalTo(self.inputFieldContainer).offset(-5.0f);
        make.left.equalTo(self.inputFieldContainer).offset(5.0f * 2.f);
        make.right.equalTo(self.sendButton.mas_left).offset(-5.0f * 2.f);
    }];

    [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.height.equalTo(self.inputFieldContainer).offset(-5.0f * 2.f);
        make.centerY.equalTo(self.inputFieldContainer);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Text View Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendText];

    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    BOOL hasText = self.inputField.text.length > 0;
    self.sendButton.enabled = hasText;
}

- (void)sendText {
    if (self.inputField.text.length > 0) {
        [self.messageThreadView sendMessageWithText:self.inputField.text];
    }

    self.inputField.text = @"";
}

- (void)toggleSuggestions {
    self.actionButton.selected = !self.actionButton.selected;
    if(self.actionButton.selected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.halfScreenView.searchView resetSearchView];
            [self.halfScreenView.searchView hideBackButton];
            [self.halfScreenView.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
        });

        [self showSuggestionsAnimated];
    } else {
        [self hideSuggestionsAnimated:NO];
        [self.inputField becomeFirstResponder];
    }
}

- (void)showSuggestionsAnimated {
    if (self.isSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    [self.inputFieldContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@50);
        make.bottom.equalTo(self.view).offset(-IMHalfScreenViewDefaultHeight);
    }];

    [self.halfScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.inputFieldContainer.mas_bottom);
        make.height.equalTo(@(IMHalfScreenViewDefaultHeight));
    }];

    [UIView animateWithDuration:.7f delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
        [self.inputField resignFirstResponder];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, IMHalfScreenViewDefaultHeight + self.inputFieldContainer.frame.size.height, 0);
        self.messageThreadView.contentInset = self.messageThreadView.scrollIndicatorInsets;
    }];
}

- (void)hideSuggestionsAnimated:(BOOL)animated {
    if (!self.isSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    [self.inputFieldContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@50);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.halfScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_bottomLayoutGuideBottom);
        make.height.equalTo(@(IMHalfScreenViewDefaultHeight));
    }];

    if (animated) {
        [UIView animateWithDuration:.7f delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.inputFieldContainer.frame.size.height, 0);
            self.messageThreadView.contentInset = self.messageThreadView.scrollIndicatorInsets;

            if (self.messageThreadView.empty) {
                [self.messageThreadView.collectionViewLayout invalidateLayout];
            } else {
                [self.messageThreadView scrollToBottom];
            }
        }];
    }

    [self.halfScreenView.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];
}

- (BOOL)isSuggestionViewDisplayed {
    return self.halfScreenView.frame.origin.y + self.halfScreenView.frame.size.height == self.view.frame.size.height;
}

- (BOOL)isSuggestionViewUsingInitialHeight {
    return self.halfScreenView.frame.size.height == IMHalfScreenViewDefaultHeight;
}

#pragma mark Search View Delegate

- (void)userDidBeginSearchFromSearchView:(IMSearchView *)searchView {
    self.imojiSearchViewFocused = YES;
}

- (void)userDidEndSearchFromSearchView:(IMSearchView *)searchView {
    self.imojiSearchViewFocused = NO;
}

- (void)userDidPressReturnKeyFromSearchView:(IMSearchView *)searchView {
    self.imojiSearchViewActionTapped = YES;
}

- (void)userDidTapCancelButtonFromSearchView:(IMSearchView *)searchView {
    self.imojiSearchViewActionTapped = YES;
}

#pragma mark Imoji Collection View Delegate

- (void)userDidSelectImoji:(nonnull IMImojiObject *)imoji fromCollectionView:(nonnull IMCollectionView *)collectionView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [((AppDelegate *)[UIApplication sharedApplication].delegate).session markImojiUsageWithIdentifier:imoji.identifier originIdentifier:@"imoji kit half screen: imoji selected"];
    });

    [self.messageThreadView sendMessageWithImoji:imoji];
}

#pragma mark Keyboard Handling

- (void)messageThreadViewTapped {
    self.actionButton.selected = NO;
    [self hideSuggestionsAnimated:YES];
    [self.inputField resignFirstResponder];
    [self.halfScreenView.searchView.searchTextField resignFirstResponder];
    [self.halfScreenView.searchView resetSearchView];
    [self.halfScreenView.searchView hideBackButton];
}

- (void)inputFieldWillShow:(NSNotification *)notification {
    if (self.isSuggestionViewDisplayed && !self.isSuggestionViewUsingInitialHeight) {
        return;
    }

    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve =
            (UIViewAnimationOptions) ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16);

    [self.inputFieldContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@50);
        make.bottom.equalTo(self.view).offset(-endRect.size.height - (self.imojiSearchViewFocused ? IMSearchViewContainerDefaultHeight : 0.0f));
    }];

    if (!self.imojiSearchViewFocused) {
        self.actionButton.selected = NO;
    }

    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, endRect.size.height + self.inputFieldContainer.frame.size.height, 0);
        self.messageThreadView.contentInset = self.messageThreadView.scrollIndicatorInsets;


        if (self.messageThreadView.empty) {
            [self.messageThreadView.collectionViewLayout invalidateLayout];
        } else {
            [self.messageThreadView scrollToBottom];
        }
    }];
}

- (void)inputFieldWillHide:(NSNotification *)notification {
    if (self.isSuggestionViewDisplayed) {
        return;
    }

    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve =
            (UIViewAnimationOptions) ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16);

    [self.inputFieldContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@50);

        if(self.imojiSearchViewActionTapped) {
            make.bottom.equalTo(self.view).offset(-IMHalfScreenViewDefaultHeight);
        } else {
            make.bottom.equalTo(self.view);
        }
    }];

    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.inputFieldContainer.frame.size.height, 0);
        self.messageThreadView.contentInset = self.messageThreadView.scrollIndicatorInsets;

        if (self.messageThreadView.empty) {
            [self.messageThreadView.collectionViewLayout invalidateLayout];
        }

        self.imojiSearchViewActionTapped = NO;
    }];
}

#pragma mark IMToolBarDelegate

- (void)userDidSelectToolbarButton:(IMToolbarButtonType)buttonType {
    switch (buttonType) {
        case IMToolbarButtonBack:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;

        default:
            break;
    }
}

#pragma mark View controller overrides

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return self.topToolbar == bar ? UIBarPositionTopAttached : UIBarPositionAny;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.messageThreadView.collectionViewLayout invalidateLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.messageThreadView.collectionViewLayout invalidateLayout];
}

@end