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

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imageBundle = [IMResourceBundleUtil assetsBundle];
    }

    return self;
}

- (nonnull UIBarButtonItem *)addToolbarButtonWithType:(IMToolbarButtonType)buttonType {
    UIImage *image, *activeImage;

    switch (buttonType) {
        case IMToolbarButtonSearch:
            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_search.png", self.imageBundle.bundlePath]];
            break;
        case IMToolbarButtonRecents:
            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_recents.png", self.imageBundle.bundlePath]];
            activeImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_recents_on.png", self.imageBundle.bundlePath]];
            break;
        case IMToolbarButtonReactions:
            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_reactions.png", self.imageBundle.bundlePath]];
            activeImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_reactions_on.png", self.imageBundle.bundlePath]];
            break;
        case IMToolbarButtonTrending:
            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_trending.png", self.imageBundle.bundlePath]];
            activeImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_trending_on.png", self.imageBundle.bundlePath]];
            break;
        case IMToolbarButtonCollection:
            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_collection.png", self.imageBundle.bundlePath]];
            activeImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_collection_on.png", self.imageBundle.bundlePath]];
            break;
        case IMToolbarButtonArtist:
            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_collection.png", self.imageBundle.bundlePath]];
            activeImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_collection_on.png", self.imageBundle.bundlePath]];
            break;
        case IMToolbarButtonBack:
            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/toolbar_back.png", self.imageBundle.bundlePath]];
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

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];

    [self appendBarButtonItem:barButtonItem  withPrependedFlexibleSpace:YES];

    return barButtonItem;
}

- (nonnull UIBarButtonItem *)addSearchBarItem {
    UISearchBar *searchBar = [UISearchBar new];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];

    [self appendBarButtonItem:barButtonItem withPrependedFlexibleSpace:NO];

    return barButtonItem;
}

- (nonnull UIBarButtonItem *)addFlexibleSpace {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.items ? self.items : @[]];

    [items addObject:item];
    self.items = items;

    return item;
}

- (void)addBarButton:(nonnull UIBarButtonItem *)barButtonItem {
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.items ? self.items : @[]];
    [items addObject:barButtonItem];
    self.items = items;
}

- (void)selectButtonOfType:(IMToolbarButtonType)buttonType {
    for (UIBarButtonItem *barButtonItem in self.items) {
        if (barButtonItem.customView && barButtonItem.customView.tag == buttonType) {
            [self imojiToolbarButtonTapped:(UIButton *) barButtonItem.customView];
            break;
        }
    }
}

- (void)imojiToolbarButtonTapped:(UIButton *)sender {
    for (UIBarButtonItem *item in self.items) {
        if ([item.customView isKindOfClass:[UIButton class]]) {
            ((UIButton *) item.customView).selected = NO;
        }
    }

    sender.selected = YES;

    // run action
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidSelectToolbarButton:)]) {
        [self.delegate userDidSelectToolbarButton:(IMToolbarButtonType) sender.tag];
    }
}

- (void)appendBarButtonItem:(UIBarButtonItem *)barButtonItem withPrependedFlexibleSpace:(BOOL)withSpace {
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.items];

    if (withSpace && items.count > 0) {
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    }

    [items addObject:barButtonItem];

    self.items = items;
}

+ (instancetype)imojiToolbar {
    return [[IMToolbar alloc] init];
}

@end
