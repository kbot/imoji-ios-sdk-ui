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

#import <Masonry/Masonry.h>
#import <ImojiSDK/ImojiSDK.h>
#import <ImojiSDKUI/IMCollectionViewController.h>
#import "ViewController.h"
#import "FullScreenViewController.h"
#import "HalfScreenViewController.h"
#import "QuarterScreenViewController.h"
#import "HalfAndQuarterScreenViewController.h"
#import "AppDelegate.h"
#import "IMResourceBundleUtil.h"
#import "SampleAppCollectionTableViewCell.h"

typedef NS_ENUM(NSUInteger, SampleAppType) {
    SampleAppTypeFullScreen,
    SampleAppTypeHalfAndQuarterScreen,
    SampleAppTypeHalfScreen,
    SampleAppTypeQuarterScreen
};

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *sampleAppTableView;
@property(nonatomic, strong) UIImageView *imojiLogoImageView;
@property(nonatomic, strong) NSMutableArray *sampleApps;

@end

@implementation ViewController


- (void)loadView {
    [super loadView];

    self.sampleApps = [@[@(SampleAppTypeFullScreen), @(SampleAppTypeHalfAndQuarterScreen), @(SampleAppTypeHalfScreen), @(SampleAppTypeQuarterScreen)] mutableCopy];

    self.imojiLogoImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/imoji_menu_logo.png", [IMResourceBundleUtil assetsBundle].bundlePath]]];

    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor colorWithRed:0.0f / 255.0f green:0.0f / 255.0f blue:0.0f / 255.0f alpha:0.20f];

    self.sampleAppTableView = [[UITableView alloc] init];
    self.sampleAppTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.sampleAppTableView setContentInset:UIEdgeInsetsMake(17.0f, 0.0f, 0.0f, 0.0f)];
    self.sampleAppTableView.dataSource = self;
    self.sampleAppTableView.delegate = self;

    [self.view addSubview:self.imojiLogoImageView];
    [self.view addSubview:separatorView];
    [self.view addSubview:self.sampleAppTableView];

    [self.imojiLogoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuideBottom).offset(42.0f);
        make.centerX.equalTo(self.view);
    }];

    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imojiLogoImageView.mas_bottom).offset(34.0f);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@260.0f);
        make.height.equalTo(@0.5f);
    }];

    [self.sampleAppTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(separatorView.mas_bottom);
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];

    [self.sampleAppTableView registerClass:[SampleAppCollectionTableViewCell class] forCellReuseIdentifier:SampleAppCollectionTableViewCellReuseId];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sampleApps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SampleAppCollectionTableViewCell *cell = [self.sampleAppTableView dequeueReusableCellWithIdentifier:SampleAppCollectionTableViewCellReuseId forIndexPath:indexPath];

    SampleAppType appsType = (SampleAppType) [self.sampleApps[(NSUInteger) indexPath.row] unsignedIntValue];
    switch(appsType) {
        case SampleAppTypeFullScreen:
            [cell setupWithTitle:@"Full Screen" iconImage:SampleAppCollectionIconTypeForward];
            break;
        case SampleAppTypeHalfScreen:
            [cell setupWithTitle:@"Half Screen" iconImage:SampleAppCollectionIconTypeForward];
            break;
        case SampleAppTypeQuarterScreen:
            [cell setupWithTitle:@"Quarter Screen" iconImage:SampleAppCollectionIconTypeForward];
            break;
        case SampleAppTypeHalfAndQuarterScreen:
            [cell setupWithTitle:@"Half + Quarter Screen" iconImage:SampleAppCollectionIconTypeForward];
            break;
        default:
            break;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *controller = nil;

    SampleAppType appsType = (SampleAppType) [self.sampleApps[(NSUInteger) indexPath.row] unsignedIntValue];
    switch(appsType) {
        case SampleAppTypeFullScreen:
            controller = [[FullScreenViewController alloc] initWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];
            break;
        case SampleAppTypeHalfScreen:
            controller = [[HalfScreenViewController alloc] init];
            break;
        case SampleAppTypeQuarterScreen:
            controller = [[QuarterScreenViewController alloc] init];
            break;
        case SampleAppTypeHalfAndQuarterScreen:
            controller = [[HalfAndQuarterScreenViewController alloc] init];
            break;
        default:
            break;
    }

    [self presentViewController:controller animated:YES completion:^{
        [self.sampleAppTableView deselectRowAtIndexPath:indexPath animated:NO];
    }];
}

@end
