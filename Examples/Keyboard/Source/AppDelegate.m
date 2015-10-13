//
//  AppDelegate.m
//  imoji-keyboard
//
//  Created by Jeff on 5/26/15.
//  Copyright (c) 2015 Jeff. All rights reserved.
//

#import "AppDelegate.h"
#import <ImojiSDK/ImojiSDK.h>
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    ViewController *vc = [[ViewController alloc] init];
    [self.window setRootViewController:vc];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
