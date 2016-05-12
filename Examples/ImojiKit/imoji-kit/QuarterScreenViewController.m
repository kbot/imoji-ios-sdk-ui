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

#import "AppDelegate.h"
#import "QuarterScreenViewController.h"
#import "MessageThreadView.h"
#import "IMImojiCategoryObject.h"
#import <ImojiSDKUI/IMCollectionView.h>
#import <ImojiSDKUI/IMSuggestionView.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <ImojiSDKUI/IMSearchView.h>
#import <ImojiSDKUI/IMToolbar.h>
#import <Masonry/Masonry.h>

@interface QuarterScreenViewController () <IMCollectionViewDelegate, IMSearchViewDelegate, IMToolbarDelegate>

@property(nonatomic, strong) IMToolbar *topToolbar;
@property(nonatomic, strong) MessageThreadView *messageThreadView;
@property(nonatomic, strong) IMSearchView *searchView;
//@property(nonatomic, strong) UIView *searchViewContainer;
@property(nonatomic, strong) IMSuggestionView *imojiSuggestionView;

@end

@implementation QuarterScreenViewController


- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Quarter Screen";
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

    self.messageThreadView = [MessageThreadView new];
    self.messageThreadView.backgroundColor = [UIColor whiteColor];
    [self.messageThreadView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageThreadViewTapped)]];

    self.searchView = [IMSearchView imojiSearchView];
//    self.searchView.backgroundColor = [UIColor whiteColor];
    self.searchView.createAndRecentsEnabled = YES;
    self.searchView.searchViewScreenType = IMSearchViewScreenTypeQuarter;
    self.searchView.backButtonType = IMSearchViewBackButtonTypeDisabled;
    self.searchView.searchTextField.returnKeyType = UIReturnKeySend;
    self.searchView.delegate = self;

//    self.searchViewContainer = [[UIView alloc] init];
//    self.searchViewContainer.backgroundColor = [UIColor whiteColor];

    self.imojiSuggestionView = [IMSuggestionView imojiSuggestionViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
//    self.imojiSuggestionView.layer.borderColor = [UIColor colorWithWhite:207.f / 255.f alpha:1.f].CGColor;
//    self.imojiSuggestionView.layer.borderWidth = 1.f;
    self.imojiSuggestionView.clipsToBounds = NO;
    self.imojiSuggestionView.collectionView.preferredImojiDisplaySize = CGSizeMake(74.f, 91.f);
    self.imojiSuggestionView.collectionView.collectionViewDelegate = self;
    self.imojiSuggestionView.collectionView.infiniteScroll = YES;

    [self.view addSubview:self.topToolbar];
    [self.view addSubview:self.messageThreadView];
    [self.view addSubview:self.imojiSuggestionView];
    [self.view addSubview:self.searchView];

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

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight));
        make.top.equalTo(self.searchView.mas_top).offset(-IMSuggestionViewBorderHeight);
    }];

    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    UIView *suggestionTopBorder = [[UIView alloc] init];
    suggestionTopBorder.backgroundColor = [UIColor colorWithWhite:207.f / 255.f alpha:1.f];
    [self.imojiSuggestionView addSubview:suggestionTopBorder];

    [suggestionTopBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imojiSuggestionView).offset(-1);
        make.left.right.equalTo(self.imojiSuggestionView);
        make.height.equalTo(@1);
    }];

//    [self.searchViewContainer addSubview:self.searchView];
//
//    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.height.equalTo(@(IMSearchViewIconWidthHeight));
//        make.centerY.equalTo(self.searchViewContainer);
//        make.left.equalTo(self.searchViewContainer).offset(IMSearchViewContainerDefaultLeftOffset);
//        make.right.equalTo(self.searchViewContainer).offset(-IMSearchViewContainerDefaultRightOffset);
//    }];
}

#pragma mark IMSearchView Delegate

