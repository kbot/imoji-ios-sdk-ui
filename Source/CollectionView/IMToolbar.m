//
//  ImojiSDKUI
//
//  Created by Alex Hoang
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

#import "IMToolbar.h"
#import "IMResourceBundleUtil.h"

NSUInteger const IMToolbarDefaultButtonItemWidthAndHeight = 40;

@implementation IMToolbar {

}

@dynamic delegate;

- (instancetype)initImojiToolbar {
    self = [super init];
    if (self) {
        self.imageBundle = [IMResourceBundleUtil assetsBundle];
        self.items = [[NSArray alloc] init];
    }

    return self;
}

- (nonnull UIBarButtonItem *)addToolbarButtonWithType:(IMToolbarButtonType)buttonType {
    UIImage *image, *activeImage;

    switch (buttonType) {
        case IMToolbarButtonSearch:
            image = [UIImage imageNamed:@"toolbar_search" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            activeImage = [UIImage imageNamed:@"toolbar_search_active" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            break;
        case IMToolbarButtonRecents:
            image = [UIImage imageNamed:@"toolbar_recents" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            activeImage = [UIImage imageNamed:@"toolbar_recents_active" inBundle:self.imageBundle compatibleWithTraitCollection:nil];

            break;
        case IMToolbarButtonReactions:
            image = [UIImage imageNamed:@"toolbar_reactions" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            activeImage = [UIImage imageNamed:@"toolbar_reactions_active" inBundle:self.imageBundle compatibleWithTraitCollection:nil];

            break;
        case IMToolbarButtonTrending:
            image = [UIImage imageNamed:@"toolbar_trending" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            activeImage = [UIImage imageNamed:@"toolbar_trending_active" inBundle:self.imageBundle compatibleWithTraitCollection:nil];

            break;
        case IMToolbarButtonCollection:
            image = [UIImage imageNamed:@"toolbar_collection" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            activeImage = [UIImage imageNamed:@"toolbar_collection_active" inBundle:self.imageBundle compatibleWithTraitCollection:nil];

            break;
        default:
            return nil;
    }

    return [self addToolbarButtonWithType:buttonType
                                    image:image
                              activeImage:activeImage];
}

- (nonnull UIBarButtonItem *)addToolbarButtonWithType:(IMToolbarButtonType)buttonType
                                                image:(nonnull UIImage *)image
                                          activeImage:(nullable UIImage *)activeImage {
    
    return [self addToolbarButtonWithType:buttonType
                                    image:image
                              activeImage:activeImage
                                    width:IMToolbarDefaultButtonItemWidthAndHeight];
}

- (nonnull UIBarButtonItem *)addToolbarButtonWithType:(IMToolbarButtonType)buttonType
                                                image:(nonnull UIImage *)image
                                          activeImage:(nullable UIImage *)activeImage
                                                width:(CGFloat)width {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setImage:image forState:UIControlStateNormal];
    if (activeImage) {
        [button setImage:activeImage forState:UIControlStateSelected];
    }
    
    button.frame = CGRectMake(0, 0, width, width);
    button.tag = buttonType;
    
    [button addTarget:self action:@selector(imojiToolbarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *toolbarButton;
    toolbarButton = [[UIBarButtonItem alloc] initWithCustomView:button];

    NSMutableArray *items = [NSMutableArray arrayWithArray:self.items];

    if (items.count > 0) {
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    }

    [items addObject:toolbarButton];

    self.items = items;
    
    return toolbarButton;
}

- (void)selectButtonOfType:(IMToolbarButtonType)buttonType {
    for (UIBarButtonItem* barButtonItem in self.items) {
        if (barButtonItem.customView && barButtonItem.customView.tag == buttonType) {
            [self imojiToolbarButtonTapped:(UIButton*) barButtonItem.customView];
            break;
        }
    }
}

- (void)imojiToolbarButtonTapped:(UIButton *)sender {
    for (UIBarButtonItem *item in self.items) {
        ((UIButton *) item.customView).selected = NO;
    }

    sender.selected = YES;

    // run action
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidSelectToolbarButton:)]) {
        [self.delegate userDidSelectToolbarButton:(IMToolbarButtonType) sender.tag];
    }
}

+ (instancetype)imojiToolbar {
    return [[IMToolbar alloc] initImojiToolbar];
}

@end
