//
// Created by Nima on 4/22/15.
// Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMImojiObject;
@class IMImojiSession;


@interface ImojiDetailsView : UIView

@property(nonatomic, strong) IMImojiObject *imoji;

+ (instancetype)detailsViewWithSession:(IMImojiSession *)session;

@end
