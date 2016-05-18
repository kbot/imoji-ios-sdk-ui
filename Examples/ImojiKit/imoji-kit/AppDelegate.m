//
//  AppDelegate.m
//  Collection
//
//  Created by Alex Hoang on 4/26/16.
//  Copyright © 2016 Imoji. All rights reserved.
//

#import "AppDelegate.h"
#import <ImojiSDK/ImojiSDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[ImojiSDK sharedInstance] setClientId:[[NSUUID alloc] initWithUUIDString:@"748cddd4-460d-420a-bd42-fcba7f6c031b"]
                                  apiToken:@"U2FsdGVkX1/yhkvIVfvMcPCALxJ1VHzTt8FPZdp1vj7GIb+fsdzOjyafu9MZRveo7ebjx1+SKdLUvz8aM6woAw=="];

    _session = [IMImojiSession imojiSession];

    return YES;
}

@end
