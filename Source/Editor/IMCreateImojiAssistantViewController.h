//
// Created by Nima Khoshini on 9/25/15.
//

#import <Foundation/Foundation.h>

@class IMImojiSession;

@interface IMCreateImojiAssistantViewController : UIViewController

@property(nonatomic, strong, nonnull) IMImojiSession *session;

/**
* @abstract Creates a new assistant view controller with a session
*/
- (nonnull instancetype)initWithSession:(nonnull IMImojiSession *)session;

/**
* @abstract Creates a new assistant view controller with a session
*/
+ (nonnull instancetype)createAssistantViewControllerWithSession:(nonnull IMImojiSession *)session;


@end
