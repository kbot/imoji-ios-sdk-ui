//
// Created by Nima on 10/12/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import "ImojiSuggestionViewCell.h"


@implementation ImojiSuggestionViewCell {

}

- (void)performGrowAnimation {
    self.imojiView.transform = CGAffineTransformMakeScale(.2f, .2f);

    [UIView animateWithDuration:.4f
                          delay:0.f
         usingSpringWithDamping:.8f
          initialSpringVelocity:.8f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.imojiView.transform = CGAffineTransformIdentity;
                     } completion:nil];
}

@end
