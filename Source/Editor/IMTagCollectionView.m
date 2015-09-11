//
//  ImojiSDKUI
//
//  Created by Nima Khoshini
//  Copyright (C) 2015 Imoji
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import <Masonry/Masonry.h>
#import "IMTagCollectionView.h"
#import "IMTagCollectionViewCell.h"

@interface IMTagCollectionView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITextFieldDelegate>

@end

NSString *const IMTagCollectionViewHeaderReuseId = @"IMTagCollectionViewHeaderReuseId";
NSString *const IMTagCollectionViewCellReuseId = @"IMTagCollectionViewCellReuseId";

@implementation IMTagCollectionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame collectionViewLayout:[UICollectionViewFlowLayout new]];
    if (self) {
        self.delegate = self;
        self.dataSource = self;

        self.backgroundColor = [UIColor clearColor];

        [self registerClass:[IMTagCollectionViewCell class]
 forCellWithReuseIdentifier:IMTagCollectionViewCellReuseId];

        [self registerClass:[UICollectionReusableView class]
 forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
        withReuseIdentifier:IMTagCollectionViewHeaderReuseId];

        [self setContentInset:UIEdgeInsetsMake(0, 10, 0, 10)];

        _tags = [NSMutableOrderedSet orderedSet];
    }

    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    IMTagCollectionViewCell *viewCell = (IMTagCollectionViewCell *) [self dequeueReusableCellWithReuseIdentifier:IMTagCollectionViewCellReuseId
                                                                                                    forIndexPath:indexPath];

    NSUInteger tagIndex = (NSUInteger) indexPath.row;
    viewCell.tagContents = self.tags[tagIndex];
    viewCell.removeButton.tag = tagIndex;

    if (!viewCell.removeButton.allTargets || viewCell.removeButton.allTargets.count == 0) {
        [viewCell.removeButton addTarget:self
                                  action:@selector(removeTag:)
                        forControlEvents:UIControlEventTouchUpInside];
    }

    viewCell.textView.textColor = [UIColor whiteColor];

    return viewCell;
}

- (CGSize)       collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.frame.size.width, 50.f);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([UICollectionElementKindSectionHeader isEqualToString:kind]) {
        UICollectionReusableView *view = [self dequeueReusableSupplementaryViewOfKind:kind
                                                                  withReuseIdentifier:IMTagCollectionViewHeaderReuseId
                                                                         forIndexPath:indexPath];


        if (view.subviews.count == 0) {
            UITextField *textField = [UITextField new];

            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.layer.borderColor = [UIColor whiteColor].CGColor;
            textField.returnKeyType = UIReturnKeyDone;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;

            textField.delegate = self;

            [view addSubview:textField];
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(view).insets(UIEdgeInsetsMake(10, 0, 10, 0));
            }];
        }

        return view;
    }

    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [IMTagCollectionViewCell sizeThatFitsTag:self.tags[((NSUInteger) indexPath.row)]
                                            andSize:CGSizeMake(self.frame.size.width / 3.0f, CGFLOAT_MAX)];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f);
}

- (CGFloat)               collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *tag = textField.text;

    [(NSMutableOrderedSet *) self.tags insertObject:tag atIndex:0];

    textField.text = @"";

    [self reloadData];

    [textField becomeFirstResponder];

    return YES;
}

- (void)removeTag:(UIButton *)button {
    [(NSMutableOrderedSet *) self.tags removeObjectAtIndex:(NSUInteger) button.tag];
    [self reloadData];
}

@end
