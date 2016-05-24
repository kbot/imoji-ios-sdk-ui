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
#import <ImojiSDKUI/IMQuarterScreenView.h>
#import <ImojiSDK/IMImojiObject.h>
#import <ImojiSDKUI/IMCreateImojiViewController.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <ImojiSDKUI/IMToolbar.h>
#import <Masonry/Masonry.h>

@interface QuarterScreenViewController () <IMCollectionViewDelegate, IMSearchViewDelegate, IMToolbarDelegate, IMStickerSearchContainerViewDelegate>

@property(nonatomic, strong) IMToolbar *topToolbar;
@property(nonatomic, strong) MessageThreadView *messageThreadView;
@property(nonatomic, strong) IMQuarterScreenView *quarterScreenView;
@property(nonatomic) BOOL suggestionViewDisplayed;

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

    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:((AppDelegate *)[UIApplication sharedApplication].delegate).appGroup];
    self.quarterScreenView = [IMQuarterScreenView imojiStickerSearchContainerViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
    self.quarterScreenView.searchView.createAndRecentsEnabled = [shared boolForKey:@"createAndRecents"];
    self.quarterScreenView.imojiSuggestionView.collectionView.renderingOptions.borderStyle = (IMImojiObjectBorderStyle) [shared integerForKey:@"stickerBorders"];
    self.quarterScreenView.delegate = self;

    [self.view addSubview:self.topToolbar];
    [self.view addSubview:self.messageThreadView];
    [self.view addSubview:self.quarterScreenView];

    [self.topToolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@44.0f);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
    }];

    [self.messageThreadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topToolbar.mas_bottom);
        make.bottom.equalTo(self.view);
    }];

    [self.quarterScreenView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.quarterScreenView.searchView.searchTextField becomeFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark IMSearchView Delegate

- (void)userDidPressReturnKeyFromSearchView:(IMSearchView *)searchView {
    [self sendText];
}

- (void)userDidTapCancelButtonFromSearchView:(IMSearchView *)searchView {
    [self hideSuggestionsAnimated:YES];
}

- (void)userDidTapRecentsButtonFromSearchView:(IMSearchView *)searchView {
    [self showSuggestionsAnimated:YES];
}

- (void)sendText {
    if (self.quarterScreenView.searchView.searchTextField.text.length > 0) {
        [self.messageThreadView sendMessageWithText:self.quarterScreenView.searchView.searchTextField.text];
        [self.quarterScreenView.searchView resetSearchView];
        [self.quarterScreenView.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
    }
}

#pragma mark IMSuggestionView

- (void)showSuggestionsAnimated:(BOOL)animated {
    if (self.suggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    [self.quarterScreenView.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight));
        make.bottom.equalTo(self.quarterScreenView.searchView.mas_top).offset(IMSuggestionViewBorderHeight);
    }];

    [self.quarterScreenView.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];

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

    self.suggestionViewDisplayed = YES;
}

- (void)hideSuggestionsAnimated:(BOOL)animated {
    if (!self.suggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    [self.quarterScreenView.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight));
        make.top.equalTo(self.quarterScreenView.searchView.mas_top).offset(-IMSuggestionViewBorderHeight);
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

    [self.quarterScreenView.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];

    self.suggestionViewDisplayed = NO;
}

#pragma mark Imoji Collection View Delegate

- (void)userDidSelectImoji:(nonnull IMImojiObject *)imoji fromCollectionView:(nonnull IMCollectionView *)collectionView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [((AppDelegate *)[UIApplication sharedApplication].delegate).session markImojiUsageWithIdentifier:imoji.identifier originIdentifier:@"imoji kit quarter: imoji selected"];
    });

    [self.messageThreadView sendMessageWithImoji:imoji];
}

#pragma mark Keyboard Handling

- (void)messageThreadViewTapped {
    [self hideSuggestionsAnimated:YES];
    [self.quarterScreenView.searchView.searchTextField resignFirstResponder];
}

- (void)inputFieldWillShow:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve =
            (UIViewAnimationOptions) ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16);

    [self.quarterScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight + IMSuggestionViewDefaultHeight));
        make.bottom.equalTo(self.view).offset(-endRect.size.height);
    }];

    if (!self.suggestionViewDisplayed) {
        if (self.quarterScreenView.searchView.searchTextField.text.length > 0) {
            [self showSuggestionsAnimated:YES];
        } else {
            [self.quarterScreenView.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
            [self showSuggestionsAnimated:NO];
        }
    }

    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                endRect.size.height + self.quarterScreenView.searchView.frame.size.height + self.quarterScreenView.imojiSuggestionView.frame.size.height,
                0
        );
        self.messageThreadView.contentInset = self.messageThreadView.scrollIndicatorInsets;

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

    [self.quarterScreenView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self.view).offset((self.view.frame.size.height - endRect.origin.y) * -1);
    }];

    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.quarterScreenView.searchView.frame.size.height, 0);
        self.messageThreadView.contentInset = self.messageThreadView.scrollIndicatorInsets;

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
