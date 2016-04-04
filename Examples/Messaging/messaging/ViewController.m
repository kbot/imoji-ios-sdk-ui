//
//  ImojiSDKUI
//
//  Created by Nima Khoshini
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

#import "AppDelegate.h"
#import "ViewController.h"
#import "MessageThreadView.h"
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMCollectionView.h>
#import <ImojiSDKUI/IMKeyboardView.h>
#import <ImojiSDKUI/IMKeyboardCollectionView.h>
#import <ImojiSDKUI/IMSuggestionView.h>
#import <ImojiSDKUI/IMToolbar.h>
#import <Masonry/View+MASAdditions.h>
#import <Masonry/ViewController+MASAdditions.h>
#import <YYImage/YYImage.h>

CGFloat const SuggestionViewBarHeight = 101.f;
CGFloat const InputBarHeight = 50.f;
CGFloat const InputFieldPadding = 5.f;
CGFloat const InitialImojiKeyboardViewHeight = 240.f;
CGFloat const SuggestionFieldBorderHeight = 1.f;

@interface ViewController () <UITextFieldDelegate, IMKeyboardViewDelegate, IMKeyboardCollectionViewDelegate, IMToolbarDelegate>

@property(nonatomic, strong) MessageThreadView *messageThreadView;
@property(nonatomic, strong) UITextField *inputField;
@property(nonatomic, strong) UIView *inputFieldContainer;
@property(nonatomic, strong) UIButton *actionButton;
@property(nonatomic, strong) UIButton *sendButton;
@property(nonatomic, strong) IMKeyboardView *imojiKeyboardView;
@property(nonatomic, strong) IMSuggestionView *imojiSuggestionView;

@end

