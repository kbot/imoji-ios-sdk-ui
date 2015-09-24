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
    UIImage *image;

    switch (buttonType) {
        case IMToolbarButtonSearch:
            image = [UIImage imageNamed:@"toolbar_search" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            break;
        case IMToolbarButtonRecents:
            image = [UIImage imageNamed:@"toolbar_recents" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            break;
        case IMToolbarButtonReactions:
            image = [UIImage imageNamed:@"toolbar_reactions" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            break;
        case IMToolbarButtonTrending:
            image = [UIImage imageNamed:@"toolbar_trending" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            break;
        case IMToolbarButtonCollection:
            image = [UIImage imageNamed:@"toolbar_collection" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            break;
        case IMToolbarButtonBack:
            image = [UIImage imageNamed:@"toolbar_back" inBundle:self.imageBundle compatibleWithTraitCollection:nil];
            break;
        default:
            return nil;
    }

    return [self addToolbarButtonWithType:buttonType
                                    image:image
                              activeImage:[IMToolbar tintImage:image
                                                       toColor:[UIColor colorWithRed:10.0f / 255.0f
                                                                               green:140.0f / 255.0f
                                                                                blue:255.0f / 255.0f
                                                                               alpha:1.0f]
                              ]
    ];
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
    UIBarButtonItem *toolbarButton;
    switch (buttonType) {
        case IMToolbarSearchField: {
            UISearchBar *searchBar = [UISearchBar new];
            toolbarButton = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
        }

            break;
        default: {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

            [button setImage:image forState:UIControlStateNormal];
            if (activeImage) {
                [button setImage:activeImage forState:UIControlStateSelected];
            }

            button.frame = CGRectMake(0, 0, width, width);
            button.tag = buttonType;

            [button addTarget:self action:@selector(imojiToolbarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

            toolbarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        }
    }

    NSMutableArray *items = [NSMutableArray arrayWithArray:self.items];

    if (items.count > 0 && ((UIBarButtonItem *) items.lastObject).customView.tag > IMToolbarButtonSearch) {
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    }

    [items addObject:toolbarButton];

    self.items = items;

    return toolbarButton;
}

- (nonnull UIBarButtonItem *)addFlexibleSpace {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.items ? self.items : @[]];

    [items addObject:item];
    self.items = items;

    return item;
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
        ((UIButton *) item.customView).selected = NO;
    }

    sender.selected = YES;

    // run action
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidSelectToolbarButton:)]) {
        [self.delegate userDidSelectToolbarButton:(IMToolbarButtonType) sender.tag];
    }
}

+ (UIImage *)tintImage:(UIImage *)image toColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);

    [color setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);

    UIRectFill(bounds);
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0];

    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return tintedImage;
}

+ (instancetype)imojiToolbar {
    return [[IMToolbar alloc] init];
}

@end
