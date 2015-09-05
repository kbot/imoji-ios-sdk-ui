//
//  IMGraphics.h
//  IMCanvas
//
//  Created by Thor Harald Johansen on 08/05/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef __IM_GRAPHICS__
#define __IM_GRAPHICS__

#include <stdbool.h>

#include "nanovg.h"

#include "IGCommon.h"
#include "IGImage.h"
#include "IGContext.h"
#include "IGPath.h"
#include "IGPaths.h"

#ifdef __cplusplus
extern "C" {
#endif

    struct IGCanvas {
        IGImage * igImage;
    };
    typedef struct IGCanvas IGCanvas;

    enum IGBlendMode {
        IG_SRC_OVER = 1,
        IG_SRC_IN,
        IG_SRC_OUT,
        IG_SRC_ATOP,
        IG_DST_OVER,
        IG_DST_IN,
        IG_DST_OUT,
        IG_DST_ATOP,
        IG_LIGHTER,
        IG_COPY,
        IG_XOR
    };
    
#if __ANDROID__
    typedef IGint IGBlendMode;
#else
    typedef enum IGBlendMode IGBlendMode;
#endif
    
    IG_FUNCTION(IGCanvas *, CanvasCreate, IGImage * igImage);

    IG_FUNCTION(void, CanvasDestroy, IGCanvas * igCanvas);

    // Call these to paint with NanoVG:

    IG_FUNCTION(void, Begin, IGCanvas * igCanvas, IGBlendMode blendMode);

    IG_FUNCTION(void, End, IGCanvas * igCanvas);
    
    IG_FUNCTION(NVGcontext *, CanvasGetNVG, IGCanvas * igCanvas);

    IG_FUNCTION(void, CanvasDrawPath, IGCanvas * igCanvas, IGPath * igPath, IGbool closed);
    
    IG_FUNCTION(void, CanvasDrawPaths, IGCanvas * igCanvas, IGPaths * igPaths, IGbool closed);

#ifdef __cplusplus
}
#endif
    
#endif
