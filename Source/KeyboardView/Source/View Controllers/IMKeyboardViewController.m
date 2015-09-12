//
//  ImojiSDKUI
//
//  Created by Jeff Wang
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

#import <Masonry/Masonry.h>
#import "IMKeyboardViewController.h"
#import "IMKeyboardCollectionView.h"
#import "IMAttributeStringUtil.h"
#import "IMQwertyViewController.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef NS_ENUM(NSUInteger, IMKeyboardContentType) {
    IMKeyboardButtonSearch = 1,
    IMKeyboardButtonRecents,
    IMKeyboardButtonCategoryReactions,
    IMKeyboardButtonCategoryTrending,
    IMKeyboardButtonFavorites,
    IMKeyboardButtonDelete
};

NSString *const IMKeyboardViewControllerDefaultFontFamily = @"Imoji-Regular";
NSString *const IMKeyboardViewControllerDefaultAppGroup = @"group.com.imoji.keyboard";

@interface IMKeyboardViewController () <IMImojiSessionDelegate, IMKeyboardCollectionViewDelegate>

// keyboard size
@property(nonatomic) CGFloat portraitHeight;
@property(nonatomic) CGFloat landscapeHeight;
@property(nonatomic) NSLayoutConstraint *heightConstraint;

// data structures
@property(nonatomic, strong) IMImojiSession *session;
@property(nonatomic, strong) IMKeyboardCollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *navButtonsArray;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *closeButton;
@property(nonatomic, strong) UIImageView *heartImageView;
@property(nonatomic, strong) UIImageView *copiedImageView;

// progress bar
@property(nonatomic, strong) UIProgressView *progressView;

// menu buttons
@property(nonatomic, strong) UIView *bottomNavView;
@property(nonatomic, strong) UIButton *nextKeyboardButton;
@property(nonatomic, strong) UIButton *searchButton;
@property(nonatomic, strong) UIButton *recentsButton;
@property(nonatomic, strong) UIButton *generalCatButton;
@property(nonatomic, strong) UIButton *trendingCatButton;
@property(nonatomic, strong) UIButton *collectionButton;
@property(nonatomic, strong) UIButton *deleteButton;

// search
@property(nonatomic, strong) UIView *searchView;
@property(nonatomic, strong) IMKeyboardSearchTextField *searchField;

@property(nonatomic, strong) UIView *splashView;

@end

@implementation IMKeyboardViewController {
    NSAttributedString *_previousTitle;
}

