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
@class IMImojiObject;
@class IMImojiSession;

@interface IMCreateImojiViewController : UIViewController

@property(readonly) UIImage *sourceImage;

- (instancetype)initWithSourceImage:(UIImage *)sourceImage session:(IMImojiSession *)session;

+ (instancetype)controllerWithSourceImage:(UIImage *)sourceImage session:(IMImojiSession *)session;

@property(nonatomic, strong) id <IMCreateImojiViewControllerDelegate> createDelegate;
@property(nonatomic, strong) IMImojiSession *session;

@end

@protocol IMCreateImojiViewControllerDelegate<NSObject>

@optional

- (void)userDidFinishCreatingImoji:(IMImojiObject *)imoji withError:(NSError *)error;

- (void)userDidCancelImageEdit:(IMCreateImojiViewController *)viewController;

@end
