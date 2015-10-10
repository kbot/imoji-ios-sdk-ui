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

@interface ViewController () <UITextFieldDelegate, IMCollectionViewDelegate>

@property(nonatomic, strong) MessageThreadView *messageThreadView;
@property(nonatomic, strong) UITextField *inputField;
@property(nonatomic, strong) ImojiSuggestionView *imojiSuggestionView;
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

    self.messageThreadView = [MessageThreadView new];
    self.inputField = [UITextField new];
    self.imojiSuggestionView = [ImojiSuggestionView new];
    self.inputField.delegate = self;

    self.inputField.font = [IMAttributeStringUtil defaultFontWithSize:16.f];
    self.inputField.layer.cornerRadius = 4.f;
    self.inputField.layer.borderColor = [UIColor colorWithWhite:.75f alpha:1.f].CGColor;
    self.inputField.backgroundColor = [UIColor whiteColor];
    self.inputField.returnKeyType = UIReturnKeySend;
    self.inputField.clearButtonMode = UITextFieldViewModeWhileEditing;

    self.messageThreadView.backgroundColor = [UIColor colorWithWhite:235 / 255.f alpha:1.f];

    self.imojiSuggestionView.collectionView.collectionViewDelegate = self;
    self.imojiSuggestionView.collectionView.preferredImojiDisplaySize = CGSizeMake(50.f, 50.f);

    [self.view addSubview:self.messageThreadView];
    [self.view addSubview:self.imojiSuggestionView];
    [self.view addSubview:self.inputField];

    UIView *suggestionTopBorder = [UIView new];
    [self.imojiSuggestionView addSubview:suggestionTopBorder];

    [suggestionTopBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imojiSuggestionView);
        make.left.right.equalTo(self.imojiSuggestionView);
        make.height.equalTo(@1);
    }];
    suggestionTopBorder.backgroundColor = [UIColor colorWithWhite:.75f alpha:1.f];

    [self.messageThreadView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.bottom.equalTo(self.view);
    }];

    [self.inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 5, 0, 5));
        make.height.equalTo(@50);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@55);
        make.top.equalTo(self.inputField.mas_top);
    }];
}

#pragma mark Text View Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [self.messageThreadView appendMessage:[Message messageWithText:[[NSAttributedString alloc] initWithString:textField.text] sender:YES]];
    }

    textField.text = @"";

    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    [self.imojiSuggestionView.collectionView loadImojisFromSentence:self.inputField.text];

    [self.imojiSuggestionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@55);
        make.bottom.equalTo(self.inputField.mas_top);
    }];

    [UIView animateWithDuration:1.0f
                          delay:0
         usingSpringWithDamping:.8f
          initialSpringVelocity:1.2f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.imojiSuggestionView layoutIfNeeded];
                     } completion:nil];
}

#pragma mark Imoji Collection View Delegate

- (void)userDidSelectImoji:(nonnull IMImojiObject *)imoji fromCollectionView:(nonnull IMCollectionView *)collectionView {
    [self.messageThreadView appendMessage:[Message messageWithImoji:imoji sender:YES]];
}

#pragma mark Keyboard Handling


- (void)inputFieldWillShow:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve =
            (UIViewAnimationOptions) ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16);

    [self.inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 5, 0, 5));
        make.height.equalTo(@50);
        make.bottom.equalTo(self.view).offset(-endRect.size.height);
    }];

    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurve
                     animations:^{
                         [self.inputField layoutIfNeeded];
                         [self.imojiSuggestionView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                self.messageThreadView.scrollIndicatorInsets =
                        self.messageThreadView.contentInset =
                                UIEdgeInsetsMake(0, 0, self.view.frame.size.height - endRect.size.height - self.inputField.frame.size.height - self.imojiSuggestionView.frame.size.height, 0);
            }];
}

- (void)inputFieldWillHide:(NSNotification *)notification {
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect endRect = [[keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve =
            (UIViewAnimationOptions) ([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue] << 16);

    NSLog(@"bottom offset %@", @((self.view.frame.size.height - endRect.origin.y)));
    [self.inputField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).insets(UIEdgeInsetsMake(0, 5, 0, 5));
        make.height.equalTo(@50);
        make.bottom.equalTo(self.view).offset((self.view.frame.size.height - endRect.origin.y) * -1);
    }];

    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurve
                     animations:^{
                         [self.inputField layoutIfNeeded];
                         [self.imojiSuggestionView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                self.messageThreadView.scrollIndicatorInsets =
                        self.messageThreadView.contentInset = UIEdgeInsetsMake(0, 0, self.view.frame.size.height - self.imojiSuggestionView.frame.origin.y - self.inputField.frame.size.height - self.imojiSuggestionView.frame.size.height, 0);
            }];
}


@end
