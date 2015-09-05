//
//  IGBorder.h
//  ImojiGraphics
//
//  Created by Thor Harald Johansen on 18/05/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef __IG_BORDER__
#define __IG_BORDER__

#include "IGCommon.h"
#include "IGContext.h"
#include "IGCanvas.h"
#include "IGImage.h"
#include "IGPaths.h"
#include "IGShadow.h"

#ifdef __cplusplus
extern "C" {
#endif

    enum IGBorderPreset {
        IG_BORDER_CLASSIC = 1,
        IG_BORDER_LITE,
        IG_BORDER_DEBUG
    };

    enum IGBorderElementType {
        IG_BORDER_ELEMENT_FILL = 1,
        IG_BORDER_ELEMENT_STROKE
    };

    #if __ANDROID__
    typedef IGint IGBorderPreset;
    typedef IGint IGBorderElementType;
    #else
    typedef enum IGBorderPreset IGBorderPreset;
    typedef enum IGBorderElementType IGBorderElementType;
    #endif

    struct IGBorderElement {
        IGBorderElementType type;
        float width;
        float offset;
        NVGcolor color;
    };
    typedef struct IGBorderElement IGBorderElement;

    vectorDefine(IGBorderElements, IGBorderElement *);
    
    struct IGBorder {
        IGint dimension;
        
        IGPaths * edgePaths;
        IGPaths ** elementPaths;
        
        IGBorderElements * elements;
        
        NVGcolor shadowColor;
        float shadowDiameter;
        float shadowOffsetX;
        float shadowOffsetY;
        
        IGShadow * igShadow;
    };
    typedef struct IGBorder IGBorder;

    IG_FUNCTION(IGBorder *, BorderCreate, IGint width, IGint height);

    // Always call BorderDestroy with destroyElements == true for preset borders!
    IG_FUNCTION(IGBorder *, BorderCreatePreset, IGint width, IGint height, IGBorderPreset igBorderPreset);

    IG_FUNCTION(void, BorderSetShadow, IGBorder * igBorder, IGfloat diameter, IGfloat offsetX, IGfloat offsetY,
                IGint red, IGint green, IGint blue, IGint alpha);

    IG_FUNCTION(void, BorderSetEdgePaths, IGBorder * igBorder, IGPaths * igPaths);

    IG_FUNCTION(void, BorderSetDimension, IGBorder * igBorder, IGint dimension);
    
    IG_FUNCTION(void, BorderAddElement, IGBorder * igBorder, IGBorderElement * igBorderElement);

    IG_FUNCTION(void, BorderDestroy, IGBorder * igBorder, IGbool destroyElements);

    IG_FUNCTION(IGBorderElement *, BorderElementCreate, IGBorderElementType type, IGfloat offset, IGfloat width,
                IGint red, IGint green, IGint blue, IGint alpha);

    IG_FUNCTION(void, BorderElementDestroy, IGBorderElement * igBorderElement);

    IG_FUNCTION(IGint, BorderGetPadding, IGBorder * igBorder);

    // Please pad IGImage with igBorderGetPadding pixels per side before passing to igBorderRender()
    // Returned image is overwritten by later igBorderRender calls and dies with igBorderDestroy!
    IG_FUNCTION(IGbool, BorderRender, IGBorder * igBorder, IGImage * igInputImage, IGImage * igOutputImage, IGfloat x, IGfloat y, IGfloat scaleX, IGfloat scaleY);

#ifdef __cplusplus
}
#endif

#endif