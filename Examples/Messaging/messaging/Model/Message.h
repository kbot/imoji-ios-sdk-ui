//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMImojiObject;


@interface Message : NSObject

@property(nonatomic, strong, nullable) NSAttributedString *text;
@property(nonatomic, assign) BOOL sender;
@property(nonatomic, strong, nullable) IMImojiObject *imoji;

+ (nonnull instancetype)messageWithImoji:(nonnull IMImojiObject *)imoji sender:(BOOL)sender;

+ (nonnull instancetype)messageWithText:(nonnull NSAttributedString *)text sender:(BOOL)sender;

@end