- (id)initWithImojiSession:(IMImojiSession *)session {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Perform custom initialization work here
        self.portraitHeight = 258;
        self.landscapeHeight = 205;

        _appGroup = IMKeyboardViewControllerDefaultAppGroup;
        _fontFamily = IMKeyboardViewControllerDefaultFontFamily;

        _session = session;
        _session.delegate = self;

        _imagesBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"ImojiKeyboardAssets" ofType:@"bundle"]];

        _collectionView = [IMKeyboardCollectionView imojiCollectionViewWithSession:self.session];
        _collectionView.appGroup = _appGroup;
        _collectionView.keyboardDelegate = self;
    }
    return self;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    // Add custom view sizing constraints here
    if (self.view.frame.size.width == 0 || self.view.frame.size.height == 0) {
        return;
    }

    [self.inputView removeConstraint:self.heightConstraint];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape = self.view.frame.size.width != (screenW * (screenW < screenH)) + (screenH * (screenW > screenH));

    if (isLandscape) {
        self.heightConstraint.constant = self.landscapeHeight;
        [self.inputView addConstraint:self.heightConstraint];
    } else {
        self.heightConstraint.constant = self.portraitHeight;
        [self.inputView addConstraint:self.heightConstraint];
    }

    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    for (UIView *subview in self.view.subviews) {
        [subview removeFromSuperview];
    }

    // basic properties
    self.view.backgroundColor = [UIColor colorWithRed:248.0f / 255.0f green:248.0f / 255.0f blue:248.0f / 255.0f alpha:1];

    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:self.portraitHeight];
    self.heightConstraint.priority = UILayoutPriorityRequired - 1; // This will eliminate the constraint conflict warning.

    // set up views

    // custom progress bar
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.progressTintColor = [UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1];
    self.progressView.trackTintColor = [UIColor colorWithRed:180.0f / 255.0f green:180.0f / 255.0f blue:180.0f / 255.0f alpha:1];
    [self.progressView setProgress:0.0f animated:NO];
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.height.equalTo(@(1));
    }];

    // menu view
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 44)];
    self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"REACTIONS"
                                                                withFontSize:14.0f
                                                                   textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]
                                                               textAlignment:NSTextAlignmentLeft];
    self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
    [self.view addSubview:self.titleLabel];

    // close button
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setImage:[UIImage imageNamed:@"keyboard_search_clear" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeCategory) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.hidden = YES;
    [self.view addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(-5);
        make.height.equalTo(@(36));
    }];

    // heart
    self.heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard_favorited" inBundle:self.imagesBundle compatibleWithTraitCollection:nil]];
    [self.view addSubview:self.heartImageView];
    self.heartImageView.hidden = YES;
    [self.heartImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(-5);
        make.height.width.equalTo(@(36));
    }];

    // copied
    self.copiedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"keyboard_copied" inBundle:self.imagesBundle compatibleWithTraitCollection:nil]];
    [self.view addSubview:self.copiedImageView];
    self.copiedImageView.hidden = YES;
    [self.copiedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(-5);
        make.height.width.equalTo(@(36));
    }];

    // collection view
    self.collectionView.clipsToBounds = YES;
    [self.collectionView setShowsHorizontalScrollIndicator:NO];

    __unsafe_unretained typeof(self) weakSelf = self;
    self.collectionView.categorySelectedCallback = ^(IMImojiCategoryObject *category) {
        [weakSelf.collectionView loadImojisFromSearch:category.identifier];
    };
    self.collectionView.categoryShowCallback = ^(NSString *title) {
        weakSelf.closeButton.hidden = NO;
        weakSelf.titleLabel.attributedText = [IMAttributeStringUtil attributedString:[title uppercaseString]
                                                                        withFontSize:14.0f
                                                                           textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]];
        weakSelf.titleLabel.font = [UIFont fontWithName:weakSelf.fontFamily size:14.f];
    };
    self.collectionView.setProgressCallback = ^(float progress) {
        if (progress != INFINITY) {
            [weakSelf.progressView setProgress:progress animated:YES];
        }
    };
    self.collectionView.showDownloadingCallback = ^() {
        [weakSelf showDownloading];
    };
    self.collectionView.showCopiedCallback = ^(NSString *message) {
        [weakSelf showCopied:message];
    };
    self.collectionView.showFavoritedCallback = ^() {
        [weakSelf showFavorited];
    };
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(30);
        make.centerX.equalTo(self.view);
        make.right.equalTo(self.view.mas_right);
        make.left.equalTo(self.view.mas_left);
    }];

    // menu view
    [self setupMenuView];

    if(!self.hasFullAccess) {
        [self showSplashViewWithType:IMKeyboardEnableFullAccessSplash];
        self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"REQUIRES FULL ACCESS"
                                                                    withFontSize:14.0f
                                                                       textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]];
        self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
    } else if(self.hasConnectivity) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationGeneric];
        });
    } else {
        [self showSplashViewWithType:IMKeyboardNoConnectionSplash];
        self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"NO NETWORK CONNECTION"
                                                                    withFontSize:14.0f
                                                                       textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]];
        self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
    }

    self.generalCatButton.selected = YES;

    // search
    self.searchView = [[UIView alloc] init];
    self.searchView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.searchView];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).with.offset(1);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom);
    }];

    UIView *searchBar = [[UIView alloc] init];
    searchBar.backgroundColor = self.view.backgroundColor;
    [self.searchView addSubview:searchBar];
    [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchView.mas_top).with.offset(0);
        make.left.equalTo(self.searchView.mas_left).with.offset(0);
        make.right.equalTo(self.searchView.mas_right).with.offset(0);
        make.height.equalTo(@(40));
    }];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, 39.f, [[UIScreen mainScreen] applicationFrame].size.height, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:194 / 255.f green:194 / 255.f blue:194 / 255.f alpha:1].CGColor;
    [searchBar.layer addSublayer:bottomBorder];

    UIButton *searchCancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [searchCancelButton setTitle:@"CANCEL" forState:UIControlStateNormal];
    searchCancelButton.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
    [searchCancelButton addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    [searchCancelButton setTitleColor:[UIColor colorWithRed:193.f / 255.0f green:193.f / 255.0f blue:199 / 255.0f alpha:1] forState:UIControlStateNormal];
    [searchBar addSubview:searchCancelButton];
    [searchCancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchBar.mas_top).with.offset(0);
        make.right.equalTo(self.searchView.mas_right);
        make.height.equalTo(@(40));
        make.width.equalTo(@(80));
    }];

    self.searchField = [[IMKeyboardSearchTextField alloc] init];
    self.searchField.font = [UIFont fontWithName:self.fontFamily size:14.f];
    [searchBar addSubview:self.searchField];
    [self.searchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchBar.mas_top).with.offset(0);
        make.left.equalTo(searchBar.mas_left).with.offset(15);
        make.right.equalTo(searchCancelButton.mas_left).with.offset(10);
        make.height.equalTo(@(40));
    }];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IMQwerty" bundle:[NSBundle mainBundle]];
    IMQwertyViewController *vc = [storyboard instantiateInitialViewController];
    vc.searchField = self.searchField;
    [self addChildViewController:vc];
    [self.searchView addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchField.mas_bottom).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    vc.setSearchCallback = ^() {
        if (self.searchField.text.length > 0) {
            [self.splashView removeFromSuperview];
            self.searchView.hidden = YES;
            [self.collectionView loadImojisFromSearch:self.searchField.text offset:nil];
            for (int i = 1; i < 6; i++) { // loop through all buttons and deselect them
                ((UIButton *) [self.view viewWithTag:i]).selected = i == 1;
            }
        }
    };

    self.searchView.hidden = YES;
}

