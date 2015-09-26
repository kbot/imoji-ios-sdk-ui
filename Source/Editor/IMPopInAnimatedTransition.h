//
// Created by Nima Khoshini on 9/25/15.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, IMPopInAnimatedTransitionDirection) {
    IMPopInAnimatedTransitionDirectionLeft,
    IMPopInAnimatedTransitionDirectionRight,
    IMPopInAnimatedTransitionDirectionUp,
    IMPopInAnimatedTransitionDirectionDown
};

@interface IMPopInAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property(nonatomic) IMPopInAnimatedTransitionDirection transitionDirection;

@property(nonatomic) BOOL presenting;

@end
