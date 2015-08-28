//
//  ViewController.h
//  imoji-sample
//
//  Created by Nima on 4/6/15.
//  Copyright (c) 2015 Builds, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMImojiSession;

@interface MainViewController : UIViewController

@property(nonatomic, strong, readonly) IMImojiSession *imojiSession;

@end

