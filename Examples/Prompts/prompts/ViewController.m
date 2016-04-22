//
//  ViewController.m
//  prompts
//
//  Created by Nima on 10/9/15.
//  Copyright © 2015 Imoji. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MessageThreadView.h"
#import <ImojiSDKUI/IMCollectionView.h>
#import <ImojiSDKUI/IMSuggestionView.h>
#import <ImojiSDKUI/IMSearchView.h>
#import <Masonry/Masonry.h>

CGFloat const SuggestionViewBarHeight = 101.f;
CGFloat const InputBarHeight = 44.f;
CGFloat const InputFieldLeftOffset = 15.f;
CGFloat const InputFieldRightOffset = 9.f;
CGFloat const SuggestionFieldBorderHeight = 1.f;

@interface ViewController () </*UITextFieldDelegate*/IMSearchViewDelegate, IMCollectionViewDelegate>

@property(nonatomic, strong) MessageThreadView *messageThreadView;
@property(nonatomic, strong) IMSearchView *inputFieldView;
@property(nonatomic, strong) UIView *inputFieldContainer;
@property(nonatomic, strong) IMSuggestionView *imojiSuggestionView;

@end

@implementation ViewController


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

    self.messageThreadView = [MessageThreadView new];
    self.imojiSuggestionView = [IMSuggestionView imojiSuggestionViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
    self.inputFieldContainer = [UIView new];

    self.inputFieldView = [IMSearchView imojiSearchView];
    self.inputFieldView.backgroundColor = [UIColor clearColor];
    self.inputFieldView.searchTextField.returnKeyType = UIReturnKeySend;
    self.inputFieldView.delegate = self;
    self.inputFieldView.searchTextField.delegate = self;

    // this essentially sets the status bar color since the view takes up the full screen
    // and the subviews are positioned below the status bar
    self.view.backgroundColor =
            [UIColor colorWithRed:248.0f / 255.0f green:248.0f / 255.0f blue:248.0f / 255.0f alpha:1.0f];
    self.inputFieldContainer.backgroundColor = [UIColor whiteColor];
    self.imojiSuggestionView.layer.borderColor = [UIColor colorWithWhite:207.f / 255.f alpha:1.f].CGColor;
    self.imojiSuggestionView.layer.borderWidth = 1.f;
    self.messageThreadView.backgroundColor = [UIColor whiteColor];
    self.imojiSuggestionView.backgroundColor = self.view.backgroundColor;
    self.imojiSuggestionView.collectionView.backgroundColor = [UIColor clearColor];

    [self.messageThreadView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageThreadViewTapped)]];

    self.imojiSuggestionView.collectionView.collectionViewDelegate = self;
    self.imojiSuggestionView.collectionView.preferredImojiDisplaySize = CGSizeMake(80.f, 80.f);

    [self.view addSubview:self.messageThreadView];
    [self.view addSubview:self.imojiSuggestionView];
    [self.view addSubview:self.inputFieldContainer];

    [self.inputFieldContainer addSubview:self.inputFieldView];

    UIView *suggestionTopBorder = [UIView new];
    [self.imojiSuggestionView addSubview:suggestionTopBorder];

    [suggestionTopBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imojiSuggestionView).offset(-1);
        make.left.right.equalTo(self.imojiSuggestionView);
        make.height.equalTo(@1);
    }];
    suggestionTopBorder.backgroundColor = self.view.backgroundColor;
    self.imojiSuggestionView.clipsToBounds = NO;

    [self.messageThreadView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.view);
    }];

    [self.inputFieldView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@26.0f);
        make.centerY.equalTo(self.inputFieldContainer);
        make.left.equalTo(self.inputFieldContainer).offset(InputFieldLeftOffset);
        make.right.equalTo(self.inputFieldContainer).offset(-InputFieldRightOffset);
    }];

    [self.inputFieldContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(InputBarHeight));
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(SuggestionViewBarHeight));
        make.top.equalTo(self.inputFieldContainer.mas_top).offset(-SuggestionFieldBorderHeight);
    }];
}

#pragma mark Text View Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendText];
    return YES;
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

- (void)showSuggestionsAnimated:(BOOL)animated {
    if (self.isSuggestionViewDisplayed) {
        return;
    }

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

    if (animated) {
        [UIView animateWithDuration:.7f
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.2f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.imojiSuggestionView layoutIfNeeded];
                         } completion:nil];

    }
}

- (BOOL)isSuggestionViewDisplayed {
    return (self.imojiSuggestionView.frame.origin.y + SuggestionFieldBorderHeight) != self.inputFieldContainer.frame.origin.y;
}

#pragma mark Imoji Collection View Delegate

- (void)userDidSelectImoji:(nonnull IMImojiObject *)imoji fromCollectionView:(nonnull IMCollectionView *)collectionView {
    [self.messageThreadView sendMessageWithImoji:imoji];
}

- (void)userDidSelectCategory:(nonnull IMImojiCategoryObject *)category fromCollectionView:(nonnull IMCollectionView *)collectionView {
    [collectionView loadImojisFromCategory:category];
}

#pragma mark Keyboard Handling

- (void)messageThreadViewTapped {
    [self.inputFieldView.searchTextField resignFirstResponder];
}

- (void)inputFieldWillShow:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve =
            (UIViewAnimationOptions) ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16);

    [self.inputFieldContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(InputBarHeight));
        make.bottom.equalTo(self.view).offset(-endRect.size.height);
    }];

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
                         [self.inputFieldContainer layoutIfNeeded];
                         [self.imojiSuggestionView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                self.messageThreadView.scrollIndicatorInsets =
                        self.messageThreadView.contentInset =
                                UIEdgeInsetsMake(0, 0,
                                        endRect.size.height +
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
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve =
            (UIViewAnimationOptions) ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16);

    [self.inputFieldContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(InputBarHeight));
        make.bottom.equalTo(self.view).offset((self.view.frame.size.height - endRect.origin.y) * -1);
    }];
    [self hideSuggestionsAnimated:NO];

    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurve
                     animations:^{
                         [self.inputFieldContainer layoutIfNeeded];
                         [self.imojiSuggestionView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                self.messageThreadView.scrollIndicatorInsets =
                        self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                                self.inputFieldContainer.frame.size.height + self.imojiSuggestionView.frame.size.height,
                                0
                        );


                if (self.messageThreadView.empty) {
                    [self.messageThreadView.collectionViewLayout invalidateLayout];
                }

            }];
}

- (void)userDidChangeTextFieldFromSearchView:(IMSearchView *)searchView {
    [self.imojiSuggestionView.collectionView loadImojisFromSentence:self.inputFieldView.searchTextField.text];
    BOOL hasText = self.inputFieldView.searchTextField.text.length > 0;

    if (!hasText) {
        [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
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
