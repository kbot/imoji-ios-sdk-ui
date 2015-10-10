//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "ImojiSuggestionView.h"
#import "IMCollectionView.h"
#import "AppDelegate.h"
#import "View+MASAdditions.h"


@interface ImojiSuggestionView ()
@end

@implementation ImojiSuggestionView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _collectionView = [IMCollectionView imojiCollectionViewWithSession:((AppDelegate *)[UIApplication sharedApplication].delegate).session];

        [self addSubview:self.collectionView];

        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }

    return self;
}

@end