@implementation ViewController {

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

    // Message Thread View Setup
    self.messageThreadView = [[MessageThreadView alloc] init];
    self.messageThreadView.backgroundColor = [UIColor whiteColor];
    [self.messageThreadView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageThreadViewTapped)]];

    // Input Field Setup
    self.inputField = [[UITextField alloc] init];
    self.inputField.layer.cornerRadius = 4.f;
    self.inputField.layer.borderColor = self.imojiSuggestionView.layer.borderColor = [UIColor colorWithWhite:207.f / 255.f alpha:1.f].CGColor;
    self.inputField.layer.borderWidth = self.imojiSuggestionView.layer.borderWidth = 1.f;
    self.inputField.backgroundColor = [UIColor colorWithWhite:1.f alpha:.9f];
    self.inputField.returnKeyType = UIReturnKeySend;
    self.inputField.rightViewMode = UITextFieldViewModeAlways;
    self.inputField.defaultTextAttributes = @{
            NSFontAttributeName : [IMAttributeStringUtil defaultFontWithSize:16.f],
            NSForegroundColorAttributeName : [UIColor colorWithWhite:.2f alpha:1.f]
    };

    // Input field right view
    UIView *rightView = [[UIView alloc] init];
    UIImage *image = [UIImage imageNamed:@"SearchBarOn"];
    CGFloat buttonWidthHeight = image.size.width * 1.15f;
    rightView.frame = CGRectMake(0, 0, buttonWidthHeight + 10.f, buttonWidthHeight + 10.f);
    self.actionButton = [[UIButton alloc] init];
    self.actionButton.backgroundColor = [UIColor colorWithRed:22.0f / 255.0f green:137.0f / 255.0f blue:251.0f / 255.0f alpha:1.0f];
    self.actionButton.layer.cornerRadius = buttonWidthHeight / 2.0f;
    [self.actionButton setImage:image forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(toggleImojiKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:self.actionButton];

    [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(rightView);
        make.width.height.equalTo(@(buttonWidthHeight));
    }];

    self.inputField.rightView = rightView;

    // text indent
    self.inputField.leftView = [[UIView alloc] init];
    self.inputField.leftView.frame = CGRectMake(0, 0, 5.f, 5.f);
    self.inputField.leftViewMode = UITextFieldViewModeAlways;
    self.inputField.delegate = self;

    // Input Field Container Setup
    self.inputFieldContainer = [[UIView alloc] init];
    self.inputFieldContainer.backgroundColor = self.view.backgroundColor;

    // Imoji Keyboard View Setup
    self.imojiKeyboardView = [IMKeyboardView imojiKeyboardViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
    NSBundle *imageBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ImojiKeyboardAssets" ofType:@"bundle"]];
    IMToolbar *newToolbar = [[IMToolbar alloc] init];
    [newToolbar addToolbarButtonWithType:IMToolbarButtonTrending
                                   image:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_trending.png", imageBundle.bundlePath]]
                             activeImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_trending_active.png", imageBundle.bundlePath]]
    ];

    [newToolbar addToolbarButtonWithType:IMToolbarButtonReactions
                                   image:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_reactions.png", imageBundle.bundlePath]]
                             activeImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_reactions_active.png", imageBundle.bundlePath]]
    ];

    [newToolbar addToolbarButtonWithType:IMToolbarButtonArtist
                                   image:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_artist.png", imageBundle.bundlePath]]
                             activeImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_artist_active.png", imageBundle.bundlePath]]
    ];
    [self.imojiKeyboardView.keyboardToolbar setItems:newToolbar.items];
    self.imojiKeyboardView.backgroundColor = self.view.backgroundColor;
    self.imojiKeyboardView.collectionView.backgroundColor = [UIColor clearColor];
    self.imojiKeyboardView.collectionView.preferredImojiDisplaySize = CGSizeMake(80.f, 80.f);
    self.imojiKeyboardView.collectionView.collectionViewDelegate = self;
    self.imojiKeyboardView.delegate = self;
    self.imojiKeyboardView.keyboardToolbar.delegate = self;

    // Imoji Suggestion View Setup
    self.imojiSuggestionView = [IMSuggestionView imojiSuggestionViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
    self.imojiSuggestionView.backgroundColor = self.view.backgroundColor;
    self.imojiSuggestionView.clipsToBounds = NO;
    self.imojiSuggestionView.collectionView.backgroundColor = [UIColor clearColor];
    self.imojiSuggestionView.collectionView.preferredImojiDisplaySize = CGSizeMake(80.f, 80.f);
    self.imojiSuggestionView.collectionView.collectionViewDelegate = self;

    // Send Button Setup
    self.sendButton = [[UIButton alloc] init];
    self.sendButton.enabled = NO;
    self.sendButton.hidden = YES;
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

    // Subviews
    [self.view addSubview:self.messageThreadView];
    [self.view addSubview:self.imojiSuggestionView];
    [self.view addSubview:self.inputFieldContainer];
    [self.view addSubview:self.imojiKeyboardView];

    [self.messageThreadView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.view);
    }];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(SuggestionViewBarHeight));
        make.top.equalTo(self.inputFieldContainer.mas_top).offset(-SuggestionFieldBorderHeight);
    }];

    [self.inputFieldContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(InputBarHeight));
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.imojiKeyboardView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.imojiKeyboardView.keyboardToolbar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.imojiKeyboardView.mas_bottom);
        make.left.equalTo(self.imojiKeyboardView.mas_left);
        make.right.equalTo(self.imojiKeyboardView.mas_right);
        make.height.equalTo(@(IMToolbarDefaultButtonItemWidthAndHeight));
        make.top.equalTo(self.imojiKeyboardView.collectionView.mas_bottom);
    }];

    // Imoji suggestion subviews
    UIView *suggestionTopBorder = [[UIView alloc] init];
    suggestionTopBorder.backgroundColor = self.view.backgroundColor;
    [self.imojiSuggestionView addSubview:suggestionTopBorder];

    [suggestionTopBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imojiSuggestionView).offset(-1);
        make.left.right.equalTo(self.imojiSuggestionView);
        make.height.equalTo(@1);
    }];

    // Input field container subviews
    [self.inputFieldContainer addSubview:self.inputField];
    [self.inputFieldContainer addSubview:self.sendButton];

    [self.inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.inputFieldContainer).insets(UIEdgeInsetsMake(InputFieldPadding, InputFieldPadding, InputFieldPadding, InputFieldPadding));
    }];

    [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.height.equalTo(self.inputFieldContainer).offset(-InputFieldPadding * 2.f);
        make.centerY.equalTo(self.inputFieldContainer);
    }];

    [self.imojiKeyboardView.keyboardToolbar selectButtonOfType:IMToolbarButtonTrending];
}