- (void)cancelSearch {
    self.searchField.text = @"";
    self.searchView.hidden = YES;
}

- (void)setupMenuView {
    int navHeight = 40;
    self.bottomNavView = [[UIView alloc] init];
    self.bottomNavView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.bottomNavView];
    [self.bottomNavView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.height.equalTo(@(navHeight));
        make.top.equalTo(self.collectionView.mas_bottom);
    }];

    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextKeyboardButton.tag = 0;
    self.nextKeyboardButton.frame = CGRectMake(0, 0, navHeight, navHeight);

    UIImage *nextKeyboardImageNormal = [UIImage imageNamed:@"keyboard_globe" inBundle:self.imagesBundle compatibleWithTraitCollection:nil];

    [self.nextKeyboardButton setImage:nextKeyboardImageNormal forState:UIControlStateNormal];
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.nextKeyboardButton];

    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchButton.tag = IMKeyboardButtonSearch;
    self.searchButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.searchButton setImage:[UIImage imageNamed:@"keyboard_search" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.searchButton setImage:[UIImage imageNamed:@"keyboard_search_active" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    [self.searchButton addTarget:self action:@selector(navPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.searchButton];

    self.recentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recentsButton.tag = IMKeyboardButtonRecents;
    self.recentsButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.recentsButton setImage:[UIImage imageNamed:@"keyboard_recents" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.recentsButton setImage:[UIImage imageNamed:@"keyboard_recents_active" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    [self.recentsButton addTarget:self action:@selector(navPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.recentsButton];

    self.generalCatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.generalCatButton.tag = IMKeyboardButtonCategoryReactions;
    self.generalCatButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.generalCatButton setImage:[UIImage imageNamed:@"keyboard_reactions" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.generalCatButton setImage:[UIImage imageNamed:@"keyboard_reactions_active" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    [self.generalCatButton addTarget:self action:@selector(navPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.generalCatButton];

    self.trendingCatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.trendingCatButton.tag = IMKeyboardButtonCategoryTrending;
    self.trendingCatButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.trendingCatButton setImage:[UIImage imageNamed:@"keyboard_trending" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.trendingCatButton setImage:[UIImage imageNamed:@"keyboard_trending_active" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    [self.trendingCatButton addTarget:self action:@selector(navPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.trendingCatButton];

    self.collectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.collectionButton.tag = IMKeyboardButtonFavorites;
    self.collectionButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.collectionButton setImage:[UIImage imageNamed:@"keyboard_collection" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.collectionButton setImage:[UIImage imageNamed:@"keyboard_collection_active" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
    [self.collectionButton addTarget:self action:@selector(navPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.collectionButton];

    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton.tag = IMKeyboardButtonDelete;
    self.deleteButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.deleteButton setImage:[UIImage imageNamed:@"keyboard_delete" inBundle:self.imagesBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deletePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.deleteButton];

    [self.bottomNavView addSubview:self.nextKeyboardButton];
    [self.bottomNavView addSubview:self.searchButton];
    [self.bottomNavView addSubview:self.recentsButton];
    [self.bottomNavView addSubview:self.generalCatButton];
    [self.bottomNavView addSubview:self.trendingCatButton];
    [self.bottomNavView addSubview:self.collectionButton];
    [self.bottomNavView addSubview:self.deleteButton];

    if(!self.hasFullAccess) {
        self.nextKeyboardButton.alpha = 0.5f;
        [self.searchButton setEnabled:NO];
        [self.recentsButton setEnabled:NO];
        [self.generalCatButton setEnabled:NO];
        [self.trendingCatButton setEnabled:NO];
        [self.collectionButton setEnabled:NO];
        [self.deleteButton setEnabled:NO];
    }

    [self positionMenuButtons];
}

- (void)positionMenuButtons {
    // left
    [self.nextKeyboardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.bottomNavView);
        make.width.equalTo(self.bottomNavView).dividedBy(7);
        make.left.equalTo(self.bottomNavView.mas_left);
    }];

    // right
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.bottomNavView);
        make.width.equalTo(self.nextKeyboardButton);
        make.right.equalTo(self.bottomNavView.mas_right);
    }];

    // left center
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.bottomNavView);
        make.width.equalTo(self.nextKeyboardButton);
        make.left.equalTo(self.nextKeyboardButton.mas_right);
    }];

    [self.recentsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.bottomNavView);
        make.width.equalTo(self.nextKeyboardButton);
        make.left.equalTo(self.searchButton.mas_right);
    }];

    // center
    [self.generalCatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.bottomNavView);
        make.width.equalTo(self.nextKeyboardButton);
        make.centerX.equalTo(self.bottomNavView);
    }];

    // right center
    [self.trendingCatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.bottomNavView);
        make.width.equalTo(self.nextKeyboardButton);
        make.left.equalTo(self.generalCatButton.mas_right);
    }];

    [self.collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.height.equalTo(self.bottomNavView);
        make.width.equalTo(self.nextKeyboardButton);
        make.left.equalTo(self.trendingCatButton.mas_right);
    }];
}

