//
//  AppDelegate.h
//  Collection
//
//  Created by Alex Hoang on 4/26/16.
//  Copyright © 2016 Imoji. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMImojiSession;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic, nonnull) UIWindow *window;
@property(nonatomic, strong, readonly, nonnull) IMImojiSession *session;

@end

