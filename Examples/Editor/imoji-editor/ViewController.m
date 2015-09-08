//
//  ViewController.m
//  imoji-editor
//
//  Created by Nima Khoshini on 9/4/15.
//  Copyright (c) 2015 Imoji. All rights reserved.
//

#import "ViewController.h"
#import "ImojiEditorContainerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    self.view = [ImojiEditorContainerView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
