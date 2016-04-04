//
// Created by Nima on 10/9/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "MessageThreadView.h"
#import "MessageViewCell.h"
#import "Message.h"
#import "EmptyMessageViewCell.h"
#import "AppDelegate.h"
#import "IMImojiSession.h"
#import "IMImojiObject.h"

@interface MessageThreadView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) NSMutableArray *data;
@property(nonatomic, strong) IMImojiSession *imojiSession;
@end

@implementation MessageThreadView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame collectionViewLayout:[UICollectionViewFlowLayout new]];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.data = [NSMutableArray new];
        self.imojiSession = ((AppDelegate *)[UIApplication sharedApplication].delegate).session;

        self.backgroundColor = [UIColor whiteColor];
        [self registerClass:[MessageViewCell class] forCellWithReuseIdentifier:MessageViewCellReuseId];
        [self registerClass:[EmptyMessageViewCell class] forCellWithReuseIdentifier:EmptyMessageViewCellReuseId];
    }

    return self;
}

#pragma mark Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.empty) {
        return 1;
    }

    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.empty) {
        return [self dequeueReusableCellWithReuseIdentifier:EmptyMessageViewCellReuseId forIndexPath:indexPath];
    }

    MessageViewCell *cell =
            (MessageViewCell *) [self dequeueReusableCellWithReuseIdentifier:MessageViewCellReuseId forIndexPath:indexPath];

    Message *message = self.data[(NSUInteger) indexPath.row];

    cell.message = message;

    return cell;
}

#pragma mark Flow delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.empty) {
        return CGSizeMake(
                self.frame.size.width - self.contentInset.left - self.contentInset.right,
                self.frame.size.height - self.contentInset.bottom - self.contentInset.top
        );
    }

    Message *message = self.data[(NSUInteger) indexPath.row];
    return [MessageViewCell estimatedSize:self.frame.size forMessage:message];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.empty) {
        return UIEdgeInsetsZero;
    }

    return UIEdgeInsetsMake(5, 0, 5, 0);
}

#pragma mark Public Methods

- (void)appendMessage:(nonnull Message *)message {
    [self.data addObject:message];

    __block NSIndexPath *newPath = [NSIndexPath indexPathForItem:self.data.count - 1 inSection:0];
    [self performBatchUpdates:^{
        if (self.data.count == 1) {
            [self deleteItemsAtIndexPaths:@[newPath]];
        }
        [self insertItemsAtIndexPaths:@[newPath]];
    } completion:^(BOOL finished) {
        [self scrollToBottom];
    }];
}

- (BOOL)empty {
    return self.data.count == 0;
}

- (void)scrollToBottom {
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.data.count - 1 inSection:0]
                 atScrollPosition:UICollectionViewScrollPositionNone
                         animated:YES];
}


#pragma mark Sending Messages (Fake)

- (void)sendMessageWithText:(nonnull NSString *)text {
    [self appendMessage:[Message messageWithText:text sender:YES]];
    [self sendFakeResponse];
}

- (void)sendMessageWithImoji:(nonnull IMImojiObject *)imoji {
    [self appendMessage:[Message messageWithImoji:imoji sender:YES]];
    [self sendFakeResponse];
}

- (void)sendFakeResponse {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 500), dispatch_get_main_queue(), ^{
        if (((NSUInteger) [NSDate date].timeIntervalSince1970) % 2 == 0) {
            [self.imojiSession getFeaturedImojisWithNumberOfResults:@1
                                          resultSetResponseCallback:^(IMImojiResultSetMetadata *resultSetMetadata, NSError *error) {

                                          }
                                              imojiResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
                                                  [self appendMessage:[Message messageWithImoji:imoji sender:NO]];
                                              }];

        } else {
            NSArray<NSString *> *fakeResponse = @[
                    @"wow",
                    @"amazing!",
                    @"lol",
                    @"omg",
                    @"I think so",
                    @"no way!"
            ];
            NSString *response = fakeResponse[((NSUInteger) [NSDate date].timeIntervalSince1970) % fakeResponse.count];

            [self appendMessage:[Message messageWithText:response
                                                  sender:NO]];
        }
    });
}


@end
