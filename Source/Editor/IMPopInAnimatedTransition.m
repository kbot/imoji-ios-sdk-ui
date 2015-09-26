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
        UIView *blurredView = [self generateViewControllerBackground:fromViewController];
        [transitionContext.containerView addSubview:blurredView];
        [transitionContext.containerView addSubview:toViewController.view];

        CGRect startFrame, endFrame = toViewController.view.frame;

        switch (self.transitionDirection) {
            case IMPopInAnimatedTransitionDirectionLeft:
                startFrame = CGRectMake(
                        -toViewController.view.frame.size.width, 0,
                        toViewController.view.frame.size.width, toViewController.view.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionRight:
                startFrame = CGRectMake(
                        toViewController.view.frame.size.width, 0,
                        toViewController.view.frame.size.width, toViewController.view.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionDown:
                startFrame = CGRectMake(
                        0, -toViewController.view.frame.size.height,
                        toViewController.view.frame.size.width, toViewController.view.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionUp:
            default:
                startFrame = CGRectMake(
                        0, toViewController.view.frame.size.height,
                        toViewController.view.frame.size.width, toViewController.view.frame.size.height
                );

                break;
        }

        toViewController.view.frame = startFrame;
        blurredView.layer.opacity = 0.0f;

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:1.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             fromViewController.view.layer.opacity = 0.0f;
                             blurredView.layer.opacity = 1.0f;
                             toViewController.view.frame = endFrame;
                         }
                         completion:^(BOOL finished) {
                             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                         }];
    } else {
        [transitionContext.containerView addSubview:fromViewController.view];

        CGRect endFrame;
        switch (self.transitionDirection) {
            case IMPopInAnimatedTransitionDirectionLeft:
                endFrame = CGRectMake(
                        -fromViewController.view.frame.size.width, 0,
                        fromViewController.view.frame.size.width, fromViewController.view.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionRight:
                endFrame = CGRectMake(
                        fromViewController.view.frame.size.width, 0,
                        fromViewController.view.frame.size.width, fromViewController.view.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionDown:
                endFrame = CGRectMake(
                        0, -fromViewController.view.frame.size.height,
                        fromViewController.view.frame.size.width, fromViewController.view.frame.size.height
                );

                break;

            case IMPopInAnimatedTransitionDirectionUp:
            default:
                endFrame = CGRectMake(
                        0, fromViewController.view.frame.size.height,
                        fromViewController.view.frame.size.width, fromViewController.view.frame.size.height
                );

                break;
        }

        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
                             fromViewController.view.layer.opacity = 0.0f;
                             fromViewController.view.frame = endFrame;
                         }
                         completion:^(BOOL finished) {
                             [fromViewController.view removeFromSuperview];
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
