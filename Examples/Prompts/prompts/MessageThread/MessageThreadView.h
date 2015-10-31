//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

@class Message;
@class IMImojiSession;
@class IMImojiObject;

@interface MessageThreadView : UICollectionView

- (void)appendMessage:(nonnull Message *)message;

- (void)scrollToBottom;

- (void)sendMessageWithText:(nonnull NSString *)text;

- (void)sendMessageWithImoji:(nonnull IMImojiObject *)imoji;

@property(nonatomic, readonly) BOOL empty;

@end
