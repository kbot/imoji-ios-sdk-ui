//
// Created by Nima on 7/20/15.
// Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const IMCollectionViewStatusCellReuseId;

@interface IMCollectionViewStatusCell : UICollectionViewCell

@property(nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property(nonatomic, strong) UILabel *title;

- (void)showLoading;

- (void)showNoResults;

@end
