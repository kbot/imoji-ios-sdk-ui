//
// Created by Alex Hoang on 9/16/15.
//

#import <Foundation/Foundation.h>

#define IMKeyboardToolbarButtonHeight 40.0f

typedef NS_ENUM(NSUInteger, IMKeyboardToolbarButtonType) {
    IMKeyboardToolbarButtonNextKeyboard,
    IMKeyboardToolbarButtonSearch,
    IMKeyboardToolbarButtonRecents,
    IMKeyboardToolbarButtonReactions,
    IMKeyboardToolbarButtonTrending,
    IMKeyboardToolbarButtonCollection,
    IMKeyboardToolbarButtonDelete
};

@protocol IMKeyboardToolbarDelegate;

@interface IMKeyboardToolbar : UIToolbar

@property(nonatomic, strong) NSBundle *imageBundle;
@property(nonatomic, weak) id<IMKeyboardToolbarDelegate> delegate;

- (void)addToolbarButtonWithType:(IMKeyboardToolbarButtonType)buttonType;

+ (instancetype)imojiKeyboardToolbar;

@end

@protocol IMKeyboardToolbarDelegate <UIToolbarDelegate>

- (void)userDidSelectNextKeyboardButton;

- (void)userDidSelectDeleteButton;

@optional

- (void)userDidSelectToolbarButton:(IMKeyboardToolbarButtonType)buttonType;

@end