//
// Created by Nima on 4/22/15.
// Copyright (c) 2015 Nima Khoshini. All rights reserved.
//

#import <Masonry/View+MASAdditions.h>
#import <ImojiSDK/IMImojiObject.h>
#import <ImojiSDK/IMImojiSession.h>
#import "ImojiDetailsView.h"
#import "ImojiTextUtil.h"


@interface ImojiDetailsView ()
@property(nonatomic, strong) UIImageView *imojiView;
@property(nonatomic, strong) IMImojiSession *session;
@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, strong) UILabel *tags;
@end

@implementation ImojiDetailsView {

}

- (instancetype)initWithSession:(IMImojiSession *)session {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.session = session;
        [self setup];
    }

    return self;
}

- (void)setup {
    self.imojiView = [UIImageView new];
    self.imojiView.contentMode = UIViewContentModeScaleAspectFit;

    self.tags = [UILabel new];

    if (NSClassFromString(@"UIVisualEffectView")) {
        self.backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    } else {
        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:.8f];
    }

    [self addSubview:self.backgroundView];
    [self addSubview:self.imojiView];
    [self addSubview:self.tags];

    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.imojiView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.height.and.width.equalTo(self.mas_width).multipliedBy(.75f);
    }];

    [self.tags mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(self.imojiView);
        make.height.equalTo(self).multipliedBy(.25f);
        make.top.equalTo(self.imojiView.mas_bottom).offset(10.0f);
    }];
    self.tags.numberOfLines = 5;
}

- (void)setImoji:(IMImojiObject *)imoji {
    self.imojiView.image = nil;
    self.tags.text = @"";

    _imoji = imoji;

    [self.session renderImoji:_imoji
                      options:[IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeFullResolution]
                     callback:^(UIImage *image, NSError *error) {
                         if (!error) {
                             self.imojiView.image = image;
                             if (imoji.tags && imoji.tags.count > 0) {
                                 NSMutableString *tags = [NSMutableString stringWithString:@"#"];
                                 [tags appendString:[imoji.tags componentsJoinedByString:@" #"]];
                                 self.tags.attributedText = [ImojiTextUtil attributedString:tags
                                                                               withFontSize:16.0f
                                                                                  textColor:[UIColor whiteColor]
                                                                              textAlignment:NSTextAlignmentCenter];
                             }
                         } else {
                             DDLogInfo(@"Full size imoji not available! %@", error);
                         }
                     }];
}

+ (instancetype)detailsViewWithSession:(IMImojiSession *)session {
    return [[ImojiDetailsView alloc] initWithSession:session];
}

@end
