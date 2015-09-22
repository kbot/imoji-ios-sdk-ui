//
//  ImojiSDKUI
//
//  Created by Jeff Wang
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
#import "IMKeyboardViewController.h"
#import "IMKeyboardCollectionView.h"
#import "IMAttributeStringUtil.h"
#import "IMQwertyViewController.h"
#import "IMConnectivityUtil.h"
#import "IMKeyboardToolbar.h"
#import "IMKeyboardView.h"

NSString *const IMKeyboardViewControllerDefaultAppGroup = @"group.com.imoji.keyboard";

@interface IMKeyboardViewController () <IMQwertyViewControllerDelegate, IMImojiSessionDelegate, IMKeyboardViewDelegate, IMKeyboardCollectionViewDelegate, IMKeyboardToolbarDelegate>

// keyboard size
@property(nonatomic) CGFloat portraitHeight;
@property(nonatomic) CGFloat landscapeHeight;
@property(nonatomic) NSLayoutConstraint *heightConstraint;

@property(nonatomic) BOOL isViewingImojiCategory;
@property(nonatomic) IMKeyboardToolbarButtonType currentToolbarButtonSelected;

@end

@implementation IMKeyboardViewController {
    NSAttributedString *_previousTitle;
}

- (id)initWithImojiSession:(IMImojiSession *)session {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Perform custom initialization work here
        self.portraitHeight = IMKeyboardViewPortraitHeight;
        self.landscapeHeight = IMKeyboardViewLandscapeHeight;
        self.isViewingImojiCategory = NO;
        self.currentToolbarButtonSelected = IMKeyboardToolbarButtonReactions;

        _appGroup = IMKeyboardViewControllerDefaultAppGroup;

        _session = session;
        _session.delegate = self;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChange)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }

    return self;
}

- (void)deviceOrientationDidChange {
    [self updateViewConstraints];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    // Add custom view sizing constraints here
    if (self.view.frame.size.width == 0 || self.view.frame.size.height == 0) {
        return;
    }

    [self.inputView removeConstraint:self.heightConstraint];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat screenH = screenSize.height;
    CGFloat screenW = screenSize.width;
    BOOL isLandscape = self.view.frame.size.width != (screenW * (screenW < screenH)) + (screenH * (screenW > screenH));

    if (isLandscape) {
        self.heightConstraint.constant = self.landscapeHeight;
        [self.inputView addConstraint:self.heightConstraint];
    } else {
        self.heightConstraint.constant = self.portraitHeight;
        [self.inputView addConstraint:self.heightConstraint];
    }

    [((IMKeyboardView *) self.view).collectionView performBatchUpdates:nil completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    for (UIView *subview in self.view.subviews) {
        [subview removeFromSuperview];
    }

    // Constraints
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.inputView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:0.0
                                                          constant:IMKeyboardViewPortraitHeight];
    self.heightConstraint.priority = UILayoutPriorityRequired - 1; // This will eliminate the constraint conflict warning.

    // View setup
    IMKeyboardView *keyboardView = [IMKeyboardView imojiKeyboardViewWithSession:self.session
                                                                       andFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, IMKeyboardViewPortraitHeight)];
    self.view = keyboardView;
    keyboardView.delegate = self;
    keyboardView.collectionView.collectionViewDelegate = self;
    keyboardView.keyboardToolbar.delegate = self;

    // Assign qwerty controller to searchView
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IMQwerty" bundle:[NSBundle mainBundle]];
    IMQwertyViewController *vc = [storyboard instantiateInitialViewController];
    vc.searchField = keyboardView.searchField;
    vc.delegate = self;
    [self addChildViewController:vc];
    [keyboardView.searchView addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(keyboardView.searchField.mas_bottom).with.offset(0);
        make.left.equalTo(keyboardView.mas_left).with.offset(0);
        make.right.equalTo(keyboardView.mas_right).with.offset(0);
        make.bottom.equalTo(keyboardView.mas_bottom);
    }];
}

- (void)setAppGroup:(NSString *)appGroup {
    _appGroup = appGroup;
}

#pragma mark IMQwertyViewControllerDelegate

- (void)userDidPressReturnKey {
    IMKeyboardView *keyboardView = (IMKeyboardView *) self.view;
    if (keyboardView.searchField.text.length > 0) {
        keyboardView.searchView.hidden = YES;

        [keyboardView updateTitleWithText:keyboardView.searchField.text hideCloseButton:NO];

        [keyboardView.collectionView loadImojisFromSearch:keyboardView.searchField.text];
        for (int i = 1; i < 6; i++) { // loop through all buttons and deselect them
            ((UIButton *) [keyboardView viewWithTag:i]).selected = i == 1;
        }
    }
}

