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
#import "UICollectionViewLeftAlignedLayout.h"
#import "IMCreateImojiUITheme.h"
#import "IMAttributeStringUtil.h"
#import "IMResourceBundleUtil.h"

@interface IMTagCollectionView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITextFieldDelegate>

@end

UIEdgeInsets const IMTagCollectionViewTagFieldInsets = {10, 0, 10, 0};
NSString *const IMTagCollectionViewHeaderReuseId = @"IMTagCollectionViewHeaderReuseId";
NSString *const IMTagCollectionViewCellReuseId = @"IMTagCollectionViewCellReuseId";

@implementation IMTagCollectionView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame collectionViewLayout:[UICollectionViewLeftAlignedLayout new]];
    if (self) {
        self.delegate = self;
        self.dataSource = self;

        self.backgroundColor = [UIColor clearColor];

        [self registerClass:[IMTagCollectionViewCell class]
 forCellWithReuseIdentifier:IMTagCollectionViewCellReuseId];

        [self registerClass:[UICollectionReusableView class]
 forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
        withReuseIdentifier:IMTagCollectionViewHeaderReuseId];

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

        viewCell.textView.textColor = [IMCreateImojiUITheme instance].tagScreenTagFontColor;
        viewCell.backgroundColor = [IMCreateImojiUITheme instance].tagScreenTagFieldBackgroundColor;
        viewCell.layer.borderWidth = [IMCreateImojiUITheme instance].tagScreenTagFieldBorderWidth;
        viewCell.layer.cornerRadius = [IMCreateImojiUITheme instance].tagScreenTagFieldCornerRadius;
        viewCell.layer.borderColor = [IMCreateImojiUITheme instance].tagScreenTagItemBorderColor.CGColor;
    }

    return viewCell;
}

- (CGSize)       collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {

    CGFloat tagCollectionViewHeight = [IMTagCollectionViewCell sizeThatFitsTag:@"" andSize:self.frame.size].height;

    return CGSizeMake(self.frame.size.width, IMTagCollectionViewTagFieldInsets.top + IMTagCollectionViewTagFieldInsets.bottom + tagCollectionViewHeight);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([UICollectionElementKindSectionHeader isEqualToString:kind]) {
        UICollectionReusableView *view = [self dequeueReusableSupplementaryViewOfKind:kind
                                                                  withReuseIdentifier:IMTagCollectionViewHeaderReuseId
                                                                         forIndexPath:indexPath];


        if (view.subviews.count == 0) {
            UITextField *textField = [UITextField new];

            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.backgroundColor = [IMCreateImojiUITheme instance].tagScreenTagFieldBackgroundColor;
            textField.layer.borderWidth = [IMCreateImojiUITheme instance].tagScreenTagFieldBorderWidth;
            textField.layer.cornerRadius = [IMCreateImojiUITheme instance].tagScreenTagFieldCornerRadius;
            textField.layer.borderColor = [IMCreateImojiUITheme instance].tagScreenTagItemBorderColor.CGColor;

            textField.returnKeyType = UIReturnKeyDone;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;

            textField.delegate = self;
            UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,
                    [IMCreateImojiUITheme instance].tagScreenRemoveTagIcon.size.width + 5.0f,
                    [IMCreateImojiUITheme instance].tagScreenRemoveTagIcon.size.height
            )];

            [clearButton setImage:[IMCreateImojiUITheme instance].tagScreenRemoveTagIcon forState:UIControlStateNormal];
            [clearButton addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];

            textField.rightView = clearButton;
            textField.rightViewMode = UITextFieldViewModeWhileEditing;
            textField.defaultTextAttributes = @{
                    NSFontAttributeName : [IMCreateImojiUITheme instance].tagScreenTagFont,
                    NSForegroundColorAttributeName : [IMCreateImojiUITheme instance].tagScreenTagFontColor
            };

            textField.attributedPlaceholder = [IMAttributeStringUtil attributedString:[IMResourceBundleUtil localizedStringForKey:@"tagScreenInputPlaceholder"]
                                                                             withFont:[IMCreateImojiUITheme instance].tagScreenTagFont
                                                                                color:[IMCreateImojiUITheme instance].tagScreenPlaceHolderFontColor];


            [view addSubview:textField];
            [textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(view).insets(IMTagCollectionViewTagFieldInsets);
            }];

            if (self.tagInputFieldShouldBeFirstResponder) {
                __weak typeof(textField) weakField = textField;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakField) {
                        [weakField becomeFirstResponder];
                    }
                });
            }
        }

        return view;
    }

    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [super layoutAttributesForItemAtIndexPath:indexPath];
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
    return [IMCreateImojiUITheme instance].tagScreenTagItemInsets;
}

- (CGFloat)               collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [IMCreateImojiUITheme instance].tagScreenTagItemInterspacingDistance;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *tag = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    textField.text = @"";

    if (tag.length > 0 && [self.tags indexOfObject:tag] == NSNotFound) {
        [(NSMutableOrderedSet *) self.tags insertObject:tag atIndex:0];
        [self performBatchUpdates:^{
                    [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
                    for (int i = 0; i < self.tags.count - 1; ++i) {
                        [self moveItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]
                                      toIndexPath:[NSIndexPath indexPathForItem:(i + 1) inSection:0]];
                    }
                }
                       completion:nil
        ];
    }

    return NO;
}

- (void)clearTextField:(id)target {
    if ([target isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *) target;
        if ([view.superview isKindOfClass:[UITextField class]]) {
            ((UITextField *) view.superview).text = nil;
        }
    }
}

- (void)removeTag:(UIButton *)button {
    NSUInteger index = [self.tags indexOfObject:((IMTagCollectionViewCell *) button.superview).tagContents];
    [(NSMutableOrderedSet *) self.tags removeObjectAtIndex:(NSUInteger) index];

    [self performBatchUpdates:^{
                [self deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
                for (NSUInteger i = index + 1; i < self.tags.count + 1; ++i) {
                    [self moveItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]
                                  toIndexPath:[NSIndexPath indexPathForItem:i - 1 inSection:0]];
                }
            }
                   completion:nil
    ];
}


- (void)setTagInputFieldShouldBeFirstResponder:(BOOL)tagInputFieldShouldBeFirstResponder {
    _tagInputFieldShouldBeFirstResponder = tagInputFieldShouldBeFirstResponder;
    [self reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

@end
