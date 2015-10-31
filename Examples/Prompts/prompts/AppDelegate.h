//
//  AppDelegate.h
//  prompts
//
//  Created by Nima on 10/9/15.
//  Copyright © 2015 Imoji. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMImojiSession;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic, nonnull) UIWindow *window;
@property(nonatomic, strong, readonly, nonnull) IMImojiSession *session;

@end

