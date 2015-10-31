//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "MessageViewCell.h"
#import "View+MASAdditions.h"
#import "Message.h"
#import "AppDelegate.h"
#import "IMImojiSession.h"
#import "IMAttributeStringUtil.h"

NSString *const MessageViewCellReuseId = @"MessageViewCellReuseId";
CGSize const MessageViewPreferredImojiSize = {100.f, 100.f};
UIEdgeInsets const MessageViewCellInsets = {0.f, 10.f, 0, 10.f};

@interface MessageViewCell ()
@property(nonatomic, strong) UILabel *label;
@end

@implementation MessageViewCell {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [UILabel new];
        self.label.layer.cornerRadius = 6.f;
        self.label.clipsToBounds = YES;

        [self addSubview:self.label];
    }

    return self;
}

- (void)setMessage:(Message *)message {
    if (message.text) {
        self.label.attributedText = [IMAttributeStringUtil attributedString:message.text
                                                                   withFont:[MessageViewCell MessageViewTextFont]
                                                                      color:[UIColor whiteColor]
                                                               andAlignment:NSTextAlignmentCenter];
    }

    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (message.sender) {
            make.right.equalTo(self).offset(MessageViewCellInsets.right * -1);
        } else {
            make.left.equalTo(self).offset(MessageViewCellInsets.left);
        }

        make.top.height.equalTo(self);

        if (message.imoji) {
            make.width.equalTo(@(MessageViewPreferredImojiSize.width));
        } else {
            CGSize size = [message.text sizeWithAttributes:@{
                    NSFontAttributeName : [MessageViewCell MessageViewTextFont]
            }];

            make.width.equalTo(@(size.width + MessageViewCellInsets.left + MessageViewCellInsets.right));
        }
    }];

    if (message.imoji) {
        IMImojiObjectRenderingOptions *options =
                [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail];
        options.targetSize = [NSValue valueWithCGSize:CGSizeMake(MessageViewPreferredImojiSize.width * [UIScreen mainScreen].scale, MessageViewPreferredImojiSize.height * [UIScreen mainScreen].scale)];

        [((AppDelegate *) [UIApplication sharedApplication].delegate).session renderImoji:message.imoji
                                                                                  options:options
                                                                                 callback:^(UIImage *image, NSError *error) {
                                                                                     if (image) {
                                                                                         [self loadImageIntoTextView:image];
                                                                                     }
                                                                                 }];
        self.label.backgroundColor = [UIColor clearColor];
    } else {
        self.label.font = [MessageViewCell MessageViewTextFont];
        self.label.textColor = [UIColor whiteColor];

        self.label.backgroundColor = message.sender ? [MessageViewCell MessageViewSenderColor] : [MessageViewCell MessageViewRecipientColor];
    }
}

+ (CGSize)estimatedSize:(CGSize)maximumSize forMessage:(Message *)message {
    if (message.imoji) {
        return CGSizeMake(maximumSize.width, MessageViewPreferredImojiSize.height);
    } else {
        CGSize size = [message.text sizeWithAttributes:@{
                NSFontAttributeName : [MessageViewCell MessageViewTextFont]
        }];
        return CGSizeMake(maximumSize.width, size.height * 2);
    }
}

- (void)loadImageIntoTextView:(UIImage *)image {
    NSTextAttachment *attachment = [NSTextAttachment new];
    attachment.image = image;
    self.label.attributedText = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
}

+ (UIColor *)MessageViewSenderColor {
    return [UIColor colorWithRed:55.0f / 255.0f green:123.0f / 255.0f blue:167.0f / 255.0f alpha:1.0f];
}

+ (UIColor *)MessageViewRecipientColor {
    return [UIColor colorWithRed:81.0f / 255.0f green:185.0f / 255.0f blue:197.0f / 255.0f alpha:1.0f];
}

+ (UIFont *)MessageViewTextFont {
    return [IMAttributeStringUtil defaultFontWithSize:16.f];
}

@end