#pragma mark Text View Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendText];
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    [self.imojiKeyboardView.collectionView loadImojisFromSentence:self.inputField.text];
    [self.imojiSuggestionView.collectionView loadImojisFromSentence:self.inputField.text];
    BOOL hasText = self.inputField.text.length > 0;
    BOOL shouldUpdateSendButtonDisplay = (self.sendButton.enabled != hasText);

    self.sendButton.enabled = hasText;

    if (shouldUpdateSendButtonDisplay) {
        [self.inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.sendButton.enabled) {
                make.top.left.bottom.equalTo(self.inputFieldContainer).insets(UIEdgeInsetsMake(InputFieldPadding, InputFieldPadding, InputFieldPadding, InputFieldPadding));
                make.right.equalTo(self.sendButton.mas_left).offset(-InputFieldPadding * 2.f);
            } else {
                make.edges.equalTo(self.inputFieldContainer).insets(UIEdgeInsetsMake(InputFieldPadding, InputFieldPadding, InputFieldPadding, InputFieldPadding));
            }
        }];

        self.sendButton.hidden = !hasText;
    }

    [self showSuggestionsAnimated:YES];

    if (!hasText) {
        [self.imojiSuggestionView.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationTrending];
    }
}

- (void)sendText {
    if (self.inputField.text.length > 0) {
        [self.messageThreadView sendMessageWithText:self.inputField.text];
    }

    self.inputField.text = @"";
}

- (void)toggleImojiKeyboard {
    if (self.isSuggestionViewDisplayed) {
        if(self.inputField.text.length > 0) {
            self.inputField.text = @"";
            [self.imojiSuggestionView.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationTrending];
        } else {
            [self hideSuggestionsAnimated:YES];
        }
    } else {
        if (self.isImojiKeyboardViewDisplayed) {
            self.actionButton.selected = NO;
            [self hideImojiKeyboardAnimated];
        } else {
            self.actionButton.selected = YES;
            [self showImojiKeyboardAnimated];
            [self hideSuggestionsAnimated:YES];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.imojiKeyboardView.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationTrending];
            });
        }
    }
}

- (void)showImojiKeyboardAnimated {
    if (self.isImojiKeyboardViewDisplayed) {
        return;
    }

    BOOL shouldMoveInputField = self.inputFieldContainer.frame.size.height + self.inputFieldContainer.frame.origin.y == self.view.frame.size.height;
    if (shouldMoveInputField) {
        [self.inputFieldContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.equalTo(@50);
            make.bottom.equalTo(self.view).offset(-InitialImojiKeyboardViewHeight);
        }];
    }

    [self.imojiKeyboardView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.inputFieldContainer.mas_bottom);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.actionButton setImage:[UIImage imageNamed:@"SearchBarOff"] forState:UIControlStateNormal];

    if (shouldMoveInputField) {
        [UIView animateWithDuration:.7f
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.2f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.imojiKeyboardView layoutIfNeeded];
                             [self.inputFieldContainer layoutIfNeeded];
                         } completion:^(BOOL finished) {
                    self.messageThreadView.scrollIndicatorInsets =
                            self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                                    InitialImojiKeyboardViewHeight + self.inputFieldContainer.frame.size.height,
                                    0
                            );
                }];
    } else {
        [self.imojiKeyboardView layoutIfNeeded];
        [self.inputField resignFirstResponder];
    }
}

