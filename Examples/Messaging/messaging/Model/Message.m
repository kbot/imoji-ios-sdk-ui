//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "Message.h"
#import "IMImojiObject.h"


@implementation Message {

}

- (instancetype)initWithText:(NSString *)text sender:(BOOL)sender {
    self = [super init];
    if (self) {
        self.text = text;
        self.sender = sender;
    }

    return self;
}

- (instancetype)initWithImoji:(IMImojiObject *)imoji sender:(BOOL)sender {
    self = [super init];
    if (self) {
        self.imoji = imoji;
        self.sender = sender;
    }

    return self;
}

+ (instancetype)messageWithText:(NSString *)text sender:(BOOL)sender {
    return [[self alloc] initWithText:text sender:sender];
}

+ (instancetype)messageWithImoji:(IMImojiObject *)imoji sender:(BOOL)sender {
    return [[self alloc] initWithImoji:imoji sender:sender];
}

@end