- (IBAction)navPressed:(UIButton *)sender {
    BOOL sameButtonPressed = NO;
    // set selected state

    if (sender.tag != 1) {
        for (int i = 1; i < 6; i++) { // loop through all buttons and deselect them
            UIButton *tmpButton = (UIButton *) [self.view viewWithTag:i];
            if (tmpButton.selected && i == sender.tag) {
                sameButtonPressed = YES; // check if it's the same button being pressed
            }
            tmpButton.selected = NO;
        }
        sender.selected = YES; // set button pressed to selected
    }

    if (sameButtonPressed && sender.tag != IMKeyboardButtonCategoryReactions && sender.tag != IMKeyboardButtonCategoryTrending) {
        return;
    }

    // run action
    if(self.hasConnectivity) {
        switch (sender.tag) {
            case IMKeyboardButtonSearch:
                self.searchView.hidden = NO;
                [self.progressView setProgress:0.f animated:YES];
                break;
            case IMKeyboardButtonRecents:
                [self.splashView removeFromSuperview];
                [self.collectionView loadRecentImojis];
                self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"RECENTS"
                                                                            withFontSize:14.0f
                                                                               textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]];
                self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
                self.closeButton.hidden = YES;
                break;
            case IMKeyboardButtonCategoryReactions:
                [self.splashView removeFromSuperview];
                [self.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationGeneric];
                self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"REACTIONS"
                                                                            withFontSize:14.0f
                                                                               textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]];
                self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
                self.closeButton.hidden = YES;
                break;
            case IMKeyboardButtonCategoryTrending:
                [self.splashView removeFromSuperview];
                [self.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationTrending];
                self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"TRENDING"
                                                                            withFontSize:14.0f
                                                                               textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]];
                self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
                self.closeButton.hidden = YES;
                break;
            case IMKeyboardButtonFavorites: {
                [self.splashView removeFromSuperview];
                [self.collectionView loadFavoriteImojis];
                NSString *title;

                if (self.session.sessionState == IMImojiSessionStateConnectedSynchronized) {
                    title = @"COLLECTION";
                } else {
                    title = @"FAVORITES";
                }

                self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:title
                                                                            withFontSize:14.0f
                                                                               textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]];
                self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
                self.closeButton.hidden = YES;
                break;
            }
            default:
                [self.splashView removeFromSuperview];
                break;
        }
    } else {
        [self showSplashViewWithType:IMKeyboardNoConnectionSplash];
        self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"NO NETWORK CONNECTION"
                                                                    withFontSize:14.0f
                                                                       textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]];
        self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
    }

}

