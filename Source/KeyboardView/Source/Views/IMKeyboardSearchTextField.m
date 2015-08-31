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

#import "IMKeyboardSearchTextField.h"

@interface IMKeyboardSearchTextField () {
    UIView * _cursorView;
    UILabel *_placeholder;
    UIButton *_clearButton;
}

@end

@implementation IMKeyboardSearchTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setUserInteractionEnabled:YES];
        
        _cursorView = [[UIView alloc] init];
        _cursorView.backgroundColor = [UIColor blueColor];
        [self addSubview:_cursorView];
        [self startBlinkAnimation];
        
        if (!self.text) {
            self.text = @"";
        }
    }
    return self;
}


- (void)layoutSubviews {
    if (!_placeholder && self.frame.size.height != 0.f) {
        _placeholder = [[UILabel alloc] init];
        _placeholder.font = self.font;
        _placeholder.text = @"SEARCH";
        _placeholder.textColor = [UIColor colorWithRed:193/255.0 green:193/255.0 blue:199/255.0 alpha:1];
        [_placeholder sizeToFit];
        float placeholderHeight = ceilf([_placeholder.text sizeWithAttributes:@{NSFontAttributeName:_placeholder.font}].height);
        _placeholder.frame = CGRectMake(0, (self.frame.size.height - placeholderHeight)/2, _placeholder.frame.size.width, _placeholder.frame.size.height);
        [self addSubview:_placeholder];
    }
    if (!_clearButton && self.frame.size.height != 0.f) {
        UIImage *clearImage = [UIImage imageNamed:@"keyboard_search_clear"];
        [_clearButton setUserInteractionEnabled:YES];
        _clearButton = [[UIButton alloc] init];
        _clearButton.frame = CGRectMake(0, 0, clearImage.size.width, clearImage.size.height);
        [_clearButton setImage:clearImage forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_clearButton];
    }
    
    if (self.text.length > 0) {
        _placeholder.hidden = YES;
        _clearButton.hidden = NO;
    } else {
        _placeholder.hidden = NO;
        _clearButton.hidden = YES;
    }

    _cursorView.frame = CGRectMake(ceilf([self.text sizeWithAttributes:@{NSFontAttributeName:self.font}].width)-1, (self.frame.size.height - 20)/2 -2, 2, 20);
    _clearButton.frame = CGRectMake(self.frame.size.width - _clearButton.frame.size.width, 0, _clearButton.frame.size.width, self.frame.size.height - 4);
}

- (void)startBlinkAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:1.0]];
    [animation setToValue:[NSNumber numberWithFloat:0.0]];
    [animation setDuration:0.5f];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionLinear]];
    [animation setAutoreverses:YES];
    [animation setRepeatCount:20000];
    [[_cursorView layer] addAnimation:animation forKey:@"opacity"];
}

-(void) deleteBackward {
    if (self.text.length > 0) {
        self.text = [self.text substringToIndex:[self.text length]-1];
    }
}

-(void) insertText:(NSString*)string {
    self.text = [self.text stringByAppendingString:string];
}

-(void) clear {
    self.text = @"";
}

@end
