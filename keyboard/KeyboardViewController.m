//
//  KeyboardViewController.m
//  keyboard
//
//  Created by Jeff on 5/26/15.
//  Copyright (c) 2015 Jeff. All rights reserved.
//

#import "KeyboardViewController.h"
#import <CoreFoundation/CoreFoundation.h>
#import "ImojiCollectionView.h"
#import <Masonry/View+MASAdditions.h>
#import <UIKit/UIKit.h>
#import "ImojiTextUtil.h"
#import "PMCustomKeyboard.h"


#define CUR_WIDTH [[UIScreen mainScreen] applicationFrame ].size.width

@interface KeyboardViewController ()

// keyboard size
@property (nonatomic) CGFloat portraitHeight;
@property (nonatomic) CGFloat landscapeHeight;
@property (nonatomic) BOOL isLandscape;
@property (nonatomic) NSLayoutConstraint *heightConstraint;

// data structures
@property (nonatomic, strong) IMImojiSession *session;
@property (nonatomic, strong) ImojiCollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *navButtonsArray;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *closeButton;

// progress bar
@property (nonatomic, strong) UIProgressView *progressView;

// menu buttons
@property (nonatomic, strong) UIView *bottomNavView;
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *recentsButton;
@property (nonatomic, strong) UIButton *generalCatButton;
@property (nonatomic, strong) UIButton *trendingCatButton;
@property (nonatomic, strong) UIButton *collectionButton;
@property (nonatomic, strong) UIButton *deleteButton;

// search
@property (nonatomic, strong) UITextField *searchField;


@end

@implementation KeyboardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Perform custom initialization work here
        self.portraitHeight = 258;
        self.landscapeHeight = 205;
    }
    return self;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    // Add custom view sizing constraints here
    if (self.view.frame.size.width == 0 || self.view.frame.size.height == 0)
        return;
    
    [self.inputView removeConstraint:self.heightConstraint];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape =  !(self.view.frame.size.width ==
                          (screenW*(screenW<screenH))+(screenH*(screenW>screenH)));
    NSLog(isLandscape ? @"Screen: Landscape" : @"Screen: Potriaint");
    NSLog(@"%f",CUR_WIDTH);
    self.isLandscape = isLandscape;
    if (isLandscape) {
        self.heightConstraint.constant = self.landscapeHeight;
        [self.inputView addConstraint:self.heightConstraint];
    } else {
        self.heightConstraint.constant = self.portraitHeight;
        [self.inputView addConstraint:self.heightConstraint];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[ImojiSDK sharedInstance] setClientId:[[NSUUID alloc] initWithUUIDString:@"a5908b99-c9b6-4661-9dfb-5c9ff4860c80"] apiToken:@"U2FsdGVkX1+FJ8PuT09YF1Ypf/yMWuFFGW885/rhgj8="];
    
    // basic properties
    self.view.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1];

    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.inputView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:self.portraitHeight];
    self.heightConstraint.priority = UILayoutPriorityRequired - 1; // This will eliminate the constraint conflict warning.
    
    self.session = [IMImojiSession imojiSession];
    self.session.delegate = self;
    
    // set up views
    
    // menu view
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 44)];
    self.titleLabel.attributedText = [ImojiTextUtil attributedString:@"REACTIONS"
                                                        withFontSize:14.0f
                                                           textColor:[UIColor colorWithRed:55/255.f green:123/255.f blue:167/255.f alpha:1.f]
                                                       textAlignment:NSTextAlignmentLeft];
    self.titleLabel.font = [UIFont fontWithName:@"Imoji-Regular" size:14.f];
    
    [self.view addSubview:self.titleLabel];
    
    
    // custom progress bar
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.progressTintColor = [UIColor colorWithRed:55/255.f green:123/255.f blue:167/255.f alpha:1.0f];
    self.progressView.trackTintColor = [UIColor colorWithRed:151/255.f green:185/255.f blue:207/255.f alpha:1.0f];
    [self.progressView setProgress:0.0f animated:NO];
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.width.equalTo(@(2));
    }];
    
    // close button
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(0, 0, 36, 40);
    [self.closeButton  setImage:[UIImage imageNamed:@"keyboard_search_clear"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeCategory) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.hidden = YES;
    [self.view addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(-5);
        make.width.height.equalTo(@(36));
    }];
    
    
    // collection view
    self.collectionView = [ImojiCollectionView imojiCollectionViewWithSession:self.session];
    self.collectionView.clipsToBounds = YES;
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    
    __unsafe_unretained typeof(self) weakSelf = self;
    self.collectionView.categoryShowCallback = ^(NSString *title) {
        weakSelf.closeButton.hidden = NO;
        weakSelf.titleLabel.attributedText = [ImojiTextUtil attributedString:[title uppercaseString]
                                                            withFontSize:14.0f
                                                               textColor:[UIColor colorWithRed:55/255.f green:123/255.f blue:167/255.f alpha:1.f]];
        weakSelf.titleLabel.font = [UIFont fontWithName:@"Imoji-Regular" size:14.f];
    };
    self.collectionView.setProgressCallback = ^(float progress) {
        if (progress != INFINITY) {
            [weakSelf.progressView setProgress:progress animated:YES];
        }
    };
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(30);
        make.centerX.equalTo(self.view);
        make.right.equalTo(self.view.mas_right);
        make.left.equalTo(self.view.mas_left);
    }];
    
    [self.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationGeneric];
    
    // menu view
    [self setupMenuView];
    
    /*
    // search
    self.searchField = [[UITextField alloc] init];
    [self.view addSubview:self.searchField];
    [self.searchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.height.equalTo(@(40));
    }];
    PMCustomKeyboard *customKeyboard = [[PMCustomKeyboard alloc] init];
    [customKeyboard setTextView:self.searchField];
    customKeyboard.backgroundColor = [UIColor redColor];
    UIView *searchView = [[UIView alloc] init];
    [self.view addSubview:searchView];
    [searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.searchField.mas_bottom).with.offset(0);
        //make.top.equalTo(self.view.mas_top).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [searchView addSubview:customKeyboard];
    
    NSLog(@"customKeyboard width: %f", customKeyboard.frame.size.width);
    NSLog(@"customKeyboard height: %f", customKeyboard.frame.size.height);
    NSLog(@"customKeyboard x: %f", customKeyboard.frame.origin.x);
    NSLog(@"customKeyboard y: %f", customKeyboard.frame.origin.y);
    NSLog(@"screen width: %f", self.view.frame.size.width);
    */
    /*
    [customKeyboard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchView.mas_top).with.offset(0);
        make.left.equalTo(searchView.mas_left).with.offset(0);
        make.right.equalTo(searchView.mas_right).with.offset(0);
        make.centerX.equalTo(searchView.mas_centerX);
        make.height.equalTo(@(216));
    }];*/
     
}

