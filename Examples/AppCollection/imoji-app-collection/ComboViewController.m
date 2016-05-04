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
#import "ComboViewController.h"
#import "MessageThreadView.h"
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMCollectionView.h>
#import <ImojiSDKUI/IMKeyboardView.h>
#import <ImojiSDKUI/IMKeyboardCollectionView.h>
#import <ImojiSDKUI/IMResourceBundleUtil.h>
#import <ImojiSDKUI/IMSearchView.h>
#import <ImojiSDKUI/IMSuggestionView.h>
#import <ImojiSDKUI/IMToolbar.h>
#import <Masonry/View+MASAdditions.h>
#import <Masonry/ViewController+MASAdditions.h>

@interface ComboViewController () <IMCollectionViewDelegate, IMSearchViewDelegate, IMToolbarDelegate>

@property(nonatomic, strong) IMToolbar *topToolbar;
@property(nonatomic, strong) MessageThreadView *messageThreadView;
@property(nonatomic, strong) IMSearchView *searchView;
@property(nonatomic, strong) UIView *searchViewContainer;
@property(nonatomic, strong) IMSuggestionView *imojiSuggestionView;
@property(nonatomic) BOOL imojiSearchViewActionTapped;
@property(nonatomic) BOOL halfScreenSuggestionViewDisplayed;
@property(nonatomic) BOOL quarterScreenSuggestionViewDisplayed;

@end

@implementation ComboViewController {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Combo Screen";
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

    // Message Thread View Setup
    self.messageThreadView = [[MessageThreadView alloc] init];
    self.messageThreadView.backgroundColor = [UIColor whiteColor];
    [self.messageThreadView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageThreadViewTapped)]];

    // Input Field Setup
    self.searchView = [IMSearchView imojiSearchView];
    self.searchView.backgroundColor = [UIColor clearColor];
    self.searchView.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchView.delegate = self;

    // Input Field Container Setup
    self.searchViewContainer = [[UIView alloc] init];
    self.searchViewContainer.backgroundColor = [UIColor whiteColor];

    // Imoji Suggestion View Setup
    self.imojiSuggestionView = [IMSuggestionView imojiSuggestionViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
    self.imojiSuggestionView.layer.borderColor = [UIColor colorWithWhite:207.f / 255.f alpha:1.f].CGColor;
    self.imojiSuggestionView.layer.borderWidth = 1.f;
    self.imojiSuggestionView.clipsToBounds = NO;
//    self.imojiSuggestionView.hidden = YES;
    self.imojiSuggestionView.collectionView.preferredImojiDisplaySize = CGSizeMake(74.f, 91.f);
    self.imojiSuggestionView.collectionView.infiniteScroll = YES;
    self.imojiSuggestionView.collectionView.collectionViewDelegate = self;

    // Subviews
    [self.view addSubview:self.topToolbar];
    [self.view addSubview:self.messageThreadView];
    [self.view addSubview:self.imojiSuggestionView];
    [self.view addSubview:self.searchViewContainer];

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
        make.top.equalTo(self.searchViewContainer.mas_top).offset(-IMSuggestionViewBorderHeight);
    }];

    [self.searchViewContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
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
    [self.searchViewContainer addSubview:self.searchView];

    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(IMSearchViewIconWidthHeight));
        make.centerY.equalTo(self.searchViewContainer);
        make.left.equalTo(self.searchViewContainer).offset(IMSearchViewDefaultLeftOffset);
        make.right.equalTo(self.searchViewContainer).offset(-IMSearchViewDefaultRightOffset);
    }];
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

- (void)userDidPressReturnKeyFromSearchView:(IMSearchView *)searchView {
//    [self sendText];
    self.imojiSearchViewActionTapped = YES;
    [self.searchView.searchTextField resignFirstResponder];

    [self showHalfScreenSuggestionViewAnimated];
}

- (void)userDidTapCancelButtonFromSearchView:(IMSearchView *)searchView {
    self.imojiSearchViewActionTapped = YES;
    [self showHalfScreenSuggestionViewAnimated];
}


- (void)sendText {
    if (self.searchView.searchTextField.text.length > 0) {
        [self.messageThreadView sendMessageWithText:self.searchView.searchTextField.text];
    }

    if(![self.searchView.searchTextField.text isEqualToString:@""] &&
            [self.searchView canPerformAction:@selector(clearButtonTapped:) withSender:self.searchView.searchTextField.rightView]) {
        [self.searchView performSelector:@selector(clearButtonTapped:) withObject:self.searchView.searchTextField.rightView];
    }
}

#pragma mark IMSuggestionView

- (void)showQuarterScreenSuggestionViewAnimated:(BOOL)animated {
    if (self.quarterScreenSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    self.quarterScreenSuggestionViewDisplayed = YES;
    self.halfScreenSuggestionViewDisplayed = NO;
//    self.imojiSuggestionView.hidden = NO;

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight));
        make.bottom.equalTo(self.searchViewContainer.mas_top).offset(IMSuggestionViewBorderHeight);
    }];

    if (animated) {
        [UIView animateWithDuration:.7f delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.2f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
//            self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
//                    self.messageThreadView.scrollIndicatorInsets.bottom + self.imojiSuggestionView.frame.size.height,
//                    0
//            );
//            self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
//                    self.messageThreadView.contentInset.bottom + self.imojiSuggestionView.frame.size.height,
//                    0
//            );
        }];
    }
}