#pragma mark IMKeyboardViewDelegate

- (void)userDidCloseCategoryFromView:(IMKeyboardView *)view {
    self.isViewingImojiCategory = NO;

    // Display previous category
    [view.collectionView loadImojiCategories:view.currentCategoryClassification];
}

#pragma mark IMKeyboardCollectionViewDelegate

- (void)userDidSelectCategory:(IMImojiCategoryObject *)category fromCollectionView:(IMCollectionView *)collectionView {
    self.isViewingImojiCategory = YES;
    [((IMKeyboardView *) self.view) updateTitleWithText:category.title hideCloseButton:NO];
    [((IMKeyboardView *) self.view).collectionView loadImojisFromSearch:category.identifier];
}

- (void)userDidSelectImoji:(IMImojiObject *)imoji fromCollectionView:(IMCollectionView *)collectionView {
    [((IMKeyboardView *) self.view) showDownloadingImojiIndicator];

    IMImojiObjectRenderingOptions *renderOptions = [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeFullResolution];
    renderOptions.aspectRatio = [NSValue valueWithCGSize:CGSizeMake(16.0f, 9.0f)];
    renderOptions.maximumRenderSize = [NSValue valueWithCGSize:CGSizeMake(1000.0f, 1000.0f)];

    [self.session renderImoji:imoji
                      options:renderOptions
                     callback:^(UIImage *image, NSError *error) {
                         if (error) {
                             NSLog(@"Error: %@", error);
                             [((IMKeyboardView *) self.view) showFinishedDownloadedWithMessage:@"UNABLE TO DOWNLOAD IMOJI"];
                         } else {
                             UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                             pasteboard.persistent = YES;
                             [pasteboard setImage:image];

                             [((IMKeyboardView *) self.view) showFinishedDownloadedWithMessage:@"COPIED TO CLIPBOARD"];
                         }
                     }];

    // save to recents
    [self saveToRecents:imoji];
}


- (void)userDidDoubleTapImoji:(IMImojiObject *)imoji fromCollectionView:(IMCollectionView *)collectionView {
    [self saveToFavorites:imoji];
    [((IMKeyboardView *) self.view) showAddedToCollectionIndicator];
}

- (void)userDidSelectSplash:(IMCollectionViewSplashCellType)splashType fromCollectionView:(IMCollectionView *)collectionView {
    if (splashType == IMCollectionViewSplashCellNoResults) {
        ((IMKeyboardView *) self.view).searchView.hidden = NO;
        [(IMKeyboardView *) self.view updateProgressBarWithValue:0.f];
    }
}

- (void)imojiCollectionView:(IMCollectionView *)collectionView didFinishLoadingContentType:(IMCollectionViewContentType)contentType {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionView.collectionViewLayout;
    CGFloat progress;
    if (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        progress = (collectionView.contentOffset.x + collectionView.frame.size.width) / collectionView.collectionViewLayout.collectionViewContentSize.width;
    } else {
        progress = (collectionView.contentOffset.y + collectionView.frame.size.height) / collectionView.collectionViewLayout.collectionViewContentSize.height;
    }

    if (progress != INFINITY) {
        [((IMKeyboardView *) self.view) updateProgressBarWithValue:progress];
    }
}

- (void)imojiCollectionViewDidScroll:(IMCollectionView *)collectionView {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *) collectionView.collectionViewLayout;
    CGFloat progress;
    if (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        progress = (collectionView.contentOffset.x + collectionView.frame.size.width) / collectionView.contentSize.width;
    } else {
        progress = (collectionView.contentOffset.y + collectionView.frame.size.height) / collectionView.contentSize.height;
    }

    if (progress != INFINITY) {
        [((IMKeyboardView *) self.view) updateProgressBarWithValue:progress];
    }
}

#pragma mark IMKeyboardToolbarDelegate

- (void)userDidSelectNextKeyboardButton {
    [self advanceToNextInputMode];
}