- (void)setupMenuView {
    int navHeight = 40;
    self.bottomNavView = [[UIView alloc] init];
    self.bottomNavView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.bottomNavView];
    [self.bottomNavView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left).offset(10);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.height.equalTo(@(navHeight));
        make.top.equalTo(self.collectionView.mas_bottom);
    }];
    
    
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextKeyboardButton.tag = 0;
    self.nextKeyboardButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    UIImage *nextKeyboardImageNormal = [UIImage imageNamed:@"keyboard_globe"];
    [self.nextKeyboardButton  setImage:nextKeyboardImageNormal forState:UIControlStateNormal];
    [self.nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.nextKeyboardButton];
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchButton.tag = 1;
    self.searchButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.searchButton  setImage:[UIImage imageNamed:@"keyboard_search"] forState:UIControlStateNormal];
    [self.searchButton setImage:[UIImage imageNamed:@"keyboard_search_active"] forState:UIControlStateSelected];
    [self.searchButton addTarget:self action:@selector(navPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.searchButton];
    
    self.recentsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recentsButton.tag = 2;
    self.recentsButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.recentsButton  setImage:[UIImage imageNamed:@"keyboard_recents"] forState:UIControlStateNormal];
    [self.recentsButton  setImage:[UIImage imageNamed:@"keyboard_recents_active"] forState:UIControlStateSelected];
    [self.recentsButton addTarget:self action:@selector(navPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.recentsButton];
    
    self.generalCatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.generalCatButton.tag = 3;
    self.generalCatButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.generalCatButton  setImage:[UIImage imageNamed:@"keyboard_reactions"] forState:UIControlStateNormal];
    [self.generalCatButton  setImage:[UIImage imageNamed:@"keyboard_reactions_active"] forState:UIControlStateSelected];
    [self.generalCatButton addTarget:self action:@selector(navPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.generalCatButton];
    
    self.trendingCatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.trendingCatButton.tag = 4;
    self.trendingCatButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.trendingCatButton  setImage:[UIImage imageNamed:@"keyboard_trending"] forState:UIControlStateNormal];
    [self.trendingCatButton  setImage:[UIImage imageNamed:@"keyboard_trending_active"] forState:UIControlStateSelected];
    [self.trendingCatButton addTarget:self action:@selector(navPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.trendingCatButton];
    
    self.collectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.collectionButton.tag = 5;
    self.collectionButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.collectionButton  setImage:[UIImage imageNamed:@"keyboard_collection"] forState:UIControlStateNormal];
    [self.collectionButton  setImage:[UIImage imageNamed:@"keyboard_collection_active"] forState:UIControlStateSelected];
    [self.collectionButton addTarget:self action:@selector(navPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.collectionButton];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton.tag = 6;
    self.deleteButton.frame = CGRectMake(0, 0, navHeight, navHeight);
    [self.deleteButton  setImage:[UIImage imageNamed:@"keyboard_delete"] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deletePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.navButtonsArray addObject:self.deleteButton];
    
    [self.bottomNavView addSubview:self.nextKeyboardButton];
    [self.bottomNavView addSubview:self.searchButton];
    [self.bottomNavView addSubview:self.recentsButton];
    [self.bottomNavView addSubview:self.generalCatButton];
    [self.bottomNavView addSubview:self.trendingCatButton];
    [self.bottomNavView addSubview:self.collectionButton];
    [self.bottomNavView addSubview:self.deleteButton];
    
    [self positionMenuButtons];
}

