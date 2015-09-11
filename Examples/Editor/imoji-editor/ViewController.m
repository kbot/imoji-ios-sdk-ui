//
//  ViewController.m
//  imoji-editor
//
//  Created by Nima Khoshini on 9/4/15.
//  Copyright (c) 2015 Imoji. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithSourceImage:[UIImage imageNamed:@"big-big-dog.jpg"]];

    if (self) {
        // nothing really to do :(
    }

    return self;
}

@end
