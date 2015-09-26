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

#import "IMCreateImojiViewController.h"
#import "IMCreateImojiView.h"
#import "IMTagCollectionView.h"
#import "IMResourceBundleUtil.h"
#import "IMImojiObject.h"
#import "IMImojiSession.h"
#import "IMCreateImojiAssistantViewController.h"
#import "IMPopInAnimatedTransition.h"
#import <Masonry/Masonry.h>


@interface IMCreateImojiViewController () <IMCreateImojiViewDelegate, UIViewControllerTransitioningDelegate>

@property(nonatomic, readonly) UIBarButtonItem *undoButton;
@property(nonatomic, readonly) UIBarButtonItem *doneButton;
@property(nonatomic, readonly) UIBarButtonItem *forwardButton;
@property(nonatomic, readonly) UIBarButtonItem *backButton;
@property(nonatomic, readonly) UIBarButtonItem *helpButton;
@property(nonatomic, readonly) UIBarButtonItem *navigationTitle;

@property(nonatomic, readonly) IMCreateImojiView *imojiEditor;

@property(nonatomic, readonly) UIView *creationView;
@property(nonatomic, readonly) UIView *tagView;

@property(nonatomic, readonly) IMTagCollectionView *tagCollectionView;
@property(nonatomic, readonly) UIToolbar *navigationButtonView;
@property(nonatomic, readonly) UIToolbar *editorButtonView;

@property(nonatomic, readonly) UIImageView *imojiPreview;

@property(nonatomic, strong) NSArray *editorViewButtons;
@property(nonatomic, strong) NSArray *tagViewButtons;
@end

@implementation IMCreateImojiViewController {

}

- (instancetype)initWithSourceImage:(UIImage *)sourceImage session:(IMImojiSession *)session {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _sourceImage = sourceImage;
        _session = session;
    }

    return self;
}

- (void)loadView {
    [super loadView];

    UIView *view = [UIView new];

    _creationView = [UIView new];
    _tagView = [UIView new];

    _tagCollectionView = [IMTagCollectionView new];
    _navigationButtonView = [UIToolbar new];
    _editorButtonView = [UIToolbar new];

    _imojiEditor = [IMCreateImojiView new];
    _undoButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ImojiEditorAssets.bundle/createImojiUndo.png"]
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(performUndo)];
    _helpButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ImojiEditorAssets.bundle/create_trace_hints"]
                                                   style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(showHelpScreen)];
    _doneButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ImojiEditorAssets.bundle/createImojiFinish.png"]
                                                   style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(finishEditing)];
    _backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ImojiEditorAssets.bundle/createImojiBack.png"]
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(goBack)];
    _forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ImojiEditorAssets.bundle/createImojiForward.png"]
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(showTagScreen)];

    _navigationTitle = [[UIBarButtonItem alloc] initWithTitle:[IMResourceBundleUtil localizedStringForKey:@"createImojiHeaderTrim"]
                                                        style:UIBarButtonItemStylePlain
                                                       target:nil
                                                       action:nil];
    [_navigationTitle setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f]}
                                    forState:UIControlStateNormal];

    _imojiPreview = [UIImageView new];

    _imojiEditor.editorDelegate = self;

    [self.imojiEditor loadImage:self.sourceImage];

    self.doneButton.enabled = YES;
    self.forwardButton.enabled = self.undoButton.enabled = NO;

    view.backgroundColor = [UIColor colorWithRed:48.0f / 255.0f green:48.0f / 255.0f blue:48.0f / 255.0f alpha:1];

    [view addSubview:self.tagView];
    [view addSubview:self.creationView];
    [view addSubview:self.navigationButtonView];
    [view addSubview:self.editorButtonView];

    self.tagView.hidden = YES;
    self.imojiPreview.contentMode = UIViewContentModeScaleAspectFit;

    [self.creationView addSubview:self.imojiEditor];
    [self.tagView addSubview:self.imojiPreview];
    [self.tagView addSubview:self.tagCollectionView];

    self.editorButtonView.items = @[
            self.undoButton,
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            self.helpButton
    ];
    self.editorButtonView.barStyle = UIBarStyleBlackTranslucent;
    self.editorButtonView.tintColor = [UIColor whiteColor];

    self.editorViewButtons = @[
            self.backButton,
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            self.navigationTitle,
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            self.forwardButton
    ];

    self.tagViewButtons = @[
            self.backButton,
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            self.navigationTitle,
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            self.doneButton
    ];

    self.navigationButtonView.items = self.editorViewButtons;
    self.navigationButtonView.barStyle = UIBarStyleBlackTranslucent;
    self.navigationButtonView.tintColor = [UIColor whiteColor];

    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navigationButtonView.mas_bottom).offset(10);
        make.width.and.left.and.bottom.equalTo(view);
    }];

    [self.imojiPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.centerX.equalTo(self.tagView);
        make.width.and.height.equalTo(self.tagView.mas_width).dividedBy(3);
    }];

    [self.tagCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imojiPreview.mas_bottom);
        make.width.equalTo(self.tagView).multipliedBy(.8f);
        make.centerX.and.bottom.equalTo(self.tagView);
    }];

    [self.navigationButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.top.equalTo(view);
        make.height.equalTo(@50);
    }];

    [self.editorButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.bottom.equalTo(view);
        make.height.equalTo(@50);
    }];

    [self.creationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view);
    }];

    [self.imojiEditor mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.creationView);
    }];

    self.view = view;

    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)performUndo {
    if ([self.imojiEditor canUndo]) {
        [self.imojiEditor undo];
        self.undoButton.enabled = self.imojiEditor.canUndo;
    }
}

