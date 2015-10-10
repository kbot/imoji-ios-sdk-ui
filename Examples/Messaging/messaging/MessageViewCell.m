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
@property(nonatomic, strong) UITextView *textView;
@end

@implementation MessageViewCell {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textView = [UITextView new];
        self.textView.layer.cornerRadius = 6.f;

        [self addSubview:self.textView];
    }

    return self;
}

- (void)setMessage:(Message *)message {
    self.textView.attributedText = message.text;

    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (message.sender) {
            make.right.equalTo(self).offset(MessageViewCellInsets.right * -1);
        } else {
            make.left.equalTo(self).offset(MessageViewCellInsets.left);
        }

        make.top.height.equalTo(self);

        if (message.imoji) {
            make.width.equalTo(@(MessageViewPreferredImojiSize.width));
        } else {
            CGSize size = [message.text.string sizeWithAttributes:@{
                    NSFontAttributeName : [IMAttributeStringUtil defaultFontWithSize:16.f]
            }];

            make.width.equalTo(@(size.width + (message.sender ? MessageViewCellInsets.right : MessageViewCellInsets.left)));
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
        self.textView.backgroundColor = [UIColor clearColor];
    } else {
        self.textView.font = [IMAttributeStringUtil defaultFontWithSize:16.f];
        self.textView.textColor = [UIColor whiteColor];

        self.textView.backgroundColor = message.sender ? [UIColor blueColor] : [UIColor greenColor];
    }
}

+ (CGSize)estimatedSize:(CGSize)maximumSize forMessage:(Message *)message {
    if (message.imoji) {
        return CGSizeMake(maximumSize.width, MessageViewPreferredImojiSize.height + 10.0f);
    } else {
        CGSize size = [message.text.string sizeWithAttributes:@{
                NSFontAttributeName : [IMAttributeStringUtil defaultFontWithSize:16.f]
        }];
        return CGSizeMake(maximumSize.width, size.height*2);
    }
}

- (void)loadImageIntoTextView:(UIImage *)image {
    NSTextAttachment *attachment = [NSTextAttachment new];
    attachment.image = image;
    self.textView.attributedText = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
}

@end
