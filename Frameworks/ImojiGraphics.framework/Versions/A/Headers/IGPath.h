//
//  IGPath.h
//  BorderApp
//
//  Created by Thor Harald Johansen on 14/05/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef IG_PATH_H
#define IG_PATH_H

#include <stdlib.h>
#include <stdbool.h>

#include "IGCommon.h"
#include "IGPoint.h"
#include "Vector.h"

#ifdef __cplusplus
extern "C" {
#endif

    vectorDefine(IGPath, IGFPoint);

    IG_FUNCTION(IGPath *, PathCreate, IGint capacity);

    IG_FUNCTION(void, PathDestroy, IGPath * igPath);

    IG_FUNCTION(IGint, PathGetCapacity, IGPath * igPath);

    IG_FUNCTION(IGFPoint *, PathGetPoints, IGPath * igPath);

    IG_FUNCTION(void, PathAddPoint, IGPath * igPath, IGFPoint igPoint);

    IG_FUNCTION(void, PathAddPointXY, IGPath * igPath, IGfloat x, IGfloat y);

    IG_FUNCTION(IGFPoint *, PathGetPoint, IGPath * igPath, IGint index);
    
    IG_FUNCTION(IGint, PathGetCount, IGPath * igPath);
    
    IG_FUNCTION(IGPath *, PathSubview, IGPath * igPath, int firstIndex, int lastIndex);
    
    IG_FUNCTION(IGPath *, PathReduce, IGPath * igPath, float epsilon);
    
    IG_FUNCTION(IGPath *, PathSimplify, IGPath * igPath);
    
    IG_FUNCTION(IGPath *, PathSmooth, IGPath * igPath, IGint window, IGbool closed);
    
    IG_FUNCTION(IGPath *, PathUniform, IGPath * igPath, float pitch, IGbool closed);
    
    IG_FUNCTION(IGPath *, PathCopy, IGPath * igPath);
    
    IG_FUNCTION(void, PathTranslate, IGPath * igPath, float tx, float ty);
    
    IG_FUNCTION(void, PathScale, IGPath * igPath, float sx, float sy);

    IG_FUNCTION(void, PathReverse, IGPath * igPath);
    
    IG_FUNCTION(IGfloat, PathGetArea, IGPath * igPath, IGbool closed);

    IG_FUNCTION(IGbool, PathGetOrientation, IGPath * igPath, IGbool closed);
    
    IG_FUNCTION(IGPath *, PathConcatenate, IGPath * igPath1, IGPath * igPath2);
    
    IG_FUNCTION(void, PathMoveEnds, IGPath * igPath, IGFPoint firstTo, IGFPoint lastTo);
    
    IG_FUNCTION(FloatVector *, PathGetOdometry, IGPath * igPath, bool closed);
    
    IG_FUNCTION(float, PathOdometryGetLength, FloatVector * odometry);

#ifdef __cplusplus
}
#endif

#endif
