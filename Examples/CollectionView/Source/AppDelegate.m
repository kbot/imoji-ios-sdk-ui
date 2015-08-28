//
//  AppDelegate.m
//  imoji-sdk-sample
//
//  Created by Nima on 4/6/15.
//  Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import <ImojiSDK/ImojiSyncSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // setup imoji sdk
    [[ImojiSDK sharedInstance] setClientId:[[NSUUID alloc] initWithUUIDString:@"748cddd4-460d-420a-bd42-fcba7f6c031b"]
                                  apiToken:@"U2FsdGVkX1/yhkvIVfvMcPCALxJ1VHzTt8FPZdp1vj7GIb+fsdzOjyafu9MZRveo7ebjx1+SKdLUvz8aM6woAw=="];

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    IMImojiSession *imojiSession = ((MainViewController *)self.window.rootViewController).imojiSession;
    if ([imojiSession isImojiAppRequest:url sourceApplication:sourceApplication]) {
        return [imojiSession handleImojiAppRequest:url sourceApplication:sourceApplication];
    }

    return NO;
}

@end
