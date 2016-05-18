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
#import <ImojiSDK/IMImojiCategoryObject.h>
#import <ImojiSDK/IMImojiObject.h>
#import <ImojiSDKUI/IMCollectionView.h>
#import <ImojiSDKUI/IMCreateImojiViewController.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <ImojiSDKUI/IMSearchView.h>
#import <ImojiSDKUI/IMSuggestionView.h>
#import <ImojiSDKUI/IMToolbar.h>
#import <Masonry/Masonry.h>
#import "AppDelegate.h"

CGFloat const InitialSuggestionViewHeight = 226.f;

@interface HalfScreenViewController () <IMToolbarDelegate, IMSearchViewDelegate, UITextFieldDelegate, IMCollectionViewDelegate,
        IMCreateImojiViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong) IMToolbar *topToolbar;
@property(nonatomic, strong) MessageThreadView *messageThreadView;
@property(nonatomic, strong) UITextField *inputField;
@property(nonatomic, strong) IMSearchView *searchView;
@property(nonatomic, strong) UIView *inputFieldContainer;
@property(nonatomic, strong) UIButton *actionButton;
@property(nonatomic, strong) UIButton *leftPlaceholderButton;
@property(nonatomic, strong) UIButton *sendButton;
@property(nonatomic, strong) IMSuggestionView *imojiSuggestionView;
@property(nonatomic, strong) UIView *suggestionContainerView;
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

    // Suggestion container view setup
    self.suggestionContainerView = [[UIView alloc] init];

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:((AppDelegate *)[UIApplication sharedApplication].delegate).appGroup];

    // Imoji search view setup
    self.searchView = [IMSearchView imojiSearchView];
    self.searchView.createAndRecentsEnabled = [shared boolForKey:@"createAndRecents"];
    self.searchView.searchViewScreenType = IMSearchViewScreenTypeHalf;
    self.searchView.backButtonType = IMSearchViewBackButtonTypeBack;
    self.searchView.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchView.delegate = self;

    // Imoji suggestion view setup
    self.imojiSuggestionView = [IMSuggestionView imojiSuggestionViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
    self.imojiSuggestionView.backgroundColor = [UIColor whiteColor];
    self.imojiSuggestionView.collectionView.backgroundColor = [UIColor clearColor];
    self.imojiSuggestionView.collectionView.infiniteScroll = YES;
    self.imojiSuggestionView.collectionView.preferredImojiDisplaySize = CGSizeMake(74.f, 91.f);
    self.imojiSuggestionView.collectionView.renderingOptions.borderStyle = (IMImojiObjectBorderStyle) [shared integerForKey:@"stickerBorders"];
    self.imojiSuggestionView.collectionView.collectionViewDelegate = self;

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

    // Button to the left of the input field
    self.leftPlaceholderButton = [[UIButton alloc] init];
    [self.leftPlaceholderButton setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/placeholdericon_left.png", [IMResourceBundleUtil assetsBundle].bundlePath]]
                                forState:UIControlStateNormal];

    [self.view addSubview:self.topToolbar];
    [self.view addSubview:self.messageThreadView];
    [self.view addSubview:self.inputFieldContainer];
    [self.view addSubview:self.suggestionContainerView];

    [self.inputFieldContainer addSubview:self.leftPlaceholderButton];
    [self.inputFieldContainer addSubview:self.inputField];
    [self.inputFieldContainer addSubview:self.sendButton];

    [self.suggestionContainerView addSubview:self.searchView];
    [self.suggestionContainerView addSubview:self.imojiSuggestionView];

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

    [self.suggestionContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.inputFieldContainer.mas_bottom);
        make.height.equalTo(@(InitialSuggestionViewHeight));
    }];

    [self.leftPlaceholderButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.inputFieldContainer).offset(5.0f * 2.f);
        make.width.and.height.equalTo(@26.0f);
        make.centerY.equalTo(self.inputFieldContainer);
    }];

    [self.inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputFieldContainer).offset(5.0f);
        make.bottom.equalTo(self.inputFieldContainer).offset(-5.0f);
        make.left.equalTo(self.leftPlaceholderButton.mas_right).offset(5.0f * 2.f);
        make.right.equalTo(self.sendButton.mas_left).offset(-5.0f * 2.f);
    }];

    [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.height.equalTo(self.inputFieldContainer).offset(-5.0f * 2.f);
        make.centerY.equalTo(self.inputFieldContainer);
    }];

    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.suggestionContainerView);
        make.left.right.equalTo(self.suggestionContainerView);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
    }];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.suggestionContainerView);
        make.top.equalTo(self.searchView.mas_bottom);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight * 2.0f));
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
//    [self.imojiSuggestionView.collectionView loadImojisFromSentence:self.inputField.text];
    BOOL hasText = self.inputField.text.length > 0;
//    BOOL shouldUpdateSendButtonDisplay = (self.sendButton.enabled != hasText);
//
    self.sendButton.enabled = hasText;
//
//    if (shouldUpdateSendButtonDisplay) {
//        [self.inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
//            if (self.sendButton.enabled) {
//                make.top.left.bottom.equalTo(self.inputFieldContainer).insets(UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f));
//                make.right.equalTo(self.sendButton.mas_left).offset(-5.0f * 2.f);
//            } else {
//                make.edges.equalTo(self.inputFieldContainer).insets(UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f));
//            }
//        }];
//
//        self.sendButton.hidden = !hasText;
//    }
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
        [self showSuggestionsAnimated];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
        });
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
        make.bottom.equalTo(self.view).offset(-InitialSuggestionViewHeight);
    }];

    [self.suggestionContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.inputFieldContainer.mas_bottom);
        make.height.equalTo(@(InitialSuggestionViewHeight));
    }];

    [UIView animateWithDuration:.7f delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
        [self.inputField resignFirstResponder];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, InitialSuggestionViewHeight + self.inputFieldContainer.frame.size.height, 0);
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

    [self.suggestionContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_bottomLayoutGuideBottom);
        make.height.equalTo(@(InitialSuggestionViewHeight));
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

    [self.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];
}