- (void)hideImojiKeyboardAnimated {
    if (!self.isImojiKeyboardViewDisplayed) {
        return;
    }

    [self.imojiKeyboardView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.actionButton setImage:[UIImage imageNamed:@"SearchBarOn"] forState:UIControlStateNormal];

    [self.imojiKeyboardView layoutIfNeeded];
    [self.inputField becomeFirstResponder];
}

- (BOOL)isImojiKeyboardViewDisplayed {
    return self.imojiKeyboardView.frame.origin.y + self.imojiKeyboardView.frame.size.height == self.view.frame.size.height;
}

- (BOOL)isImojiKeyboardViewUsingInitialHeight {
    return self.imojiKeyboardView.frame.size.height == InitialImojiKeyboardViewHeight;
}

#pragma mark Suggestions View
//- (void)toggleSuggestions {
//    if (self.isSuggestionViewDisplayed) {
//        self.actionButton.selected = NO;
//        [self hideSuggestionsAnimated:YES];
//    } else {
//        self.actionButton.selected = YES;
//        [self.imojiSuggestionView.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationTrending];
//        [self showSuggestionsAnimated:YES];
//    }
//}

- (void)showSuggestionsAnimated:(BOOL)animated {
    if (self.isSuggestionViewDisplayed) {
        return;
    }

    self.imojiSuggestionView.hidden = NO;

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(SuggestionViewBarHeight));
        make.bottom.equalTo(self.inputFieldContainer.mas_top).offset(SuggestionFieldBorderHeight);
    }];

    [self.actionButton setImage:[UIImage imageNamed:@"SearchBarOff"] forState:UIControlStateNormal];

    if (animated) {
        [UIView animateWithDuration:.7f
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.2f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self.imojiSuggestionView layoutIfNeeded];
                         } completion:nil];
    }
}

- (void)hideSuggestionsAnimated:(BOOL)animated {
    if (!self.isSuggestionViewDisplayed) {
        return;
    }

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(SuggestionViewBarHeight));
        make.top.equalTo(self.inputFieldContainer.mas_top).offset(-SuggestionFieldBorderHeight);
    }];

    [self.actionButton setImage:[UIImage imageNamed:@"SearchBarOn"] forState:UIControlStateNormal];

    if (animated) {
        [UIView animateWithDuration:.7f
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.2f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.imojiSuggestionView layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             self.imojiSuggestionView.hidden = YES;
                         }];

    }
}

- (BOOL)isSuggestionViewDisplayed {
    return (self.imojiSuggestionView.frame.origin.y + SuggestionFieldBorderHeight) != self.inputFieldContainer.frame.origin.y;
}

#pragma mark IMKeyboardViewDelegate

- (void)userDidCloseCategoryFromView:(IMKeyboardView *)view {
    [view.collectionView loadImojiCategories:view.currentCategoryClassification];
}

#pragma mark Imoji Collection View Delegate

- (void)userDidSelectImoji:(nonnull IMImojiObject *)imoji fromCollectionView:(nonnull IMCollectionView *)collectionView {
    [self.messageThreadView sendMessageWithImoji:imoji];
}

- (void)userDidSelectCategory:(nonnull IMImojiCategoryObject *)category fromCollectionView:(nonnull IMCollectionView *)collectionView {
    [self.imojiKeyboardView updateTitleWithText:category.title hideCloseButton:NO];
    [self.imojiKeyboardView.collectionView loadImojisFromCategory:category];
}

- (void)userDidSelectAttributionLink:(NSURL *)attributionLink fromCollectionView:(IMCollectionView *)collectionView {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        if ([responder respondsToSelector:@selector(openURL:)]) {
            [responder performSelector:@selector(openURL:) withObject:attributionLink];
        }
    }
}

