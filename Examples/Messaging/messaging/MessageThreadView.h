//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

@class Message;

@interface MessageThreadView : UICollectionView

- (void)appendMessage:(nonnull Message *)message;

@end
