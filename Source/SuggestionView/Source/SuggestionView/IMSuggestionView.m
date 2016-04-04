//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import <ImojiSDK/IMImojiSession.h>
#import "IMSuggestionView.h"
//#import "AppDelegate.h"
#import "View+MASAdditions.h"
#import "IMSuggestionCollectionView.h"


@interface IMSuggestionView ()
@end

@implementation IMSuggestionView {

}

- (instancetype)initWithSession:(IMImojiSession *)session {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _collectionView = [[IMSuggestionCollectionView alloc] initWithSession:session];

        [self addSubview:self.collectionView];

        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];

        [(UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    }

    return self;
}

+ (instancetype)imojiSuggestionViewWithSession:(IMImojiSession *)session {
    return [[IMSuggestionView alloc] initWithSession:session];
}

@end