#pragma mark Keyboard Handling

- (void)messageThreadViewTapped {
    [self.inputField resignFirstResponder];
}

- (void)inputFieldWillShow:(NSNotification *)notification {
    if (self.isImojiKeyboardViewDisplayed && !self.isImojiKeyboardViewUsingInitialHeight) {
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
        make.bottom.equalTo(self.view).offset(-endRect.size.height);
    }];

    if (self.inputField.text.length > 0 && !self.isImojiKeyboardViewDisplayed) {
        [self showImojiKeyboardAnimated];
    }

    if (self.inputField.text.length > 0 && !self.isSuggestionViewDisplayed) {
        [self showSuggestionsAnimated:NO];
    }

    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurve
                     animations:^{
                         [self.inputFieldContainer layoutIfNeeded];
                         [self.imojiKeyboardView layoutIfNeeded];
                         [self.imojiSuggestionView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                self.messageThreadView.scrollIndicatorInsets =
                        self.messageThreadView.contentInset =
                                UIEdgeInsetsMake(0, 0,
                                        endRect.size.height +
//                                                self.inputFieldContainer.frame.size.height,
                                                self.inputFieldContainer.frame.size.height + self.imojiSuggestionView.frame.size.height,
                                        0
                                );


                if (self.messageThreadView.empty) {
                    [self.messageThreadView.collectionViewLayout invalidateLayout];
                } else {
                    [self.messageThreadView scrollToBottom];
                }
            }];
}

- (void)inputFieldWillHide:(NSNotification *)notification {
    if (self.isImojiKeyboardViewDisplayed) {
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
        make.bottom.equalTo(self.view).offset((self.view.frame.size.height - endRect.origin.y) * -1);
    }];
    [self hideImojiKeyboardAnimated];
    [self hideSuggestionsAnimated:NO];

    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurve
                     animations:^{
                         [self.inputFieldContainer layoutIfNeeded];
                         [self.imojiKeyboardView layoutIfNeeded];
                         [self.imojiSuggestionView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                self.messageThreadView.scrollIndicatorInsets =
                        self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
//                                self.inputFieldContainer.frame.size.height,
                                self.inputFieldContainer.frame.size.height + self.imojiSuggestionView.frame.size.height,
                                0
                        );


                if (self.messageThreadView.empty) {
                    [self.messageThreadView.collectionViewLayout invalidateLayout];
                }
            }];
}

#pragma mark IMToolBarDelegate
- (void)userDidSelectToolbarButton:(IMToolbarButtonType)buttonType {
    switch (buttonType) {
        case IMToolbarButtonReactions:
            // Set classification for use in returning user to Reactions when closing a category
            self.imojiKeyboardView.currentCategoryClassification = IMImojiSessionCategoryClassificationGeneric;

            [self.imojiKeyboardView.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationGeneric];
            [self.imojiKeyboardView updateTitleWithText:@"REACTIONS" hideCloseButton:YES];
            break;
        case IMToolbarButtonTrending:
            // Set classification for use in returning user to Trending when closing a category
            self.imojiKeyboardView.currentCategoryClassification = IMImojiSessionCategoryClassificationTrending;

            [self.imojiKeyboardView.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationTrending];
            [self.imojiKeyboardView updateTitleWithText:@"TRENDING" hideCloseButton:YES];
            break;
        case IMToolbarButtonArtist:
            // Set classification for use in returning user to Artist when closing a category
            self.imojiKeyboardView.currentCategoryClassification = IMImojiSessionCategoryClassificationArtist;

            [self.imojiKeyboardView.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationArtist];
            [self.imojiKeyboardView updateTitleWithText:@"ARTIST" hideCloseButton:YES];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.messageThreadView.collectionViewLayout invalidateLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.messageThreadView.collectionViewLayout invalidateLayout];
}

@end
