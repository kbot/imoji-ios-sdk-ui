//
//  ImojiSDKUI
//
//  Created by Nima Khoshini
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

#import "IMPopInAnimatedTransition.h"

@implementation IMPopInAnimatedTransition {

}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.transitionDirection = IMPopInAnimatedTransitionDirectionUp;
    }

    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return .6f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if (self.presenting) {
        UIView *fromView = [fromViewController.view resizableSnapshotViewFromRect:fromViewController.view.frame
                                                               afterScreenUpdates:NO
                                                                    withCapInsets:UIEdgeInsetsZero];
        UIView *toView = toViewController.view;

        UIView *blurredView = [self generateViewControllerBackground:fromViewController];
        [transitionContext.containerView addSubview:blurredView];
        [transitionContext.containerView addSubview:toView];

        CGRect startFrame, endFrame = toView.frame;

        switch (self.transitionDirection) {
            case IMPopInAnimatedTransitionDirectionLeft:
                startFrame = CGRectMake(
                        -toView.frame.size.width, 0,
                        toView.frame.size.width, toView.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionRight:
                startFrame = CGRectMake(
                        toView.frame.size.width, 0,
                        toView.frame.size.width, toView.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionDown:
                startFrame = CGRectMake(
                        0, -toView.frame.size.height,
                        toView.frame.size.width, toView.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionUp:
            default:
                startFrame = CGRectMake(
                        0, toView.frame.size.height,
                        toView.frame.size.width, toView.frame.size.height
                );

                break;
        }

        toView.frame = startFrame;
        blurredView.layer.opacity = 0.0f;

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:1.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             fromView.layer.opacity = 0.0f;
                             blurredView.layer.opacity = 1.0f;
                             toView.frame = endFrame;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    } else {
        UIView *fromView = fromViewController.view;
        UIView *blurredBackgroundView = transitionContext.containerView.subviews.firstObject;

        [transitionContext.containerView addSubview:fromView];

        CGRect endFrame;
        switch (self.transitionDirection) {
            case IMPopInAnimatedTransitionDirectionLeft:
                endFrame = CGRectMake(
                        -fromView.frame.size.width, 0,
                        fromView.frame.size.width, fromView.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionRight:
                endFrame = CGRectMake(
                        fromView.frame.size.width, 0,
                        fromView.frame.size.width, fromView.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionDown:
                endFrame = CGRectMake(
                        0, -fromView.frame.size.height,
                        fromView.frame.size.width, fromView.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionUp:
            default:
                endFrame = CGRectMake(
                        0, fromView.frame.size.height,
                        fromView.frame.size.width, fromView.frame.size.height
                );

                break;
        }

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             blurredBackgroundView.layer.opacity = 0.0f;
                             fromView.frame = endFrame;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }
        ];
    }
}

- (UIView *)generateViewControllerBackground:(UIViewController *)controller {
    UIView *view = controller.view;
    UIImageView *imageView = [UIImageView new];
    UIView *foregroundView;

    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    // show blurred background if available (iOS 8 and above)
    if (NSClassFromString(@"UIVisualEffectView")) {
        foregroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    } else {
        // fall back to a simple translucent background
        foregroundView = [UIView new];
        foregroundView.backgroundColor = [UIColor colorWithWhite:.2f alpha:.95f];
    }

    [imageView addSubview:foregroundView];

    foregroundView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    imageView.frame = CGRectMake(0, 0, foregroundView.frame.size.width, foregroundView.frame.size.height);

    return imageView;
}


@end
