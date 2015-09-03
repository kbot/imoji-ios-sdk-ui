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
    [[ImojiSDK sharedInstance] setClientId:[[NSUUID alloc] initWithUUIDString:@"748cddd4-460d-420a-bd42-fcba7f6c031b"]
                                  apiToken:@"U2FsdGVkX1/yhkvIVfvMcPCALxJ1VHzTt8FPZdp1vj7GIb+fsdzOjyafu9MZRveo7ebjx1+SKdLUvz8aM6woAw=="];
    
    self = [super initWithImojiSession:[IMImojiSession imojiSession]];
    if (self) {
        
    }
    
    return self;
}

@end
