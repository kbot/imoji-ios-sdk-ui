//
//  SearchTextField.h
//  imoji-keyboard
//
//  Created by Jeff on 8/16/15.
//  Copyright (c) 2015 Jeff. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTextField : UILabel

-(void) deleteBackward;
-(void) insertText:(NSString*)string;

@end
