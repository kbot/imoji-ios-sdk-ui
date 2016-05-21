//
//  ImojiSDKUI
//
//  Created by Alex Hoang
//  Copyright (C) 2016 Imoji
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

#import "IMHalfScreenView.h"
#import <Masonry/Masonry.h>

CGFloat const IMHalfScreenViewDefaultHeight = 226.0f;

@interface IMHalfScreenView () <IMSearchViewDelegate, IMCollectionViewDelegate>
@end

@implementation IMHalfScreenView

- (void)setupStickerSearchContainerViewWithSession:(IMImojiSession *)session {
    self.searchView = [IMSearchView imojiSearchView];
    self.searchView.createAndRecentsEnabled = YES;
    self.searchView.backButtonType = IMSearchViewBackButtonTypeBack;
    self.searchView.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchView.delegate = self;

    self.imojiSuggestionView = [IMSuggestionView imojiSuggestionViewWithSession:session];
    self.imojiSuggestionView.backgroundColor = [UIColor whiteColor];
    self.imojiSuggestionView.clipsToBounds = NO;
    self.imojiSuggestionView.collectionView.backgroundColor = [UIColor clearColor];
    self.imojiSuggestionView.collectionView.infiniteScroll = YES;
    self.imojiSuggestionView.collectionView.preferredImojiDisplaySize = CGSizeMake(74.f, 91.f);
    self.imojiSuggestionView.collectionView.collectionViewDelegate = self;

    [self addSubview:self.searchView];
    [self addSubview:self.imojiSuggestionView];

    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
        make.height.equalTo(@(IMSearchViewContainerDefaultHeight));
    }];

    [self.imojiSuggestionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.searchView.mas_bottom);
        make.height.equalTo(@(IMSuggestionViewDefaultHeight * 2.0f));
    }];
}

#pragma mark IMSearchView Delegate

- (void)userDidBeginSearchFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidBeginSearchFromSearchView:)]) {
        [self.delegate userDidBeginSearchFromSearchView:searchView];
    }

    searchView.backButton.hidden = YES;

    if (!searchView.recentsButton.selected) {
        [searchView.searchViewContainer mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(IMSearchViewContainerDefaultLeftOffset);
        }];

        if (![searchView.searchIconImageView isDescendantOfView:searchView.searchViewContainer]) {
            [searchView.searchViewContainer addSubview:searchView.searchIconImageView];
        }
    }

    [searchView.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView.searchViewContainer);
        make.centerY.equalTo(searchView.searchViewContainer);
        make.width.and.height.equalTo(@(IMSearchViewIconWidthHeight));
    }];
}

- (void)userDidEndSearchFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidEndSearchFromSearchView:)]) {
        [self.delegate userDidEndSearchFromSearchView:searchView];
    }

    if(searchView.searchTextField.text.length > 0 && !searchView.recentsButton.selected) {
        [searchView showBackButton];
    }
}

- (void)userDidTapBackButtonFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapBackButtonFromSearchView:)]) {
        [self.delegate userDidTapBackButtonFromSearchView:searchView];
    }

    [searchView resetSearchView];

    if(![searchView.searchTextField isFirstResponder]) {
        [searchView hideBackButton];
    }

    [self.imojiSuggestionView.collectionView loadImojiCategoriesWithOptions:[IMCategoryFetchOptions optionsWithClassification:IMImojiSessionCategoryClassificationTrending]];
}

- (void)userDidTapRecentsButtonFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidTapRecentsButtonFromSearchView:)]) {
        [self.delegate userDidTapRecentsButtonFromSearchView:searchView];
    }

    searchView.backButton.hidden = NO;
    searchView.createButton.hidden = YES;
    searchView.searchTextField.rightView = searchView.searchIconImageView;

    [searchView.recentsButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@(IMSearchViewCreateRecentsIconWidthHeight));
        make.centerY.equalTo(searchView.searchViewContainer);
        make.left.equalTo(searchView.backButton.mas_right).offset(13.0f);
    }];

    [searchView.searchTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView.recentsButton.mas_right).offset(2.0f);
        make.right.equalTo(searchView.searchViewContainer).offset(-6.0f);
        make.height.equalTo(@(IMSearchViewIconWidthHeight));
        make.centerY.equalTo(searchView.searchViewContainer);
    }];

    [self.imojiSuggestionView.collectionView loadRecents];
}

- (void)userDidPressReturnKeyFromSearchView:(IMSearchView *)searchView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidPressReturnKeyFromSearchView:)]) {
        [self.delegate userDidPressReturnKeyFromSearchView:searchView];
    }

    [searchView.searchTextField resignFirstResponder];
}

+ (instancetype)imojiStickerSearchContainerViewWithSession:(IMImojiSession *)session {
    return [[IMHalfScreenView alloc] initWithSession:session];
}

@end
