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
#import <ImojiSDKUI/IMSearchView.h>
#import <ImojiSDKUI/IMSuggestionView.h>
#import <ImojiSDKUI/IMToolbar.h>
#import <Masonry/View+MASAdditions.h>
#import <Masonry/ViewController+MASAdditions.h>

CGFloat const SuggestionViewBarHeight = 91.f;
CGFloat const InputBarHeight = 50.f;
CGFloat const InputFieldPadding = 5.f;
CGFloat const InitialImojiKeyboardViewHeight = 240.f;
CGFloat const SuggestionFieldBorderHeight = 1.f;
CGFloat const InputFieldLeftOffset = 15.f;
CGFloat const InputFieldRightOffset = 9.f;
@interface ViewController () </*UITextFieldDelegate*/IMSearchViewDelegate, IMKeyboardViewDelegate, IMKeyboardCollectionViewDelegate, IMToolbarDelegate>

@property(nonatomic, strong) MessageThreadView *messageThreadView;
//@property(nonatomic, strong) UITextField *inputField;
@property(nonatomic, strong) IMSearchView *inputFieldView;
@property(nonatomic, strong) UIView *inputFieldContainer;
//@property(nonatomic, strong) UIButton *actionButton;
//@property(nonatomic, strong) UIButton *sendButton;
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

    // this essentially sets the status bar color since the view takes up the full screen
    // and the subviews are positioned below the status bar
    self.view.backgroundColor = [UIColor colorWithRed:248.0f / 255.0f green:248.0f / 255.0f blue:248.0f / 255.0f alpha:1.0f];

    // Message Thread View Setup
    self.messageThreadView = [[MessageThreadView alloc] init];
    self.messageThreadView.backgroundColor = [UIColor whiteColor];
    [self.messageThreadView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageThreadViewTapped)]];

    // Input Field Setup
    self.inputFieldView = [IMSearchView imojiSearchView];
    self.imojiSuggestionView.layer.borderColor = [UIColor colorWithWhite:207.f / 255.f alpha:1.f].CGColor;
    self.imojiSuggestionView.layer.borderWidth = 1.f;
    self.inputFieldView.backgroundColor = [UIColor clearColor];
    self.inputFieldView.searchTextField.returnKeyType = UIReturnKeySend;
    self.inputFieldView.delegate = self;

    // Input Field Container Setup
    self.inputFieldContainer = [[UIView alloc] init];
    self.inputFieldContainer.backgroundColor = [UIColor whiteColor];

    // Imoji Keyboard View Setup
    self.imojiKeyboardView = [IMKeyboardView imojiKeyboardViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
    self.imojiKeyboardView.backgroundColor = self.view.backgroundColor;
    self.imojiKeyboardView.collectionView.backgroundColor = [UIColor clearColor];
    self.imojiKeyboardView.collectionView.preferredImojiDisplaySize = CGSizeMake(80.f, 80.f);
    self.imojiKeyboardView.collectionView.collectionViewDelegate = self;
    self.imojiKeyboardView.delegate = self;
    self.imojiKeyboardView.keyboardToolbar.delegate = self;

    // Modify keyboard toolbar
    NSBundle *imageBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"ImojiKeyboardAssets" ofType:@"bundle"]];
    IMToolbar *messagingToolbar = [[IMToolbar alloc] init];
    [messagingToolbar addToolbarButtonWithType:IMToolbarButtonTrending
                                         image:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_trending.png", imageBundle.bundlePath]]
                                   activeImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_trending_active.png", imageBundle.bundlePath]]
    ];

    [messagingToolbar addToolbarButtonWithType:IMToolbarButtonReactions
                                         image:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_reactions.png", imageBundle.bundlePath]]
                                   activeImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_reactions_active.png", imageBundle.bundlePath]]
    ];

    [messagingToolbar addToolbarButtonWithType:IMToolbarButtonArtist
                                         image:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_artist.png", imageBundle.bundlePath]]
                                   activeImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/keyboard_artist_active.png", imageBundle.bundlePath]]
    ];
    [self.imojiKeyboardView.keyboardToolbar setItems:messagingToolbar.items];

    // Imoji Suggestion View Setup
    self.imojiSuggestionView = [IMSuggestionView imojiSuggestionViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
    self.imojiSuggestionView.backgroundColor = self.view.backgroundColor;
    self.imojiSuggestionView.layer.borderColor = [UIColor colorWithWhite:207.f / 255.f alpha:1.f].CGColor;
    self.imojiSuggestionView.layer.borderWidth = 1.f;
    self.imojiSuggestionView.clipsToBounds = NO;
//    self.imojiSuggestionView.hidden = YES;
    self.imojiSuggestionView.collectionView.backgroundColor = [UIColor clearColor];
    self.imojiSuggestionView.collectionView.preferredImojiDisplaySize = CGSizeMake(74.f, 86.f);
    self.imojiSuggestionView.collectionView.collectionViewDelegate = self;

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
    [self.inputFieldContainer addSubview:self.inputFieldView];

    [self.inputFieldView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@26.0f);
        make.centerY.equalTo(self.inputFieldContainer);
        make.left.equalTo(self.inputFieldContainer).offset(InputFieldLeftOffset);
        make.right.equalTo(self.inputFieldContainer).offset(-InputFieldRightOffset);
    }];

    [self.imojiKeyboardView.keyboardToolbar selectButtonOfType:IMToolbarButtonTrending];
}