- (void)closeCategory {
    self.closeButton.hidden = YES;

    // check if keyboard is in search mode
    UIButton *tmpButton = (UIButton *) [self.view viewWithTag:1];
    if (tmpButton.selected) {
        self.searchView.hidden = NO;
        self.searchField.text = @"";
        return;
    }

    // check which category keyboard displaying
    [self.splashView removeFromSuperview];
    [self.collectionView loadImojiCategories:self.collectionView.currentCategoryClassification];

    if (self.collectionView.currentCategoryClassification == IMImojiSessionCategoryClassificationGeneric) {
        self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"REACTIONS"
                                                                    withFontSize:14.0f
                                                                       textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]];
        self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
    } else {
        self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"TRENDING"
                                                                    withFontSize:14.0f
                                                                       textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]];
        self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
    }
}

- (void)showDownloading {
    if (![self.titleLabel.attributedText.string isEqual:@"COPIED TO CLIPBOARD"] && ![self.titleLabel.attributedText.string isEqual:@"DOWNLOADING ..."] && ![self.titleLabel.attributedText.string isEqual:@"SAVED TO FAVORITES"]) {
        _previousTitle = self.titleLabel.attributedText;
    }

    self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"DOWNLOADING ..."
                                                                withFontSize:14.0f
                                                                   textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]
                                                               textAlignment:NSTextAlignmentLeft];
    self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
    self.closeButton.hidden = YES;
}

- (void)showCopied:(NSString *)message {
    self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:[message uppercaseString]
                                                                withFontSize:14.0f
                                                                   textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]
                                                               textAlignment:NSTextAlignmentLeft];
    self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];

    self.copiedImageView.hidden = NO;
    [self performSelector:@selector(showPreviousTitle) withObject:self afterDelay:1.5];
}

- (void)showFavorited {
    if (![self.titleLabel.attributedText.string isEqual:@"COPIED TO CLIPBOARD"] && ![self.titleLabel.attributedText.string isEqual:@"DOWNLOADING ..."] && ![self.titleLabel.attributedText.string isEqual:@"SAVED TO FAVORITES"]) {
        _previousTitle = self.titleLabel.attributedText;
    }
    self.titleLabel.attributedText = [IMAttributeStringUtil attributedString:@"SAVED TO FAVORITES"
                                                                withFontSize:14.0f
                                                                   textColor:[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1]
                                                               textAlignment:NSTextAlignmentLeft];
    self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];

    self.closeButton.hidden = YES;
    self.heartImageView.hidden = NO;
    [self performSelector:@selector(showPreviousTitle) withObject:self afterDelay:1.5];
}

- (void)showPreviousTitle {
    self.titleLabel.attributedText = _previousTitle;
    self.titleLabel.font = [UIFont fontWithName:self.fontFamily size:14.f];
    self.copiedImageView.hidden = YES;
    self.heartImageView.hidden = YES;
    self.closeButton.hidden = NO;
}

- (IBAction)deletePressed:(id)sender {
    [self.textDocumentProxy deleteBackward];
}

- (void)setAppGroup:(NSString *)appGroup {
    _appGroup = appGroup;
    self.collectionView.appGroup = appGroup;
}

- (void)selectedNoResultsView {
    self.searchView.hidden = NO;
    [self.progressView setProgress:0.f animated:YES];
}

