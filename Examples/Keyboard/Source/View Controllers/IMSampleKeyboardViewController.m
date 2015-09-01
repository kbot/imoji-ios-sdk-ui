//
//  IMSampleKeyboardViewController.m
//  imoji-keyboard
//
//  Created by Nima on 8/31/15.
//  Copyright © 2015 Jeff. All rights reserved.
//

#import "IMSampleKeyboardViewController.h"

@implementation IMSampleKeyboardViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    [[ImojiSDK sharedInstance] setClientId:[[NSUUID alloc] initWithUUIDString:@"a5908b99-c9b6-4661-9dfb-5c9ff4860c80"] apiToken:@"U2FsdGVkX1+FJ8PuT09YF1Ypf/yMWuFFGW885/rhgj8="];
    
    self = [super initWithImojiSession:[IMImojiSession imojiSession]];
    if (self) {
        
    }
    
    return self;
}

@end
