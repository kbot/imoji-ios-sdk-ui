//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "MessageThreadView.h"
#import "MessageViewCell.h"
#import "Message.h"

@interface MessageThreadView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) NSMutableArray *data;
@end

@implementation MessageThreadView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame collectionViewLayout:[UICollectionViewFlowLayout new]];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.data = [NSMutableArray new];

        self.backgroundColor = [UIColor whiteColor];
        [self registerClass:[MessageViewCell class] forCellWithReuseIdentifier:MessageViewCellReuseId];
    }

    return self;
}

#pragma mark Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MessageViewCell *cell =
            (MessageViewCell *) [self dequeueReusableCellWithReuseIdentifier:MessageViewCellReuseId forIndexPath:indexPath];

    Message* message = self.data[(NSUInteger) indexPath.row];

    cell.message = message;

    return cell;
}

#pragma mark Flow delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    Message* message = self.data[(NSUInteger) indexPath.row];
    return [MessageViewCell estimatedSize:self.frame.size forMessage:message];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 0, 5, 0);
}

#pragma mark Public Methods

- (void)appendMessage:(nonnull Message *)message {
    [self.data addObject:message];

    __block NSIndexPath *newPath = [NSIndexPath indexPathForItem:self.data.count - 1 inSection:0];
    [self performBatchUpdates:^{
        [self insertItemsAtIndexPaths:@[newPath]];
    } completion:^(BOOL finished) {
        [self scrollToItemAtIndexPath:newPath
                     atScrollPosition:UICollectionViewScrollPositionBottom
                             animated:YES];
    }];
}

@end
