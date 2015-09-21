//
//  IGPaths.h
//  BorderApp
//
//  Created by Thor Harald Johansen on 14/05/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef IG_PATHS_H
#define IG_PATHS_H

#include "IGCommon.h"
#include "IGPath.h"

#ifdef __cplusplus
extern "C" {
#endif

    vectorDefine(IGPaths, IGPath *);

    IG_FUNCTION(IGPaths *, PathsCreate, IGint capacity);

    IG_FUNCTION(void, PathsDestroy, IGPaths * igPaths, IGbool destroyPaths);

    IG_FUNCTION(IGint, PathsGetCapacity, IGPaths * igPaths);

    IG_FUNCTION(void, PathsAddPath, IGPaths * igPaths, IGPath * igPath);
    
    IG_FUNCTION(IGPath *, PathsRemovePathAt, IGPaths * igPaths, IGint index, bool destroyPath);
    
    IG_FUNCTION(IGPath *, PathsGetPath, IGPaths * igPaths, IGint index);
    
    IG_FUNCTION(IGint, PathsGetCount, IGPaths * igPaths);

    IG_FUNCTION(IGint, PathsGetPointCount, IGPaths * igPaths);

    IG_FUNCTION(void, PathsTranslate, IGPaths * igPaths, float tx, float ty);
    
    IG_FUNCTION(void, PathsScale, IGPaths * igPaths, float sx, float sy);
    
    IG_FUNCTION(void, PathsReverse, IGPaths * igPaths);
    
    IG_FUNCTION(IGPaths *, PathsReduce, IGPaths * igPaths, IGfloat epsilon);
    
    IG_FUNCTION(IGPaths *, PathsSmooth, IGPaths * igPaths, IGint window, IGbool closed);
    
    IG_FUNCTION(IGPaths *, PathsUniform, IGPaths * igPaths, float pitch, IGbool closed);
    
    IG_FUNCTION(IGPaths *, PathsSimplify, IGPaths * igPaths);

    IG_FUNCTION(IGPaths *, PathsCopy, IGPaths * igPaths);

    IG_FUNCTION(IGPaths *, PathsJoinEnds, IGPaths * igPaths, IGfloat maxDistance);
    
    void pathsSerialize(IGPaths * igPaths, UInt8Vector * toVector);
    
    void pathsDeserialize(IGPaths * igPaths, UInt8Vector * fromVector);

#ifdef __cplusplus
}
#endif
    
#endif
