//
//  ClipperOffset.h
//  BorderApp
//
//  Created by Thor Harald Johansen on 14/05/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef IG_CLIPPER_H
#define IG_CLIPPER_H

#include "IGCommon.h"
#include "IGPaths.h"

#ifdef __cplusplus
extern "C" {
#endif

    struct IGOffset;
    typedef struct IGOffset IGOffset;

    IG_FUNCTION(IGOffset *, OffsetCreate);
    
    IG_FUNCTION(void, OffsetAddPath, IGOffset * igOffset, IGPath * igPath);
    
    IG_FUNCTION(void, OffsetAddPaths, IGOffset * igOffset, IGPaths * igPaths);
    
    IG_FUNCTION(IGPaths *, OffsetPerform, IGOffset * igOffset, float delta);
    
    IG_FUNCTION(void, OffsetDestroy, IGOffset * igOffset);
    
#ifdef __cplusplus
}
#endif
    
#endif