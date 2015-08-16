//
//  SearchTextField.m
//  imoji-keyboard
//
//  Created by Jeff on 8/16/15.
//  Copyright (c) 2015 Jeff. All rights reserved.
//

#import "SearchTextField.h"

@interface SearchTextField () {
    UIView * _cursorView;
    UILabel *_placeholder;
}

@end

@implementation SearchTextField

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
    if (self.text.length > 0) {
        _placeholder.hidden = YES;
    } else {
        _placeholder.hidden = NO;
    }

    _cursorView.frame = CGRectMake(ceilf([self.text sizeWithAttributes:@{NSFontAttributeName:self.font}].width)-1, (self.frame.size.height - 20)/2 -2, 2, 20);
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

@end
