//
//  ViewController.m
//  imoji-sample
//
//  Created by Nima on 4/6/15.
//  Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <ImojiSDK/ImojiSyncSDK.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMCollectionView.h>

#import "MainViewController.h"
#import "ImojiResultsView.h"

@interface MainViewController () <UIAlertViewDelegate, IMImojiSessionDelegate>

@property(nonatomic, strong) ImojiResultsView *imojiCollectionsView;
@property(nonatomic, strong) UIButton *collectionsButton;
@property(nonatomic, strong) UIButton *searchButton;
@property(nonatomic, strong) UIButton *featuredButton;
@property(nonatomic, strong) UIButton *categoriesButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _imojiSession = [IMImojiSession imojiSession];

    UIImageView *appIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Main-Icon"]];
    UILabel *title = [UILabel new];
    self.categoriesButton = [UIButton new];
    self.featuredButton = [UIButton new];
    self.searchButton = [UIButton new];
    self.collectionsButton = [UIButton new];

    self.imojiCollectionsView = [ImojiResultsView resultsViewWithSession:self.imojiSession];
    self.imojiCollectionsView.hidden = YES;
    __weak typeof(self) weakSelf = self;
    self.imojiCollectionsView.dismissedCallback = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf hideImojiCollectionsView];
    };

    self.view.backgroundColor = [UIColor colorWithRed:249.0f / 255.0f
                                                green:249.0f / 255.0f
                                                 blue:249.0f / 255.0f
                                                alpha:1.0f];

    self.categoriesButton.backgroundColor =
            self.featuredButton.backgroundColor =
                    self.searchButton.backgroundColor =
                            self.collectionsButton.backgroundColor =
                                    [UIColor colorWithRed:44.0f / 255.0f
                                                    green:168.0f / 255.0f
                                                     blue:224.0f / 255.0f
                                                    alpha:1.0f];

    self.categoriesButton.layer.cornerRadius = self.featuredButton.layer.cornerRadius =
            self.searchButton.layer.cornerRadius = self.collectionsButton.layer.cornerRadius = 5.0f;

    title.attributedText = [IMAttributeStringUtil attributedString:@"Imoji SDK Sample"
                                                          withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                             color:[UIColor colorWithRed:120.0f / 255.0f
                                                                                   green:120.0f / 255.0f
                                                                                    blue:120.0f / 255.0f
                                                                                   alpha:1.0f]
                                                      andAlignment:NSTextAlignmentLeft
                            ];

    [self.categoriesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.featuredButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.collectionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.categoriesButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Categories"
                                                                             withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                                                color:[UIColor whiteColor]
                                                                         andAlignment:NSTextAlignmentLeft]
                                     forState:UIControlStateNormal
    ];

    [self.featuredButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Featured"
                                                                           withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                                              color:[UIColor whiteColor]
                                                                       andAlignment:NSTextAlignmentLeft]

                                   forState:UIControlStateNormal
    ];

    [self.searchButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Search"
                                                                         withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                                            color:[UIColor whiteColor]
                                                                     andAlignment:NSTextAlignmentLeft]

                                 forState:UIControlStateNormal
    ];

    [self.collectionsButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Authenticate Account"
                                                                  withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                                     color:[UIColor whiteColor]
                                                                          andAlignment:NSTextAlignmentLeft]

                                      forState:UIControlStateNormal
    ];

    [self.categoriesButton addTarget:self action:@selector(displayCategories) forControlEvents:UIControlEventTouchUpInside];
    [self.featuredButton addTarget:self action:@selector(displayFeaturedImojis) forControlEvents:UIControlEventTouchUpInside];
    [self.searchButton addTarget:self action:@selector(searchImojis) forControlEvents:UIControlEventTouchUpInside];
    [self.collectionsButton addTarget:self action:@selector(loadCollections) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:title];
    [self.view addSubview:appIcon];
    [self.view addSubview:self.categoriesButton];
    [self.view addSubview:self.featuredButton];
    [self.view addSubview:self.searchButton];
    [self.view addSubview:self.collectionsButton];

    [self.view addSubview:self.imojiCollectionsView];

    [self.categoriesButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.height.equalTo(self.featuredButton);
        make.bottom.equalTo(self.featuredButton.mas_top).offset(-20.0f);
    }];
    [self.featuredButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(.65f);
        make.height.equalTo(self.view.mas_width).multipliedBy(.65f / 4.0f);
    }];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.height.equalTo(self.featuredButton);
        make.top.equalTo(self.featuredButton.mas_bottom).offset(20.0f);
    }];
    [self.collectionsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.height.equalTo(self.featuredButton);
        make.top.equalTo(self.searchButton.mas_bottom).offset(20.0f);
    }];
    [appIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.categoriesButton.mas_top).offset(-20.0f);
    }];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(appIcon.mas_top).offset(-10.0f);
    }];

    [self.imojiCollectionsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.imojiSession.delegate = self;
}

- (void)loadCollections {
    if (self.imojiSession.sessionState == IMImojiSessionStateConnectedSynchronized) {
        self.imojiCollectionsView.hidden = NO;
        [self.imojiCollectionsView.collectionView loadUserCollectionImojis];
    } else {
        NSError *error;
        [self.imojiSession requestUserSynchronizationWithError:&error];

        if (error && error.code == IMImojiSessionErrorCodeImojiApplicationNotInstalled) {
            [IMImojiApplicationUtility presentApplicationDownloadViewController:self];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)hideImojiCollectionsView {
    self.imojiCollectionsView.hidden = YES;
}

- (void)displayFeaturedImojis {
    self.imojiCollectionsView.hidden = NO;
    [self.imojiCollectionsView.collectionView loadFeaturedImojis];
}

- (void)displayImojisWithSearchTerm:(NSString *)searchTerm {
    self.imojiCollectionsView.hidden = NO;
    [self.imojiCollectionsView.collectionView loadImojisFromSearch:searchTerm];
}

- (void)searchImojis {
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Search"
                                                   message:@"Enter Search Term"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Search", nil];
    view.alertViewStyle = UIAlertViewStylePlainTextInput;

    [view show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Search"]) {
        UITextField *searchTerm = [alertView textFieldAtIndex:0];
        [self displayImojisWithSearchTerm:searchTerm.text];
    }
}

- (void)displayCategories {
    self.imojiCollectionsView.hidden = NO;
    [self.imojiCollectionsView.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark ImojiSession delegate

- (void)imojiSession:(IMImojiSession *)session stateChanged:(IMImojiSessionState)newState fromState:(IMImojiSessionState)oldState {
    if (self.imojiSession.sessionState == IMImojiSessionStateConnectedSynchronized) {
        [self.collectionsButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Collections"
                                                                                  withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                                                     color:[UIColor whiteColor]
                                                                              andAlignment:NSTextAlignmentLeft]

                                          forState:UIControlStateNormal
        ];
    } else {
        [self.collectionsButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Authenticate Account"
                                                                                  withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                                                     color:[UIColor whiteColor]
                                                                              andAlignment:NSTextAlignmentLeft]

                                          forState:UIControlStateNormal
        ];
    }
}

@end
