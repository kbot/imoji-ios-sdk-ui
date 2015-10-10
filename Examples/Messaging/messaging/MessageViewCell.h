//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//


@class Message;
extern NSString *const MessageViewCellReuseId;

@interface MessageViewCell : UICollectionViewCell

@property(nonatomic, strong) Message* message;

+ (CGSize)estimatedSize:(CGSize)maximumSize forMessage:(Message *)message;

@end
