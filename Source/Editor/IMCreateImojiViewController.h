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

#import <Foundation/Foundation.h>

@protocol IMCreateImojiViewControllerDelegate;
@class IMImojiObject, IMImojiSession;

/**
* A simple view controller to display an Imoji sticker creator along with a screen to add tags.
*/
@interface IMCreateImojiViewController : UIViewController

@property(readonly, nonnull) UIImage * sourceImage;

/**
* @abstract Creates a new editor view controller with a specified image
*/
- (__nonnull instancetype)initWithSourceImage:(__nonnull UIImage *)sourceImage session:(__nonnull IMImojiSession *)session;

/**
* @abstract Creates a new editor view controller with a specified image
*/
+ (__nonnull instancetype)controllerWithSourceImage:(__nonnull UIImage *)sourceImage session:(__nonnull IMImojiSession *)session;

/**
* @abstract A delegate to receive events from the editor view controller
*/
@property(nonatomic, strong, nullable) id <IMCreateImojiViewControllerDelegate> createDelegate;

/**
* @abstract The current Imoji Session
*/
@property(nonatomic, strong, nonnull) IMImojiSession * session;

@end

@protocol IMCreateImojiViewControllerDelegate <NSObject>

@optional

/**
* @abstract Called by IMCreateImojiViewController once the user has completed the editing process. If any error occurred,
 * the imoji object will be nil and the error parameter will be specified.
*/
- (void)userDidFinishCreatingImoji:(__nullable IMImojiObject *)imoji
                         withError:(__nullable NSError *)error
                fromViewController:(__nonnull IMCreateImojiViewController *)viewController;

/**
* @abstract Called by IMCreateImojiViewController when the user hits the back button. The caller should dismiss the view
 * controller accordingly
*/
- (void)userDidCancelImageEdit:(__nonnull IMCreateImojiViewController *)viewController;

@end
