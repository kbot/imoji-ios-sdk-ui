//
// Created by Nima Khoshini on 9/25/15.
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

    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    } else {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }

    imageView.image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    if (NSClassFromString(@"UIVisualEffectView")) {
        foregroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    } else {
        foregroundView = [UIView new];
        foregroundView.backgroundColor = [UIColor colorWithWhite:255 alpha:.9f];
    }

    [imageView addSubview:foregroundView];

    foregroundView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    imageView.frame = CGRectMake(0, 0, foregroundView.frame.size.width, foregroundView.frame.size.height);

    return imageView;
}


@end
