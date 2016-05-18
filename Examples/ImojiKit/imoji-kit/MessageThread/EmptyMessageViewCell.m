//
// Created by Nima on 10/12/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <ImojiSDKUI/IMAttributeStringUtil.h>
#import "EmptyMessageViewCell.h"

NSString *const EmptyMessageViewCellReuseId = @"EmptyMessageViewCellReuseId";

@interface EmptyMessageViewCell ()
@property(nonatomic, strong) UILabel *label;
@end

@implementation EmptyMessageViewCell {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.label = [UILabel new];
//        self.label.attributedText = [IMAttributeStringUtil attributedString:@"Welcome!\n\nType a message below\n to get started"
//                                                                   withFont:[IMAttributeStringUtil defaultFontWithSize:20.f]
//                                                                      color:[UIColor colorWithWhite:.74f alpha:35.f]
//                                                               andAlignment:NSTextAlignmentCenter];
//        self.label.numberOfLines = -1;
//
//        [self addSubview:self.label];
//
//        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self);
//        }];
    }

    return self;
}


@end
