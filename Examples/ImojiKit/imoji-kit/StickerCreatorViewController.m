//
//  ImojiSDKUI
//
//  Created by Alex Hoang
//  Copyright (C) 2016 Imoji
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

#import <ImojiSDK/ImojiSDK.h>
#import "StickerCreatorViewController.h"

@interface StickerCreatorViewController () <IMCreateImojiViewControllerDelegate>

@end

@implementation StickerCreatorViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithSourceImage:[UIImage imageNamed:@"frosty-dog"] session:[IMImojiSession imojiSession]];
    if (self) {
        self.createDelegate = self;
    }

    return self;
}


- (instancetype)initWithSourceImage:(UIImage *)sourceImage session:(IMImojiSession *)session {
    self = [super initWithSourceImage:sourceImage session:session];
    if (self) {
        self.createDelegate = self;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }

    return self;
}

#pragma mark IMCreateImojiViewControllerDelegate

- (void)imojiUploadDidComplete:(nonnull IMImojiObject *)localImoji
               persistentImoji:(nullable IMImojiObject *)persistentImoji
                     withError:(nullable NSError *)error
            fromViewController:(nonnull IMCreateImojiViewController *)viewController {
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Unable to create Imoji :("
                                    message:[NSString stringWithFormat:@"error: %@", error]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Imoji Created!"
                                    message:@"You did it!"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    [self reset];
}

- (void)userDidCancelImageEdit:(IMCreateImojiViewController *)viewController {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
