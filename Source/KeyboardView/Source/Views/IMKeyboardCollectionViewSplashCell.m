//
// Created by Alex Hoang on 9/14/15.
//

#import "IMKeyboardCollectionViewSplashCell.h"
#import <Masonry/Masonry.h>

NSString *const IMKeyboardCollectionViewSplashCellReuseId = @"IMKeyboardCollectionViewSplashCellReuseId";

@implementation IMKeyboardCollectionViewSplashCell {

}

- (void)setupSplashCellWithType:(IMKeyboardCollectionViewSplashCellType)type
                 andImageBundle:(NSBundle *)imagesBundle {
    if(self.splashGraphic) {
        [self.splashGraphic removeFromSuperview];
        self.splashGraphic = nil;
    }

    if(self.splashText) {
        [self.splashText removeFromSuperview];
        self.splashText = nil;
    }

    self.splashGraphic = [[UIImageView alloc] init];
    self.splashText = [[UILabel alloc] init];

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentNatural;

    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];

    switch(type) {
        case IMKeyboardCollectionViewSplashCellNoConnection:
            self.splashGraphic.image = [UIImage imageNamed:@"keyboard_splash_noconnection" inBundle:imagesBundle compatibleWithTraitCollection:nil];

            self.splashText.text = @"Enable wifi or cellular data\nto use imoji sticker keyboard";
            self.splashText.textColor = [UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1];
            self.splashText.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:14.0f];
            break;
        case IMKeyboardCollectionViewSplashCellEnableFullAccess:
            self.splashGraphic.image = [UIImage imageNamed:@"keyboard_splash_enableaccess" inBundle:imagesBundle compatibleWithTraitCollection:nil];

            self.splashText.text = @"Allow Full Access in Settings\nto use imoji sticker keyboard";
            self.splashText.textColor = [UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1];
            self.splashText.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:14.0f];
            break;
        case IMKeyboardCollectionViewSplashCellNoResults:
            self.splashGraphic.image = [UIImage imageNamed:@"keyboard_splash_noresults" inBundle:imagesBundle compatibleWithTraitCollection:nil];

            [textAttributes setDictionary:@{
                    NSFontAttributeName : [UIFont fontWithName:@"SFUIDisplay-Light" size:19.0f],
                    NSForegroundColorAttributeName : [UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1],
                    NSParagraphStyleAttributeName : paragraphStyle
            }];

            [text appendAttributedString: [[NSAttributedString alloc] initWithString:@"No Results\n"
                                                                          attributes:textAttributes]];
            textAttributes[@"NSFont"] = [UIFont fontWithName:@"SFUIDisplay-Regular" size:16.0f];
            textAttributes[@"NSColor"] = [UIColor colorWithRed:56.0f / 255.0f green:124.0f / 255.0f blue:169.0f / 255.0f alpha:1];
            [text appendAttributedString: [[NSAttributedString alloc] initWithString:@"Try Again"
                                                                          attributes:textAttributes]];
            self.splashText.attributedText = text;
            break;
        case IMKeyboardCollectionViewSplashCellCollection:
            self.splashGraphic.image = [UIImage imageNamed:@"keyboard_splash_collection" inBundle:imagesBundle compatibleWithTraitCollection:nil];

            [textAttributes setDictionary:@{
                    NSFontAttributeName : [UIFont fontWithName:@"SFUIDisplay-Medium" size:15.0f],
                    NSForegroundColorAttributeName : [UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1],
                    NSParagraphStyleAttributeName : paragraphStyle
            }];

            [text appendAttributedString: [[NSAttributedString alloc] initWithString:@"Double tap "
                                                                          attributes:textAttributes]];
            textAttributes[@"NSFont"] = [UIFont fontWithName:@"SFUIDisplay-Regular" size:15.0f];
            [text appendAttributedString: [[NSAttributedString alloc] initWithString:@"stickers to add them\nto your collection!"
                                                                          attributes:textAttributes]];

            self.splashText.attributedText = text;
            break;
        case IMKeyboardCollectionViewSplashCellRecents:
            self.splashGraphic.image = [UIImage imageNamed:@"keyboard_splash_recents" inBundle:imagesBundle compatibleWithTraitCollection:nil];

            self.splashText = [[UILabel alloc] init];
            self.splashText.text = @"Stickers you send\nwill appear here";
            self.splashText.textColor = [UIColor colorWithRed:167.0f / 255.0f green:169.0f / 255.0f blue:172.0f / 255.0f alpha:1];

            self.splashText.font = [UIFont fontWithName:@"SFUIDisplay-Regular" size:15.0f];
            break;
        default:
            break;
    }

    self.splashText.lineBreakMode = NSLineBreakByWordWrapping;
    self.splashText.numberOfLines = 2;
    self.splashText.textAlignment = NSTextAlignmentCenter;

    [self addSubview:self.splashGraphic];
    [self addSubview:self.splashText];

    [self.splashGraphic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-(self.splashGraphic.image.size.height / 2.0f));
    }];

    [self.splashText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.splashGraphic.mas_bottom).offset(13.0f);
        make.width.and.centerX.equalTo(self);
    }];
}


@end