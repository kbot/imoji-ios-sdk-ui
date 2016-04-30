//
//  ViewController.m
//  Collection
//
//  Created by Alex Hoang on 4/26/16.
//  Copyright © 2016 Imoji. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <ImojiSDK/ImojiSDK.h>
#import <ImojiSDKUI/IMCollectionViewController.h>
#import "ViewController.h"
#import "FullScreenViewController.h"
#import "HalfScreenViewController.h"
#import "QuarterScreenViewController.h"
#import "ComboViewController.h"
#import "AppDelegate.h"

NSString *const SampleAppsCollectionTableViewCellReuseId = @"SampleAppsCollectionTableViewCellReuseId";

typedef NS_ENUM(NSUInteger, SampleAppsType) {
    SampleAppsTypeFullScreen,
    SampleAppsTypeHalfScreen,
    SampleAppsTypeQuarterScreen,
    SampleAppsTypeComboScreen
};

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) IMImojiSession *imojiSession;
@property(nonatomic, strong) UITableView *sampleAppsTableView;
@property(nonatomic, strong) NSMutableArray *sampleApps;

@end

@implementation ViewController


- (void)loadView {
    [super loadView];

    _imojiSession = ((AppDelegate *)[UIApplication sharedApplication].delegate).session;

    self.sampleApps = [@[@(SampleAppsTypeFullScreen), @(SampleAppsTypeHalfScreen), @(SampleAppsTypeQuarterScreen), @(SampleAppsTypeComboScreen)] mutableCopy];

    self.sampleAppsTableView = [[UITableView alloc] init];
    self.sampleAppsTableView.dataSource = self;
    self.sampleAppsTableView.delegate = self;

    [self.view addSubview:self.sampleAppsTableView];

    [self.sampleAppsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.sampleAppsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SampleAppsCollectionTableViewCellReuseId];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sampleApps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SampleAppsCollectionTableViewCellReuseId];

    SampleAppsType appsType = (SampleAppsType) [self.sampleApps[(NSUInteger) indexPath.row] unsignedIntValue];
    switch(appsType) {
        case SampleAppsTypeFullScreen:
            cell.textLabel.text = @"Full Screen";
            break;
        case SampleAppsTypeHalfScreen:
            cell.textLabel.text = @"Half Screen";
            break;
        case SampleAppsTypeQuarterScreen:
            cell.textLabel.text = @"Quarter Screen";
            break;
        case SampleAppsTypeComboScreen:
            cell.textLabel.text = @"Combo Screen";
            break;
        default:
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *controller = nil;

    SampleAppsType appsType = (SampleAppsType) [self.sampleApps[(NSUInteger) indexPath.row] unsignedIntValue];
    switch(appsType) {
        case SampleAppsTypeFullScreen:
            controller = [[FullScreenViewController alloc] initWithSession:self.imojiSession];
            break;
        case SampleAppsTypeHalfScreen:
            controller = [[HalfScreenViewController alloc] init];
            break;
        case SampleAppsTypeQuarterScreen:
            controller = [[QuarterScreenViewController alloc] init];
            break;
        case SampleAppsTypeComboScreen:
            controller = [[ComboViewController alloc] init];
            break;
        default:
            break;
    }

    [self presentViewController:controller animated:YES completion:^{
        [self.sampleAppsTableView deselectRowAtIndexPath:indexPath animated:NO];
    }];
}

@end
