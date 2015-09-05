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

#import "IMEditorView.h"
#import <ImojiGraphics/ImojiGraphics.h>

@interface IMEditorView ()

@property(nonatomic) IGContext *igContext;
@property(nonatomic, readwrite) IGImage *igInputImage;
@property(nonatomic) IGEditor *igEditor;
@property(nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, assign) BOOL firstDrawRect;

@end

@implementation IMEditorView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.firstDrawRect = YES;
        self.multipleTouchEnabled = YES;
        self.contentScaleFactor = 1;

        self.igContext = igContextCreate();
        self.context = (__bridge EAGLContext *) self.igContext->appleEAGLContext;

        self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
        self.drawableDepthFormat = GLKViewDrawableDepthFormatNone;
        self.drawableStencilFormat = GLKViewDrawableStencilFormat8;

        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
        self.displayLink.paused = true; // Don't waste battery with 60 FPS animation when idle!
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }

    return self;
}

- (void)dealloc {
    self.displayLink.paused = true;
    [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];

    if (self.igEditor != nil) {
        igEditorDestroy(self.igEditor);
    }
}

- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
    if (self.igInputImage != nil) {
        if (self.firstDrawRect) {
            self.firstDrawRect = NO;

            // Fetch OpenGL viewport bounds into array
            GLint viewport[4];//GLint UnsafeMutablePointer < GLint >.alloc(4)
            glGetIntegerv((GLenum) GL_VIEWPORT, viewport);

            // Calculate width/height from it
            GLint viewportWidth = viewport[2] - viewport[0];
            GLint viewportHeight = viewport[3] - viewport[1];

            // Calculate average viewport and image dimensions
            IGfloat viewportDimension = 0.5f * (IGfloat) (viewportWidth + viewportHeight);
            IGfloat imageDimension = 0.5f * (IGfloat) (igImageGetWidth(self.igInputImage) + igImageGetHeight(self.igInputImage));

            // Set zoom to viewport:image ratio, clamped to 1 or above (zoom out only)
            IGfloat zoom = MIN(1, viewportDimension / imageDimension);

            igEditorZoomTo(self.igEditor, zoom);
        }

        igEditorDisplay(self.igEditor);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesBegan:touches withEvent:event];
    if (self.igEditor != nil) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:self];
            igEditorTouchEvent(self.igEditor, IG_TOUCH_BEGAN, &touch, (IGfloat) location.x, (IGfloat) location.y);
        }

        self.displayLink.paused = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesEnded:touches withEvent:event];
    if (self.igEditor != nil) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:self];
            igEditorTouchEvent(self.igEditor, IG_TOUCH_MOVED, &touch, (IGfloat) location.x, (IGfloat) location.y);
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [super touchesMoved:touches withEvent:event];
    if (self.igEditor != nil) {
        self.displayLink.paused = YES;

        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInView:self];
            igEditorTouchEvent(self.igEditor, IG_TOUCH_ENDED, &touch, (IGfloat) location.x, (IGfloat) location.y);
        }

        [self setNeedsDisplay];
    }
}

- (void)undo {
    if (self.igEditor != nil) {
        igEditorUndo(self.igEditor);
        [self setNeedsDisplay];
    }
}

- (void)setIgInputImage:(IGImage *)igInputImage {
    _igInputImage = igInputImage;

    if (self.igEditor != nil) {
        igEditorDestroy(self.igEditor);
    }

    self.igEditor = igEditorCreate(igInputImage);
    [self setNeedsDisplay];
}

- (BOOL)isImojiReady {
    return self.igEditor == nil ? false : igEditorImojiIsReady(self.igEditor);
}

- (BOOL)canUndo {
    return self.igEditor == nil ? false : igEditorCanUndo(self.igEditor);
}

- (void)scrollTo:(CGPoint)point {
    if (!self.igEditor) {
        return;
    }

    igEditorScrollTo(self.igEditor, point.x, point.y);
}

- (void)zoomTo:(CGFloat)zoom {
    if (!self.igEditor) {
        return;
    }

    igEditorZoomTo(self.igEditor, zoom);
}

- (void)loadImage:(UIImage *)image {
    self.igInputImage = igImageFromNative(self.igContext, image.CGImage, 1);
}

- (UIImage *)getOutputImage {
    IGImage *trimmedImage = self.igEditor == nil ? nil : igEditorGetTrimmedOutputImage(self.igEditor);

    IGBorder* igBorder = igBorderCreatePreset(igImageGetWidth(trimmedImage), igImageGetHeight(trimmedImage), IG_BORDER_CLASSIC);
    IGint padding = igBorderGetPadding(igBorder);
    IGImage* igOutputImage = igImageCreate(self.igContext, igImageGetWidth(trimmedImage) + padding * 2, igImageGetHeight(trimmedImage) + padding * 2);

    igBorderRender(igBorder, trimmedImage, igOutputImage, padding, padding, 1, 1);
    igBorderDestroy(igBorder, true);
    igImageDestroy(trimmedImage);

    CGImageRef pImage = igImageToNative(igOutputImage);

    igImageDestroy(igOutputImage);

    return [UIImage imageWithCGImage:pImage];
}

@end
