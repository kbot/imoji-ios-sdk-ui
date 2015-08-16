//
//  KeyboardViewController.h
//  iOSKeyboardTemplate
//

#import <UIKit/UIKit.h>
#import "SearchTextField.h"

@interface QwertyViewController : UIInputViewController

//callback
@property(nonatomic, strong) void(^setSearchCallback) ();
@property(nonatomic, strong) SearchTextField *searchField;

@end