- (void)userDidSelectToolbarButton:(IMKeyboardToolbarButtonType)buttonType {
    IMKeyboardView *keyboardView = (IMKeyboardView *) self.view;
    if ([IMConnectivityUtil sharedInstance].hasConnectivity) {
        switch (buttonType) {
            case IMKeyboardToolbarButtonSearch:
                keyboardView.searchView.hidden = NO;
                [keyboardView updateProgressBarWithValue:0.f];
                break;
            case IMKeyboardToolbarButtonRecents:
                [keyboardView.collectionView loadRecentImojis:self.recentImojis];
                [keyboardView updateTitleWithText:@"RECENTS" hideCloseButton:YES];
                break;
            case IMKeyboardToolbarButtonReactions:
                if (self.isViewingImojiCategory || buttonType != self.currentToolbarButtonSelected) {
                    self.isViewingImojiCategory = NO;

                    // Set classification for use in returning user to Reactions when closing a category
                    keyboardView.currentCategoryClassification = IMImojiSessionCategoryClassificationGeneric;

                    [keyboardView.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationGeneric];
                    [keyboardView updateTitleWithText:@"REACTIONS" hideCloseButton:YES];
                }
                break;
            case IMKeyboardToolbarButtonTrending:
                if (self.isViewingImojiCategory || buttonType != self.currentToolbarButtonSelected) {
                    self.isViewingImojiCategory = NO;

                    // Set classification for use in returning user to Trending when closing a category
                    keyboardView.currentCategoryClassification = IMImojiSessionCategoryClassificationTrending;

                    [keyboardView.collectionView loadImojiCategories:IMImojiSessionCategoryClassificationTrending];
                    [keyboardView updateTitleWithText:@"TRENDING" hideCloseButton:YES];
                }
                break;
            case IMKeyboardToolbarButtonCollection: {
                [keyboardView.collectionView loadFavoriteImojis:self.favoritedImojis];
                [keyboardView updateTitleWithText:@"COLLECTION" hideCloseButton:YES];
                break;
            }
            default:
                break;
        }

        self.currentToolbarButtonSelected = buttonType;
    } else {
        [keyboardView.collectionView displaySplashOfType:IMCollectionViewSplashCellNoConnection];
        [keyboardView updateTitleWithText:@"NO NETWORK CONNECTION" hideCloseButton:YES];
    }
}

- (void)userDidSelectDeleteButton {
    [self.textDocumentProxy deleteBackward];
}

#pragma mark Recents/Favorites Logic

- (void)saveToRecents:(IMImojiObject *)imojiObject {
    NSUInteger arrayCapacity = 20;
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:self.appGroup];
    NSArray *savedArrayOfRecents = [shared objectForKey:@"recentImojis"];
    NSMutableArray *arrayOfRecents = [NSMutableArray arrayWithCapacity:arrayCapacity];

    if (!savedArrayOfRecents || savedArrayOfRecents.count == 0) {
        [arrayOfRecents addObject:imojiObject.identifier];
    } else {
        [arrayOfRecents addObjectsFromArray:savedArrayOfRecents];

        if ([arrayOfRecents containsObject:imojiObject.identifier]) {
            [arrayOfRecents removeObject:imojiObject.identifier];
        }
        [arrayOfRecents insertObject:imojiObject.identifier atIndex:0];

        while (arrayOfRecents.count > arrayCapacity) {
            [arrayOfRecents removeLastObject];
        }
    }

    [shared setObject:arrayOfRecents forKey:@"recentImojis"];
    [shared synchronize];
}

- (void)saveToFavorites:(IMImojiObject *)imojiObject {
    if (self.session.sessionState == IMImojiSessionStateConnectedSynchronized) {
        [self.session addImojiToUserCollection:imojiObject
                                      callback:^(BOOL successful, NSError *error) {

                                      }];
    } else {
        NSUInteger arrayCapacity = 20;
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:self.appGroup];
        NSArray *savedArrayOfFavorites = [shared objectForKey:@"favoriteImojis"];
        NSMutableArray *arrayOfFavorites = [NSMutableArray arrayWithCapacity:arrayCapacity];

        if (!savedArrayOfFavorites || savedArrayOfFavorites.count == 0) {
            [arrayOfFavorites addObject:imojiObject.identifier];
        } else {
            [arrayOfFavorites addObjectsFromArray:savedArrayOfFavorites];

            if ([arrayOfFavorites containsObject:imojiObject.identifier]) {
                [arrayOfFavorites removeObject:imojiObject.identifier];
            }
            [arrayOfFavorites insertObject:imojiObject.identifier atIndex:0];

            while (arrayOfFavorites.count > arrayCapacity) {
                [arrayOfFavorites removeLastObject];
            }
        }

        [shared setObject:arrayOfFavorites forKey:@"favoriteImojis"];
        [shared synchronize];
    }
}

- (NSArray *)recentImojis {
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:self.appGroup];
    return [shared objectForKey:@"recentImojis"];
}

- (NSArray *)favoritedImojis {
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:self.appGroup];
    return [shared objectForKey:@"favoriteImojis"];
}

@end
