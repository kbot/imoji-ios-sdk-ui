//
//  ViewController.m
//  messaging
//
//  Created by Nima on 10/9/15.
//  Copyright © 2015 Imoji. All rights reserved.
//

#import "ViewController.h"
#import "MessageThreadView.h"
#import "ImojiSuggestionView.h"
#import "IMCollectionView.h"
#import "Message.h"
#import "View+MASAdditions.h"
#import "ViewController+MASAdditions.h"
#import "IMAttributeStringUtil.h"
#import "AppDelegate.h"

@interface ViewController () <UITextFieldDelegate, IMCollectionViewDelegate>

@property(nonatomic, strong) MessageThreadView *messageThreadView;
@property(nonatomic, strong) UITextField *inputField;
@property(nonatomic, strong) UIView *inputFieldContainer;
@property(nonatomic, strong) ImojiSuggestionView *imojiSuggestionView;

@property(nonatomic, strong) IMImojiSession *imojiSession;
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];

    self.imojiSession = ((AppDelegate *) [UIApplication sharedApplication].delegate).session;

    self.messageThreadView = [MessageThreadView new];
    self.inputField = [UITextField new];
    self.imojiSuggestionView = [ImojiSuggestionView new];
    self.inputFieldContainer = [UIView new];

    self.inputField.delegate = self;

    self.inputField.layer.cornerRadius = 4.f;
    self.inputField.layer.borderColor = [UIColor colorWithWhite:.75f alpha:1.f].CGColor;
    self.inputField.backgroundColor = [UIColor colorWithWhite:1.f alpha:.9f];
    self.inputField.returnKeyType = UIReturnKeySend;
    self.inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.inputField.defaultTextAttributes = @{
            NSFontAttributeName: [IMAttributeStringUtil defaultFontWithSize:16.f],
            NSForegroundColorAttributeName: [UIColor colorWithWhite:.2f alpha:1.f]
    };
    // text indent
    self.inputField.leftView = [UIView new];
    self.inputField.leftView.frame = CGRectMake(0, 0, 5.f, 5.f);
    self.inputField.leftViewMode = UITextFieldViewModeAlways;

    // this essentially sets the status bar color since the view takes up the full screen
    // and the subviews are positioned below the status bar
    self.view.backgroundColor =
            [UIColor colorWithRed:55.0f / 255.0f green:123.0f / 255.0f blue:167.0f / 255.0f alpha:1.0f];
    self.inputFieldContainer.backgroundColor = self.view.backgroundColor;
    self.messageThreadView.backgroundColor = [UIColor colorWithWhite:235 / 255.f alpha:1.f];
    self.imojiSuggestionView.backgroundColor = self.view.backgroundColor;
    self.imojiSuggestionView.collectionView.backgroundColor = [UIColor clearColor];

    self.imojiSuggestionView.collectionView.collectionViewDelegate = self;
    self.imojiSuggestionView.collectionView.preferredImojiDisplaySize = CGSizeMake(50.f, 50.f);

    [self.view addSubview:self.messageThreadView];
    [self.view addSubview:self.imojiSuggestionView];
    [self.view addSubview:self.inputFieldContainer];
    [self.inputFieldContainer addSubview:self.inputField];

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

    [self.inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.inputFieldContainer).insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];

    [self.inputFieldContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@50);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@55);
        make.top.equalTo(self.inputFieldContainer.mas_top);
    }];
}

#pragma mark Text View Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [self sendMessageWithText:textField.text];
    }

    textField.text = @"";

    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    [self.imojiSuggestionView.collectionView loadImojisFromSentence:self.inputField.text];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@55);
        make.bottom.equalTo(self.inputFieldContainer.mas_top);
    }];

    [self showSuggestionsAnimated:YES];
}

- (void)showSuggestionsAnimated:(BOOL)animated {
    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@55);
        make.bottom.equalTo(self.inputFieldContainer.mas_top);
    }];

    if (animated) {
        [UIView animateWithDuration:1.0f
                              delay:0
             usingSpringWithDamping:.8f
              initialSpringVelocity:1.2f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.imojiSuggestionView layoutIfNeeded];
                         } completion:nil];
    }
}

- (void)hideSuggestionsAnimated:(BOOL)animated {
    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@55);
        make.top.equalTo(self.inputFieldContainer.mas_top);
    }];

    if (animated) {
        [UIView animateWithDuration:1.0f
                              delay:0
             usingSpringWithDamping:.8f
              initialSpringVelocity:1.2f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [self.imojiSuggestionView layoutIfNeeded];
                         } completion:nil];

    }
}

#pragma mark Imoji Collection View Delegate

- (void)userDidSelectImoji:(nonnull IMImojiObject *)imoji fromCollectionView:(nonnull IMCollectionView *)collectionView {
    [self sendMessageWithImoji:imoji];
}

#pragma mark Keyboard Handling


- (void)inputFieldWillShow:(NSNotification *)notification {
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
        make.height.equalTo(@50);
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
            }];
}

#pragma mark View controller overrides

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark Sending Messages (Fake)

- (void)sendMessageWithText:(nonnull NSString *)text {
    [self.messageThreadView appendMessage:[Message messageWithText:[[NSAttributedString alloc] initWithString:text] sender:YES]];
    [self sendFakeResponse];
}

- (void)sendMessageWithImoji:(nonnull IMImojiObject *)imoji {
    [self.messageThreadView appendMessage:[Message messageWithImoji:imoji sender:YES]];
    [self sendFakeResponse];
}

- (void)sendFakeResponse {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 500), dispatch_get_main_queue(), ^{
        if (((NSUInteger) [NSDate date].timeIntervalSince1970) % 2 == 0) {
            [self.imojiSession getFeaturedImojisWithNumberOfResults:@1
                                          resultSetResponseCallback:^(NSNumber *resultCount, NSError *error) {

                                          }
                                              imojiResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
                                                  [self.messageThreadView appendMessage:[Message messageWithImoji:imoji sender:NO]];
                                              }];

        } else {
            NSArray<NSString*> *fakeResponse = @[
                    @"wow",
                    @"amazing!",
                    @"lol",
                    @"omg",
                    @"I think so",
                    @"no way!"
            ];
            NSString *response = fakeResponse[((NSUInteger) [NSDate date].timeIntervalSince1970) % fakeResponse.count];
            
            [self.messageThreadView appendMessage:[Message messageWithText:[[NSAttributedString alloc] initWithString:response]
                                                                    sender:NO]];
        }
    });
}

@end