- (void)showSplashViewWithType:(IMKeyboardSplashType)splashType {
    if(self.splashView) {
        [self.splashView removeFromSuperview];
        self.splashView = nil;
    }

    self.splashView = [[UIView alloc] init];
    UIImageView *splashGraphic = [[UIImageView alloc] init];
    UILabel *splashText = [[UILabel alloc] init];

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentNatural;

    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];

    switch(splashType) {
        case IMKeyboardNoConnectionSplash:
            splashGraphic.image = [UIImage imageNamed:@"keyboard_splash_noconnection" inBundle:self.imagesBundle compatibleWithTraitCollection:nil];

            splashText.text = @"Enable wifi or cellular data\nto use imoji sticker keyboard";
            splashText.textColor = [UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1];
            splashText.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:14.0f];
            break;
        case IMKeyboardEnableFullAccessSplash:
            splashGraphic.image = [UIImage imageNamed:@"keyboard_splash_enableaccess" inBundle:self.imagesBundle compatibleWithTraitCollection:nil];

            splashText.text = @"Allow Full Access in Settings\nto use imoji sticker keyboard";
            splashText.textColor = [UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1];
            splashText.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:14.0f];
            break;
        case IMKeyboardNoResultsSplash:
            splashGraphic.image = [UIImage imageNamed:@"keyboard_splash_noresults" inBundle:self.imagesBundle compatibleWithTraitCollection:nil];

            [textAttributes setDictionary:@{
                    NSFontAttributeName : [UIFont fontWithName:@"SFUIDisplay-Light" size:19.0f],
                    NSForegroundColorAttributeName : [UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1],
                    NSParagraphStyleAttributeName : paragraphStyle
            }];

            [text appendAttributedString: [[NSAttributedString alloc] initWithString:@"No Results\n"
                                                                          attributes:textAttributes]];
            textAttributes[@"NSFont"] = [UIFont fontWithName:@"SFUIDisplay-Regular" size:16.0f];
            textAttributes[@"NSColor"] = [UIColor colorWithRed:56.0f / 255.0f green:124.0f / 255.0f blue:169.0f / 255.0f alpha:1];
            [text appendAttributedString: [[NSAttributedString alloc] initWithString:@"Try Again"
                                                                          attributes:textAttributes]];
            splashText.attributedText = text;
            break;
        case IMKeyboardCollectionSplash:
            splashGraphic.image = [UIImage imageNamed:@"keyboard_splash_collection" inBundle:self.imagesBundle compatibleWithTraitCollection:nil];

            [textAttributes setDictionary:@{
                    NSFontAttributeName : [UIFont fontWithName:@"SFUIDisplay-Medium" size:15.0f],
                    NSForegroundColorAttributeName : [UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1],
                    NSParagraphStyleAttributeName : paragraphStyle
            }];

            [text appendAttributedString: [[NSAttributedString alloc] initWithString:@"Double tap "
                                                                          attributes:textAttributes]];
            textAttributes[@"NSFont"] = [UIFont fontWithName:@"SFUIDisplay-Regular" size:15.0f];
            [text appendAttributedString: [[NSAttributedString alloc] initWithString:@"stickers to add them\nto your collection!"
                                                                          attributes:textAttributes]];

            splashText.attributedText = text;
            break;
        case IMKeyboardRecentsSplash:
            splashGraphic.image = [UIImage imageNamed:@"keyboard_splash_recents" inBundle:self.imagesBundle compatibleWithTraitCollection:nil];

            splashText = [[UILabel alloc] init];
            splashText.text = @"Stickers you send\nwill appear here";
            splashText.textColor = [UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1];

            splashText.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:15.0f];
            break;
        default:
            break;
    }

    splashText.lineBreakMode = NSLineBreakByWordWrapping;
    splashText.numberOfLines = 2;
    splashText.textAlignment = NSTextAlignmentCenter;

    [self.view insertSubview:self.splashView aboveSubview:self.collectionView];

    [self.splashView addSubview:splashGraphic];
    [self.splashView addSubview:splashText];

    [splashGraphic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-30.0f);
    }];

    [splashText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(splashGraphic.mas_bottom).offset(13.0f);
        make.width.equalTo(self.view).multipliedBy(.60f);
        make.centerX.equalTo(self.view);
    }];
}

- (BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    BOOL isConnected = nil;

    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                isConnected = NO;
            } else if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                isConnected = YES;
            } else if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                    (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs

                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    isConnected = YES;
                }
            } else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                isConnected = YES;
            }
        }
    }

    CFRelease(reachability);

    if(isConnected) {
        return isConnected;
    }

    return NO;
}

- (BOOL)hasFullAccess{
    return [UIPasteboard generalPasteboard];
}

@end
