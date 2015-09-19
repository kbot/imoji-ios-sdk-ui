//
//  ViewController.m
//  imoji-categories
//
//  Created by Nima on 9/18/15.
//  Copyright © 2015 Imoji. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <ImojiSDK/ImojiSDK.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import <ImojiSDKUI/IMCollectionViewController.h>
#import <ImojiSDKUI/IMCollectionView.h>
#import "ViewController.h"

@interface ViewController () <IMCollectionViewDelegate>

@property(nonatomic, strong) UIButton *reactionsButton;
@property(nonatomic, strong) UIButton *trendingButton;
@property(nonatomic, strong) IMImojiSession *imojiSession;

@end

@implementation ViewController



- (void)loadView {
    [super loadView];

    _imojiSession = [IMImojiSession imojiSession];

    UILabel *title = [UILabel new];
    self.reactionsButton = [UIButton new];
    self.trendingButton = [UIButton new];

    self.view.backgroundColor = [UIColor colorWithRed:249.0f / 255.0f
                                                green:249.0f / 255.0f
                                                 blue:249.0f / 255.0f
                                                alpha:1.0f];

    self.reactionsButton.backgroundColor =
            self.trendingButton.backgroundColor =
                    [UIColor colorWithRed:44.0f / 255.0f
                                    green:168.0f / 255.0f
                                     blue:224.0f / 255.0f
                                    alpha:1.0f];

    self.reactionsButton.layer.cornerRadius = self.trendingButton.layer.cornerRadius = 5.0f;

    title.attributedText = [IMAttributeStringUtil attributedString:@"Imoji Categories"
                                                          withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                             color:[UIColor colorWithRed:120.0f / 255.0f
                                                                                   green:120.0f / 255.0f
                                                                                    blue:120.0f / 255.0f
                                                                                   alpha:1.0f]
                                                      andAlignment:NSTextAlignmentLeft
    ];

    [self.reactionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.trendingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.reactionsButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Reactions"
                                                                            withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                                               color:[UIColor whiteColor]
                                                                        andAlignment:NSTextAlignmentLeft]
                                    forState:UIControlStateNormal
    ];

    [self.trendingButton setAttributedTitle:[IMAttributeStringUtil attributedString:@"Trending"
                                                                           withFont:[IMAttributeStringUtil defaultFontWithSize:20.0f]
                                                                              color:[UIColor whiteColor]
                                                                       andAlignment:NSTextAlignmentLeft]

                                   forState:UIControlStateNormal
    ];

    [self.reactionsButton addTarget:self action:@selector(displayReactions) forControlEvents:UIControlEventTouchUpInside];
    [self.trendingButton addTarget:self action:@selector(displayTrending) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:title];
    [self.view addSubview:self.reactionsButton];
    [self.view addSubview:self.trendingButton];

    [self.reactionsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.width.height.equalTo(self.trendingButton);
        make.bottom.equalTo(self.trendingButton.mas_top).offset(-20.0f);
    }];
    [self.trendingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(.65f);
        make.height.equalTo(self.view.mas_width).multipliedBy(.65f / 4.0f);
    }];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.reactionsButton.mas_top).offset(-10.0f);
    }];
    
    self.title = @"Categories";
}

- (void)displayReactions {
    IMCollectionViewController *viewController = [IMCollectionViewController collectionViewControllerWithSession:self.imojiSession];
    viewController.collectionView.collectionViewDelegate = self;
    viewController.modalPresentationStyle = UIModalPresentationPopover;
    viewController.searchField.hidden = YES;

    [self presentViewController:viewController animated:YES completion:^{
        [viewController.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationGeneric];
        [viewController updateViewConstraints];
    }];
}

- (void)displayTrending {
    IMCollectionViewController *viewController = [IMCollectionViewController collectionViewControllerWithSession:self.imojiSession];
    viewController.collectionView.collectionViewDelegate = self;
    viewController.modalPresentationStyle = UIModalPresentationPopover;
    viewController.searchField.hidden = YES;

    [self presentViewController:viewController animated:YES completion:^{
        [viewController.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationTrending];
        [viewController updateViewConstraints];
    }];
}

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category fromCollectionView:(IMCollectionView *)collectionView {
    [collectionView loadImojisFromSearch:category.identifier];
}

@end
