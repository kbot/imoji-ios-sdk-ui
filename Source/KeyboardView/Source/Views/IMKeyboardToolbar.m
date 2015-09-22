//
// Created by Alex Hoang on 9/16/15.
//

#import "IMKeyboardToolbar.h"

@implementation IMKeyboardToolbar {

}

@dynamic delegate;

- (instancetype)initImojiKeyboardToolbar {
    self = [super init];
    if (self) {
        self.imageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"ImojiKeyboardAssets" ofType:@"bundle"]];
        self.items = [[NSArray alloc] init];
    }

    return self;
}

- (void)addToolbarButtonWithType:(IMKeyboardToolbarButtonType)buttonType {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, IMKeyboardToolbarButtonHeight, IMKeyboardToolbarButtonHeight);

    switch (buttonType) {
        case IMKeyboardToolbarButtonNextKeyboard:
            [button setImage:[UIImage imageNamed:@"keyboard_globe" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(nextKeyboardPressed:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case IMKeyboardToolbarButtonSearch:
            [button setImage:[UIImage imageNamed:@"keyboard_search" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"keyboard_search_active" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
            break;
        case IMKeyboardToolbarButtonRecents:
            [button setImage:[UIImage imageNamed:@"keyboard_recents" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"keyboard_recents_active" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
            break;
        case IMKeyboardToolbarButtonReactions:
            [button setImage:[UIImage imageNamed:@"keyboard_reactions" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"keyboard_reactions_active" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
            button.selected = YES;
            break;
        case IMKeyboardToolbarButtonTrending:
            [button setImage:[UIImage imageNamed:@"keyboard_trending" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"keyboard_trending_active" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
            break;
        case IMKeyboardToolbarButtonCollection:
            [button setImage:[UIImage imageNamed:@"keyboard_collection" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"keyboard_collection_active" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
            break;
        case IMKeyboardToolbarButtonDelete:
            [button setImage:[UIImage imageNamed:@"keyboard_delete" inBundle:self.imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(deletePressed:) forControlEvents:UIControlEventTouchUpInside];
            break;
        default:
            return;
    }

    button.tag = buttonType;
    if (buttonType != IMKeyboardToolbarButtonNextKeyboard && buttonType != IMKeyboardToolbarButtonDelete) {
        [button addTarget:self action:@selector(navPressed:) forControlEvents:UIControlEventTouchUpInside];
    }

    UIBarButtonItem *toolbarButton;
    toolbarButton = [[UIBarButtonItem alloc] initWithCustomView:button];

    if (self.items.count > 0) {
        self.items = [self.items arrayByAddingObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    }

    self.items = [self.items arrayByAddingObject:toolbarButton];
}

- (IBAction)nextKeyboardPressed:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidSelectToolbarButton:)]) {
        [self.delegate userDidSelectNextKeyboardButton];
    }
}

- (IBAction)deletePressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidSelectDeleteButton)]) {
        [self.delegate userDidSelectDeleteButton];
    }
}

- (IBAction)navPressed:(UIButton *)sender {
    BOOL sameButtonPressed = NO;
    // set selected state

    if (sender.tag != IMKeyboardToolbarButtonSearch && sender.tag != IMKeyboardToolbarButtonDelete) {
        for(UIBarButtonItem *item in self.items) {
            UIButton *tmpButton = (UIButton *) item.customView;
            if(tmpButton.isSelected && tmpButton.tag == sender.tag) {
                sameButtonPressed = YES;
            }
            tmpButton.selected = NO;
        }

        sender.selected = YES; // set button pressed to selected
    }

    if (sameButtonPressed && sender.tag != IMKeyboardToolbarButtonReactions && sender.tag != IMKeyboardToolbarButtonTrending) {
        return;
    }

    // run action
    if (self.delegate && [self.delegate respondsToSelector:@selector(userDidSelectToolbarButton:)]) {
        [self.delegate userDidSelectToolbarButton:(IMKeyboardToolbarButtonType) sender.tag];
    }
}

+ (instancetype)imojiKeyboardToolbar {
    return [[IMKeyboardToolbar alloc] initImojiKeyboardToolbar];
}

@end