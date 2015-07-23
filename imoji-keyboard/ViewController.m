//
//  ViewController.m
//  imoji-keyboard
//
//  Created by Jeff on 5/26/15.
//  Copyright (c) 2015 Jeff. All rights reserved.
//

#import "ViewController.h"
#import <ImojiSDK/ImojiSDK.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    IMImojiSession *session = [IMImojiSession imojiSession];
    //self.session.delegate = self;
    
    [session getImojiCategoriesWithClassification:IMImojiSessionCategoryClassificationGeneric
                                              callback:^(NSArray *imojiCategories, NSError *error) {
                                                 NSLog(@"got categories: %@", imojiCategories);
                                              }];
    NSLog(@"view did load");
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
