//
//  IGImage.h
//  ImojiGraphics
//
//  Created by Thor Harald Johansen on 15/05/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef __IG_IMAGE__
#define __IG_IMAGE__

#include <stdint.h>
#include <stdbool.h>

#include "nanovg.h"

#include "IGCommon.h"
#include "IGContext.h"

#if TARGET_OS_IPHONE
#include "CoreGraphics/CoreGraphics.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

    struct IGImage {
        IGContext * igContext;
        int width;
        int height;
        int stride;
        uint32_t fbo;
        uint32_t rbo;
        uint32_t texture;
        uint32_t * pixels;
        bool pixelsReadOnly;
        int nvgImage;
#ifdef IG_USE_CORE_VIDEO_TEXTURES
        void * applePixelBuffer; /* CVPixelBufferRef */
        void * appleTextureRef; /* CVOpenGLESTextureRef */
#else
        uint32_t * clientPixels;
        bool clientPixelsFresh; // MUST be set to false after OpenGL operations
#endif
    };
    typedef struct IGImage IGImage;

    IG_FUNCTION(IGImage *, ImageCreate, IGContext * igContext, IGint width, IGint height);

    IG_FUNCTION(IGImage *, ImageCreateDummy, IGContext * igContext, IGint width, IGint height);

    IG_FUNCTION(void, ImageDestroy, IGImage * igImage);
        
    static inline int igImageGetStride(IGImage * igImage) {
        return igImage->stride;
    }

    IG_FUNCTION(IGint, ImageGetWidth, IGImage * igImage);
    
    IG_FUNCTION(IGint, ImageGetHeight, IGImage * igImage);

    // Creates an image padded with given pixel amounts from a given source image
    IG_FUNCTION(IGImage *, ImagePad, IGImage * igImage, IGint perSideX, IGint perSideY);
    
    // These are used to lock pixels to access their values:
    
    void igImageLockPixels(IGImage * igImage, bool readOnly);

    void igImageUnlockPixels(IGImage * igImage);
    
    // These may crash or give undefined results if pixels are not locked first:
    
    static inline uint32_t igImageGetPixel(IGImage * igImage, int x, int y) {
        return igImage->pixels[y * (igImage->stride >> 2) + x];
    }

    static inline uint8_t igImageGetAlpha(IGImage * igImage, int x, int y) {
        return (igImageGetPixel(igImage, x, y) >> 24) & 0xFF;
    }

    static inline uint8_t igImageGetRed(IGImage * igImage, int x, int y) {
#ifdef IG_USE_BGRA
        return (igImageGetPixel(igImage, x, y) >> 16) & 0xFF;
#elif defined IG_USE_RGBA
        return igImageGetPixel(igImage, x, y) & 0xFF;
#else
#error "Unknown image format"
#endif
    }
    
    static inline uint8_t igImageGetGreen(IGImage * igImage, int x, int y) {
#if defined IG_USE_BGRA || defined IG_USE_RGBA
        return (igImageGetPixel(igImage, x, y) >> 8) & 0xFF;
#else
#error "Unknown image format"
#endif
    }
    
    static inline uint8_t igImageGetBlue(IGImage * igImage, int x, int y) {
#ifdef IG_USE_BGRA
        return igImageGetPixel(igImage, x, y) & 0xFF;
#elif defined IG_USE_RGBA
        return (igImageGetPixel(igImage, x, y) >> 16) & 0xFF;
#else
#error "Unknown image format"
#endif
    }

    static inline void igImagePutPixel(IGImage * igImage, int x, int y, uint32_t pixel) {
        igImage->pixels[y * (igImage->stride >> 2) + x] = pixel;
    }

    static inline void igImagePutRGBA(IGImage * igImage, int x, int y, uint32_t r, uint32_t g, uint32_t b, uint32_t a) {
#ifdef IG_USE_BGRA
        igImage->pixels[y * (igImage->stride >> 2) + x] = (a << 24) | (r << 16) | (g << 8) | b;
#elif defined IG_USE_RGBA
        igImage->pixels[y * (igImage->stride >> 2) + x] = (a << 24) | (b << 16) | (g << 8) | r;
#else
#error "Unknown image format"
#endif
    }
    
    // Image bridging functions:

#if TARGET_OS_IPHONE
    IG_FUNCTION(CGImageRef, ImageToNative, IGImage * igImage);
    
    IG_FUNCTION(IGImage *, ImageFromNative, IGContext * igContext, CGImageRef cgImage, IGint padding);
#elif defined __ANDROID__
    IG_FUNCTION(jobject, ImageToNative, IGImage * igImage);

    IG_FUNCTION(IGImage *, ImageFromNative, IGContext * igContext, jobject bitmap, IGint padding);
#else
// No generic implementation really possible on desktop.
#endif

    void igAppleCGDataProviderRelease(void *info, const void *data, size_t size);
    
#ifdef __cplusplus
}
#endif
    
#endif