#pragma mark Text View Delegates

- (void)userDidPressReturnKeySearchView:(IMSearchView *)searchView {
    [self sendText];
}

- (void)userDidChangeTextFieldFromSearchView:(IMSearchView *)searchView {
    [self.imojiSuggestionView.collectionView loadImojisFromSentence:self.inputFieldView.searchTextField.text];
    BOOL hasText = self.inputFieldView.searchTextField.text.length > 0;

    if (!hasText) {
        [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
    }
}

- (void)userShouldBeginSearchFromSearchView:(IMSearchView *)searchView {
    [self hideImojiKeyboardAnimated];
}

- (void)sendText {
    if (self.inputFieldView.searchTextField.text.length > 0) {
        [self.messageThreadView sendMessageWithText:self.inputFieldView.searchTextField.text];
    }

    if(![self.inputFieldView.searchTextField.text isEqualToString:@""] &&
       [self.inputFieldView canPerformAction:@selector(clearButtonTapped:) withSender:self.inputFieldView.searchTextField.rightView]) {
        [self.inputFieldView performSelector:@selector(clearButtonTapped:) withObject:self.inputFieldView.searchTextField.rightView];
    }
}

- (void)showImojiKeyboardAnimated {
    if (self.isImojiKeyboardViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

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

    if (shouldMoveInputField) {
        [UIView animateWithDuration:.7f
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.2f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                                     InitialImojiKeyboardViewHeight + self.inputFieldContainer.frame.size.height,
                                     0
                             );
                             self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                                     InitialImojiKeyboardViewHeight + self.inputFieldContainer.frame.size.height,
                                     0
                             );
                         }
        ];
    } else {
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0.0 animations:^{
            [self.inputFieldView.searchTextField resignFirstResponder];
        }];
    }
}

- (void)hideImojiKeyboardAnimated {
    if (!self.isImojiKeyboardViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    [self.imojiKeyboardView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.imojiKeyboardView.collectionView.collectionViewLayout invalidateLayout];
    [self.view layoutIfNeeded];

    [UIView animateWithDuration:0.0 animations:^{
        [self.inputFieldView.searchTextField becomeFirstResponder];
    }];
}

- (BOOL)isImojiKeyboardViewDisplayed {
    return self.imojiKeyboardView.frame.origin.y + self.imojiKeyboardView.frame.size.height == self.view.frame.size.height;
}

- (BOOL)isImojiKeyboardViewUsingInitialHeight {
    return self.imojiKeyboardView.frame.size.height == InitialImojiKeyboardViewHeight;
}

#pragma mark Suggestion View

- (void)showSuggestionsAnimated:(BOOL)animated {
    if (self.isSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

//    self.imojiSuggestionView.hidden = NO;

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(SuggestionViewBarHeight));
        make.bottom.equalTo(self.inputFieldContainer.mas_top).offset(SuggestionFieldBorderHeight);
    }];

    if (animated) {
        [UIView animateWithDuration:.7f
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.2f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                                     self.messageThreadView.scrollIndicatorInsets.bottom + self.imojiSuggestionView.frame.size.height,
                                     0
                             );
                             self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                                     self.messageThreadView.contentInset.bottom + self.imojiSuggestionView.frame.size.height,
                                     0
                             );
                        }
        ];
    }
}

