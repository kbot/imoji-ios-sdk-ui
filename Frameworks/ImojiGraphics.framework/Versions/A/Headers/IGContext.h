//
//  IGContext.h
//  ImojiGraphics
//
//  Created by Thor Harald Johansen on 15/05/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef __IG_CONTEXT__
#define __IG_CONTEXT__

#include "nanovg.h"

#include "IGCommon.h"

#ifdef __cplusplus
extern "C" {
#endif

    struct IGContext {
        NVGcontext * nvgContext;
#if TARGET_OS_IPHONE
        const void * appleEAGLContext;  /* EAGLContext               */
#ifdef IG_USE_CORE_VIDEO_TEXTURES
        void * appleTextureCache;       /* CVOpenGLESTextureCacheRef */
#endif
#elif defined __ANDROID__
        void * androidEGLDisplay;
        void * androidEGLSurface;
        void * androidEGLContext;
#else
// Desktop needs no context variables
#endif
    };
    typedef struct IGContext IGContext;

    IG_FUNCTION(IGContext *, ContextCreate);

#if defined __ANDROID__
    IG_FUNCTION(IGContext *, ContextCreateHosted);
#endif
    
    IG_FUNCTION(void, ContextDestroy, IGContext * igContext);

    IG_FUNCTION(IGbool, ContextMakeCurrent, IGContext * igContext);
    
#ifdef __cplusplus
}
#endif

#endif