- (void)userDidChangeTextFieldFromSearchView:(IMSearchView *)searchView {
    BOOL hasText = self.searchView.searchTextField.text.length > 0;

    if (!hasText) {
        [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
    } else {
        [self.imojiSuggestionView.collectionView loadImojisFromSentence:self.searchView.searchTextField.text];
    }
}

- (void)userDidClearTextFieldFromSearchView:(IMSearchView *)searchView {
    [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
}

- (void)userDidPressReturnKeyFromSearchView:(IMSearchView *)searchView {
    [self sendText];
}

- (void)userDidTapCancelButtonFromSearchView:(IMSearchView *)searchView {
    [self hideSuggestionsAnimated:YES];
}

- (void)sendText {
    if (self.searchView.searchTextField.text.length > 0) {
        [self.messageThreadView sendMessageWithText:self.searchView.searchTextField.text];
    }

    if(![self.searchView.searchTextField.text isEqualToString:@""] &&
       [self.searchView canPerformAction:@selector(clearButtonTapped) withSender:self.searchView.searchTextField.rightView]) {
        [self.searchView performSelector:@selector(clearButtonTapped) withObject:self.searchView.searchTextField.rightView];
    }
}

#pragma mark IMSuggestionView

- (void)showSuggestionsAnimated:(BOOL)animated {
    if (self.isSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight));
        make.bottom.equalTo(self.searchView.mas_top).offset(IMSuggestionViewBorderHeight);
    }];

    [self.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];

    if (animated) {
        [UIView animateWithDuration:.7f
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.2f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:nil];
    }
}

- (void)hideSuggestionsAnimated:(BOOL)animated {
    if (!self.isSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight));
        make.top.equalTo(self.searchView.mas_top).offset(-IMSuggestionViewBorderHeight);
    }];

    if (animated) {
        [UIView animateWithDuration:.7f
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.2f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         } completion:nil];

    }

    [self.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];
}

- (BOOL)isSuggestionViewDisplayed {
    return (self.imojiSuggestionView.frame.origin.y + IMSuggestionViewBorderHeight) != self.searchView.frame.origin.y;
}

#pragma mark Imoji Collection View Delegate

- (void)userDidSelectImoji:(nonnull IMImojiObject *)imoji fromCollectionView:(nonnull IMCollectionView *)collectionView {
    [self.messageThreadView sendMessageWithImoji:imoji];
}

- (void)userDidSelectCategory:(nonnull IMImojiCategoryObject *)category fromCollectionView:(nonnull IMCollectionView *)collectionView {
    self.searchView.searchTextField.text = category.title;
    self.searchView.searchTextField.rightView.hidden = NO;
    [collectionView loadImojisFromCategory:category];
}

#pragma mark Keyboard Handling

- (void)messageThreadViewTapped {
    [self hideSuggestionsAnimated:YES];
    [self.searchView.searchTextField resignFirstResponder];
}

- (void)inputFieldWillShow:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve =
            (UIViewAnimationOptions) ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16);

    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self.view).offset(-endRect.size.height);
    }];

    if (!self.isSuggestionViewDisplayed) {
        if (self.searchView.searchTextField.text.length > 0) {
            [self showSuggestionsAnimated:YES];
        } else {
            [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
            [self showSuggestionsAnimated:NO];
        }
    }

    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^{
        [self.view layoutIfNeeded];
//                         [self.imojiSuggestionView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets =
                self.messageThreadView.contentInset =
                        UIEdgeInsetsMake(0, 0,
                                endRect.size.height +
                                        self.searchView.frame.size.height + self.imojiSuggestionView.frame.size.height,
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

    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self.view).offset((self.view.frame.size.height - endRect.origin.y) * -1);
    }];
//    [self hideSuggestionsAnimated:NO];

    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^{
        [self.view layoutIfNeeded];
//                         [self.imojiSuggestionView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets =
                self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                        self.searchView.frame.size.height + self.imojiSuggestionView.frame.size.height,
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