- (void)hideSuggestionsAnimated:(BOOL)animated {
    if (!self.isSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(SuggestionViewBarHeight));
        make.top.equalTo(self.inputFieldContainer.mas_top).offset(-SuggestionFieldBorderHeight);
    }];

    if (animated) {
        [UIView animateWithDuration:.7f
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.2f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                                     self.messageThreadView.scrollIndicatorInsets.bottom - self.imojiSuggestionView.frame.size.height,
                                     0
                             );
                             self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                                     self.messageThreadView.contentInset.bottom - self.imojiSuggestionView.frame.size.height,
                                     0
                             );
//                             self.imojiSuggestionView.hidden = YES;
                         }
        ];

    } else {
//        self.imojiSuggestionView.hidden = YES;
    }

    [self.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];
}

- (BOOL)isSuggestionViewDisplayed {
    return (self.imojiSuggestionView.frame.origin.y + SuggestionFieldBorderHeight) != self.inputFieldContainer.frame.origin.y;
}

#pragma mark IMKeyboardViewDelegate

- (void)userDidCloseCategoryFromView:(IMKeyboardView *)view {
    [view.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:view.currentCategoryClassification]];
}

#pragma mark Imoji Collection View Delegate

- (void)userDidSelectImoji:(nonnull IMImojiObject *)imoji fromCollectionView:(nonnull IMCollectionView *)collectionView {
    [self.messageThreadView sendMessageWithImoji:imoji];
}

- (void)userDidSelectCategory:(nonnull IMImojiCategoryObject *)category fromCollectionView:(nonnull IMCollectionView *)collectionView {
//    if (self.isImojiKeyboardViewDisplayed) {
        [self.imojiKeyboardView updateTitleWithText:category.title hideCloseButton:NO];
    [self.imojiKeyboardView.collectionView loadImojisFromCategory:category];
    [self showImojiKeyboardAnimated];
    [self hideSuggestionsAnimated:YES];
//    }

//    [collectionView loadImojisFromCategory:category];
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
    [self hideImojiKeyboardAnimated];
    [self hideSuggestionsAnimated:NO];
    [self.inputFieldView.searchTextField resignFirstResponder];
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

    if (self.isImojiKeyboardViewDisplayed) {
        [self hideImojiKeyboardAnimated];
    }

    if (self.inputFieldView.searchTextField.text.length > 0 && !self.isSuggestionViewDisplayed) {
        [self showSuggestionsAnimated:NO];
    } else {
        [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
        [self showSuggestionsAnimated:YES];
    }

    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurve
                     animations:^{
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                                 endRect.size.height + self.inputFieldContainer.frame.size.height +
                                 (self.isSuggestionViewDisplayed ? self.imojiSuggestionView.frame.size.height : 0),
                                 0
                         );
                         self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                                 endRect.size.height + self.inputFieldContainer.frame.size.height +
                                 (self.isSuggestionViewDisplayed ? self.imojiSuggestionView.frame.size.height : 0),
                                 0
                         );

                         if (self.messageThreadView.empty) {
                             [self.messageThreadView.collectionViewLayout invalidateLayout];
                         } else {
                             [self.messageThreadView scrollToBottom];
                         }
                     }
    ];
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
                         [self.view layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                                 self.inputFieldContainer.frame.size.height,
                                 0
                         );

                         self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                                 self.inputFieldContainer.frame.size.height,
                                 0
                         );

                         if (self.messageThreadView.empty) {
                             [self.messageThreadView.collectionViewLayout invalidateLayout];
                         }
                     }
    ];
}

#pragma mark IMToolBarDelegate
- (void)userDidSelectToolbarButton:(IMToolbarButtonType)buttonType {
    switch (buttonType) {
        case IMToolbarButtonReactions:
            // Set classification for use in returning user to Reactions when closing a category
            self.imojiKeyboardView.currentCategoryClassification = IMImojiSessionCategoryClassificationGeneric;

            [self.imojiKeyboardView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationGeneric]];
            [self.imojiKeyboardView updateTitleWithText:@"REACTIONS" hideCloseButton:YES];
            break;
        case IMToolbarButtonTrending:
            // Set classification for use in returning user to Trending when closing a category
            self.imojiKeyboardView.currentCategoryClassification = IMImojiSessionCategoryClassificationTrending;

            [self.imojiKeyboardView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
            [self.imojiKeyboardView updateTitleWithText:@"TRENDING" hideCloseButton:YES];
            break;
        case IMToolbarButtonArtist:
            // Set classification for use in returning user to Artist when closing a category
            self.imojiKeyboardView.currentCategoryClassification = IMImojiSessionCategoryClassificationArtist;

            [self.imojiKeyboardView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationArtist]];
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
