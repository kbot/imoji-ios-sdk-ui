//
// Created by Alex Hoang on 9/14/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, IMKeyboardCollectionViewSplashCellType) {
    IMKeyboardCollectionViewSplashCellNoConnection = 1,
    IMKeyboardCollectionViewSplashCellEnableFullAccess,
    IMKeyboardCollectionViewSplashCellNoResults,
    IMKeyboardCollectionViewSplashCellRecents,
    IMKeyboardCollectionViewSplashCellCollection
};

extern NSString *const IMKeyboardCollectionViewSplashCellReuseId;

@interface IMKeyboardCollectionViewSplashCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *splashGraphic;
@property(nonatomic, strong) UILabel *splashText;

- (void)setupSplashCellWithType:(IMKeyboardCollectionViewSplashCellType)type
                 andImageBundle:(NSBundle *)imagesBundle;

@end