- (BOOL)isSuggestionViewDisplayed {
    return self.suggestionContainerView.frame.origin.y + self.suggestionContainerView.frame.size.height == self.view.frame.size.height;
}

- (BOOL)isSuggestionViewUsingInitialHeight {
    return self.suggestionContainerView.frame.size.height == InitialSuggestionViewHeight;
}

#pragma mark Search View Delegate

- (void)userDidBeginSearchFromSearchView:(IMSearchView *)searchView {
    self.imojiSearchViewFocused = YES;
}

- (void)userDidChangeTextFieldFromSearchView:(IMSearchView *)searchView {
    BOOL hasText = self.searchView.searchTextField.text.length > 0;

    if (!hasText) {
        [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
    } else {
        [self.imojiSuggestionView.collectionView loadImojisFromSentence:self.searchView.searchTextField.text];
    }
}

- (void)userDidEndSearchFromSearchView:(IMSearchView *)searchView {
    self.imojiSearchViewFocused = NO;
}

- (void)userDidPressReturnKeyFromSearchView:(IMSearchView *)searchView {
    self.imojiSearchViewActionTapped = YES;
    [self.searchView.searchTextField resignFirstResponder];
}

- (void)userDidClearTextFieldFromSearchView:(IMSearchView *)searchView {
    [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
}

- (void)userDidTapBackButtonFromSearchView:(IMSearchView *)searchView {
    [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
}

- (void)userDidTapCancelButtonFromSearchView:(IMSearchView *)searchView {
    self.imojiSearchViewActionTapped = YES;

    if (searchView.recentsButton.selected) {
        [self.imojiSuggestionView.collectionView loadRecents];
    } else if (![searchView.previousSearchTerm isEqualToString:searchView.searchTextField.text]) {
        if([searchView.previousSearchTerm isEqualToString:@""]) {
            [self userDidClearTextFieldFromSearchView:searchView];
        } else {
            [self.imojiSuggestionView.collectionView loadImojisFromSentence:searchView.previousSearchTerm];
        }
    }
}

- (void)userDidTapCreateButtonFromSearchView:(IMSearchView *)searchView {
//    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0) {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;

            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
//    } else {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                                 delegate:self
//                                                        cancelButtonTitle:@"Cancel"
//                                                   destructiveButtonTitle:nil
//                                                        otherButtonTitles:@"Photo Library", nil];
//
//        [actionSheet showInView:self.view];
//    }
}

- (void)userDidTapRecentsButtonFromSearchView:(IMSearchView *)searchView {
    [self.imojiSuggestionView.collectionView loadRecents];
}

#pragma mark Imoji Collection View Delegate

- (void)userDidSelectImoji:(nonnull IMImojiObject *)imoji fromCollectionView:(nonnull IMCollectionView *)collectionView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [((AppDelegate *)[UIApplication sharedApplication].delegate).session markImojiUsageWithIdentifier:imoji.identifier originIdentifier:@"imoji kit half screen: imoji selected"];
    });

    [self.messageThreadView sendMessageWithImoji:imoji];
}

- (void)userDidSelectCategory:(nonnull IMImojiCategoryObject *)category fromCollectionView:(nonnull IMCollectionView *)collectionView {
    self.searchView.searchTextField.text = category.title;
    self.searchView.searchTextField.rightView.hidden = NO;
    self.searchView.createButton.hidden = YES;
    self.searchView.recentsButton.hidden = YES;
    [self.searchView showBackButton];

    [collectionView loadImojisFromCategory:category];
}

#pragma mark Keyboard Handling

- (void)messageThreadViewTapped {
    self.actionButton.selected = NO;
    [self hideSuggestionsAnimated:YES];
    [self.inputField resignFirstResponder];
    [self.searchView.searchTextField resignFirstResponder];
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
            make.bottom.equalTo(self.view).offset(-InitialSuggestionViewHeight);
        } else {
            make.bottom.equalTo(self.view).offset((self.view.frame.size.height - endRect.origin.y) * -1);
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

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    IMCreateImojiViewController *createImojiViewController = [[IMCreateImojiViewController alloc] initWithSourceImage:image session: ((AppDelegate *)[UIApplication sharedApplication].delegate).session];
    createImojiViewController.createDelegate = self;
    createImojiViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    createImojiViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [picker presentViewController:createImojiViewController animated: true completion: nil];
}

#pragma mark IMCreateImojiViewControllerDelegate

- (void)imojiUploadDidBegin:(IMImojiObject *)localImoji fromViewController:(IMCreateImojiViewController *)viewController {
    [((AppDelegate *)[UIApplication sharedApplication].delegate).session markImojiUsageWithIdentifier:localImoji.identifier originIdentifier:@"imoji created"];
}

- (void)imojiUploadDidComplete:(IMImojiObject *)localImoji
               persistentImoji:(IMImojiObject *)persistentImoji
                     withError:(NSError *)error
            fromViewController:(IMCreateImojiViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];

    [self.imojiSuggestionView.collectionView loadRecents];
}

- (void)userDidCancelImageEdit:(IMCreateImojiViewController *)viewController {
    [viewController dismissViewControllerAnimated:NO completion:nil];
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