//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMImojiObject;


@interface Message : NSObject

@property(nonatomic, strong, nullable) NSAttributedString *text;
@property(nonatomic, assign) BOOL sender;
@property(nonatomic, assign, nullable) IMImojiObject *imoji;

+ (instancetype)messageWithImoji:(IMImojiObject *)imoji sender:(BOOL)sender;

+ (instancetype)messageWithText:(NSAttributedString *)text sender:(BOOL)sender;

@end