-(void) positionMenuButtons {    
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

- (IBAction)navPressed:(UIButton*)sender {
    BOOL sameButtonPressed = NO;
    // set selected state
    for (int i = 1; i < 6; i++) {
        UIButton *tmpButton = (UIButton *)[self.view viewWithTag:i];
        if (tmpButton.selected == YES && i == sender.tag) {
            sameButtonPressed = YES;
        }
        tmpButton.selected = NO;
    }
    sender.selected = YES;
    if (sameButtonPressed) {
        return;
    }
    
    // run action
    self.closeButton.hidden = YES;
    switch (sender.tag) {
        case 1:
            self.titleLabel.attributedText = [ImojiTextUtil attributedString:@"SEARCH"
                                                                withFontSize:14.0f
                                                                   textColor:[UIColor colorWithRed:55/255.f green:123/255.f blue:167/255.f alpha:1.f]];
            self.titleLabel.font = [UIFont fontWithName:@"Imoji-Regular" size:14.f];
            [self.progressView setProgress:0.f animated:YES];
            break;
        case 2:
            [self.collectionView loadRecentImojis];
            self.titleLabel.attributedText = [ImojiTextUtil attributedString:@"RECENTS"
                                                                withFontSize:14.0f
                                                                   textColor:[UIColor colorWithRed:55/255.f green:123/255.f blue:167/255.f alpha:1.f]];
            self.titleLabel.font = [UIFont fontWithName:@"Imoji-Regular" size:14.f];
            break;
        case 3:
            [self.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationGeneric];
            self.titleLabel.attributedText = [ImojiTextUtil attributedString:@"REACTIONS"
                                                                withFontSize:14.0f
                                                                   textColor:[UIColor colorWithRed:55/255.f green:123/255.f blue:167/255.f alpha:1.f]];
            self.titleLabel.font = [UIFont fontWithName:@"Imoji-Regular" size:14.f];
            break;
        case 4:
            [self.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationTrending];
            self.titleLabel.attributedText = [ImojiTextUtil attributedString:@"TRENDING"
                                                                withFontSize:14.0f
                                                                   textColor:[UIColor colorWithRed:55/255.f green:123/255.f blue:167/255.f alpha:1.f]];
            self.titleLabel.font = [UIFont fontWithName:@"Imoji-Regular" size:14.f];
            break;
        case 5:
            [self.collectionView loadFavoriteImojis];
            self.titleLabel.attributedText = [ImojiTextUtil attributedString:@"FAVORITES"
                                                                withFontSize:14.0f
                                                                   textColor:[UIColor colorWithRed:55/255.f green:123/255.f blue:167/255.f alpha:1.f]];
            self.titleLabel.font = [UIFont fontWithName:@"Imoji-Regular" size:14.f];
            break;
        default:
            break;
    }
}

- (void)closeCategory {
    self.closeButton.hidden = YES;
    [self.collectionView loadImojiCategories:self.collectionView.currentCategoryClassification];
    if (self.collectionView.currentCategoryClassification == IMImojiSessionCategoryClassificationGeneric) {
        self.titleLabel.attributedText = [ImojiTextUtil attributedString:@"REACTIONS"
                                                            withFontSize:14.0f
                                                               textColor:[UIColor colorWithRed:55/255.f green:123/255.f blue:167/255.f alpha:1.f]];
        self.titleLabel.font = [UIFont fontWithName:@"Imoji-Regular" size:14.f];
    } else {
        self.titleLabel.attributedText = [ImojiTextUtil attributedString:@"TRENDING"
                                                            withFontSize:14.0f
                                                               textColor:[UIColor colorWithRed:55/255.f green:123/255.f blue:167/255.f alpha:1.f]];
        self.titleLabel.font = [UIFont fontWithName:@"Imoji-Regular" size:14.f];
    }
}

- (void)setTitle:(NSString*)text {
    
}

- (IBAction)deletePressed:(id)sender {
    [self.textDocumentProxy deleteBackward];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
}

@end
