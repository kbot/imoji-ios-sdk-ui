//
//  KeyboardViewController.h
//  iOSKeyboardTemplate
//

#import <UIKit/UIKit.h>

@interface QwertyViewController : UIInputViewController

//callback
@property(nonatomic, strong) void(^setSearchCallback) ();

@end