- (void)showHalfScreenSuggestionViewAnimated {
    if (self.halfScreenSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    [self.searchViewContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self.view).offset(-IMSuggestionViewDefaultHeight * 2.0f);
    }];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.searchViewContainer.mas_bottom);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight * 2.0f));
//        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [UIView animateWithDuration:.7f delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.view layoutIfNeeded];
        [self.searchView.searchTextField resignFirstResponder];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                2.0f * IMSuggestionViewDefaultHeight + self.searchViewContainer.frame.size.height,
                0
        );
        self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                2.0f * IMSuggestionViewDefaultHeight + self.searchViewContainer.frame.size.height,
                0
        );

        self.halfScreenSuggestionViewDisplayed = YES;
        self.quarterScreenSuggestionViewDisplayed = NO;
    }];
}

//- (void)hideHalfScreenSuggestionViewAnimated {
//    if (!self.halfScreenSuggestionViewDisplayed) {
//        return;
//    }
//
//    [self.view layoutIfNeeded];
//
//    self.halfScreenSuggestionViewDisplayed = NO;
//
//    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.view);
//        make.top.equalTo(self.mas_bottomLayoutGuideTop);
//        make.height.equalTo(@(IMSearchViewContainerDefaultHeight * 2.0f));
//    }];
//
//    [self.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];
//    [self.view layoutIfNeeded];
//
//    [UIView animateWithDuration:0.0 animations:^{
//        [self.searchView.searchTextField becomeFirstResponder];
//    }];
//}

- (void)hideSuggestionsAnimated:(BOOL)animated {
    if (!self.quarterScreenSuggestionViewDisplayed && !self.halfScreenSuggestionViewDisplayed) {
        return;
    }

    [self.view layoutIfNeeded];

    if (self.halfScreenSuggestionViewDisplayed) {
        [self.searchViewContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
            make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        }];
    }

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight));
        make.top.equalTo(self.searchViewContainer.mas_top).offset(-IMSuggestionViewBorderHeight);
    }];

    if (animated) {
        [UIView animateWithDuration:.7f delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (self.halfScreenSuggestionViewDisplayed) {
                self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                        self.messageThreadView.scrollIndicatorInsets.bottom - 2.0f * self.imojiSuggestionView.frame.size.height,
                        0
                );
                self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                        self.messageThreadView.contentInset.bottom - 2.0f * self.imojiSuggestionView.frame.size.height,
                        0
                );

                if (self.messageThreadView.empty) {
                    [self.messageThreadView.collectionViewLayout invalidateLayout];
                } else {
                    [self.messageThreadView scrollToBottom];
                }

                self.quarterScreenSuggestionViewDisplayed = NO;
                self.halfScreenSuggestionViewDisplayed = NO;
            }
//            self.imojiSuggestionView.hidden = YES;
        }];
    } else {
//        self.imojiSuggestionView.hidden = YES;
        self.quarterScreenSuggestionViewDisplayed = NO;
        self.halfScreenSuggestionViewDisplayed = NO;
    }

    [self.imojiSuggestionView.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark Imoji Collection View Delegate

- (void)userDidSelectImoji:(nonnull IMImojiObject *)imoji fromCollectionView:(nonnull IMCollectionView *)collectionView {
    [self.messageThreadView sendMessageWithImoji:imoji];
}

- (void)userDidSelectCategory:(nonnull IMImojiCategoryObject *)category fromCollectionView:(nonnull IMCollectionView *)collectionView {
    self.searchView.searchTextField.text = category.title;
    self.searchView.searchTextField.rightView.hidden = NO;
    self.imojiSearchViewActionTapped = YES;

    [self showHalfScreenSuggestionViewAnimated];

    [collectionView loadImojisFromCategory:category];
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
    [self hideSuggestionsAnimated:self.halfScreenSuggestionViewDisplayed];
    [self.searchView.searchTextField resignFirstResponder];
}

- (void)inputFieldWillShow:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve =
            (UIViewAnimationOptions) ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16);

    [self.searchViewContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
        make.bottom.equalTo(self.view).offset(-endRect.size.height);
    }];

    if (!self.quarterScreenSuggestionViewDisplayed) {
        if (self.searchView.searchTextField.text.length > 0) {
            [self showQuarterScreenSuggestionViewAnimated:YES];
        } else {
            [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
            [self showQuarterScreenSuggestionViewAnimated:NO];
        }
    }

    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                endRect.size.height + self.searchViewContainer.frame.size.height +
                        (self.quarterScreenSuggestionViewDisplayed ? self.imojiSuggestionView.frame.size.height : 0),
                0
        );
        self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                endRect.size.height + self.searchViewContainer.frame.size.height +
                        (self.quarterScreenSuggestionViewDisplayed ? self.imojiSuggestionView.frame.size.height : 0),
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

    if(!self.imojiSearchViewActionTapped) {
        [self.searchViewContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
            make.bottom.equalTo(self.view).offset((self.view.frame.size.height - endRect.origin.y) * -1);
        }];
    }

    [UIView animateWithDuration:animationDuration delay:0.0 options:animationCurve animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.messageThreadView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0,
                self.halfScreenSuggestionViewDisplayed ? 0.0f : self.searchViewContainer.frame.size.height,
                0
        );

        self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0,
                self.halfScreenSuggestionViewDisplayed ? 0.0f : self.searchViewContainer.frame.size.height,
                0
        );

        if (self.messageThreadView.empty) {
            [self.messageThreadView.collectionViewLayout invalidateLayout];
        } else {
            [self.messageThreadView scrollToBottom];
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