- (void)showHelpScreen {
    IMCreateImojiAssistantViewController *assistantViewController =
            [IMCreateImojiAssistantViewController createAssistantViewControllerWithSession:self.session];

    assistantViewController.transitioningDelegate = self;
    assistantViewController.modalPresentationStyle = UIModalPresentationCustom;

    [self presentViewController:assistantViewController
                       animated:YES
                     completion:nil];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    IMPopInAnimatedTransition *transition = [IMPopInAnimatedTransition new];
    transition.presenting = YES;
    return transition;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [IMPopInAnimatedTransition new];
}

- (void)finishEditing {
    if (self.createDelegate && [self.createDelegate respondsToSelector:@selector(userDidFinishCreatingImoji:withError:fromViewController:)]) {
        [self.session createImojiWithImage:self.imojiEditor.outputImage
                                      tags:self.tagCollectionView.tags.array
                                  callback:^(IMImojiObject *imoji, NSError *error) {
                                      [self.createDelegate userDidFinishCreatingImoji:imoji withError:error fromViewController:self];
                                  }];
    }
}

- (void)showTagScreen {
    self.tagView.hidden = NO;
    self.editorButtonView.hidden = YES;
    self.tagView.layer.opacity = 0.0f;

    self.imojiPreview.image = self.imojiEditor.borderedOutputImage;

    [UIView animateWithDuration:.7f
                     animations:^{
                         self.tagView.layer.opacity = 1.0f;
                         self.creationView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         self.creationView.hidden = YES;
                         [self.navigationTitle setTitle:[IMResourceBundleUtil localizedStringForKey:@"createImojiHeaderTag"]];
                         self.navigationButtonView.items = self.tagViewButtons;

                         self.tagCollectionView.tagInputFieldShouldBeFirstResponder = YES;
                     }
    ];
}

- (void)goBack {
    if (self.creationView.hidden) {
        self.creationView.hidden = NO;
        self.editorButtonView.hidden = NO;
        self.navigationButtonView.items = self.editorViewButtons;
        self.tagCollectionView.tagInputFieldShouldBeFirstResponder = YES;

        [UIView animateWithDuration:.7f
                         animations:^{
                             self.tagView.layer.opacity = 0.0f;
                             self.creationView.layer.opacity = 1.0f;
                         }
                         completion:^(BOOL finished) {
                             self.tagView.hidden = YES;
                             [self.navigationTitle setTitle:[IMResourceBundleUtil localizedStringForKey:@"createImojiHeaderTrim"]];
                         }];
    } else {
        if (self.createDelegate && [self.createDelegate respondsToSelector:@selector(userDidCancelImageEdit:)]) {
            [self.createDelegate userDidCancelImageEdit:self];
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)userDidUpdatePathInEditorView:(IMCreateImojiView *)editorView {
    self.undoButton.enabled = editorView.canUndo;
    self.forwardButton.enabled = editorView.hasOutputImage;
}

+ (instancetype)controllerWithSourceImage:(UIImage *)sourceImage session:(IMImojiSession *)session {
    return [[self alloc] initWithSourceImage:sourceImage session:session];
}

@end
