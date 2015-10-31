//
// Created by Nima on 10/12/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "ImojiSuggestionLoadingViewCell.h"
#import "View+MASAdditions.h"

@implementation ImojiSuggestionLoadingViewCell {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;

        [self.activityIndicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }

    return self;
}

- (void)showLoading {
    [super showLoading];
    self.title.hidden = YES;
}

- (void)showNoResults {
    [super showNoResults];
    self.title.hidden = NO;
}

@end
