//
//  IGBoxBlur.h
//  ImojiGraphics
//
//  Created by Thor Harald Johansen on 20/05/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef __IG_SHADOW__
#define __IG_SHADOW__

#include "IGCommon.h"
#include "IGImage.h"

#ifdef __cplusplus
extern "C" {
#endif

    struct IGShadow {
        IGContext * igContext;
        IGint vertexShader;
        IGint fragmentShader;
        IGint shaderProgram;
        IGint positionAttrib;
        IGint vbo;
        IGImage * igImages[2];
    };
    typedef struct IGShadow IGShadow;

    IG_FUNCTION(IGShadow *, ShadowCreate, IGContext * igContext, int width, int height);
    IG_FUNCTION(IGImage *, ShadowRender, IGShadow * igShadow, IGImage *src, IGint diameter, IGfloat red, IGfloat green, IGfloat blue);
    IG_FUNCTION(void, ShadowDestroy, IGShadow * igShadow);

#ifdef __cplusplus
}
#endif
    
#endif