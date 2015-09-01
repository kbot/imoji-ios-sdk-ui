//
//  ViewController.m
//  imoji-keyboard
//
//  Created by Jeff on 5/26/15.
//  Copyright (c) 2015 Jeff. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel* label = [[UILabel alloc] init];
    
    label.text = @"Install the keyboard in Settings :D";
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
