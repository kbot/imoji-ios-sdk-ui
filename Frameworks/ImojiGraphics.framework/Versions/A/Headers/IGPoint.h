//
//  IGPoint.h
//  BorderApp
//
//  Created by Thor Harald Johansen on 14/05/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef IG_POINT_H
#define IG_POINT_H

#include <stdbool.h>

#include "IGCommon.h"

#ifdef __cplusplus
extern "C" {
#endif

    struct IGFPoint {
        float x;
        float y;
        float u;
        float v;
    };
    typedef struct IGFPoint IGFPoint;

    struct IGIPoint {
        int x;
        int y;
        int u;
        int v;
    };
    typedef struct IGIPoint IGIPoint;
    
    struct IGFPointOnLine {
        IGFPoint p; // Point P projected onto line AB
        IGfloat t;  // Normalized position of P along AB
        IGfloat d;  // Distance from P to projection
    };
    typedef struct IGFPointOnLine IGFPointOnLine;

    IG_FUNCTION(IGFPoint *, FPointCreate, IGfloat x, IGfloat y);
    
    IG_FUNCTION(IGfloat, FPointGetX, IGFPoint * igFPoint);
    
    IG_FUNCTION(IGfloat, FPointGetY, IGFPoint * igFPoint);
    
    IG_FUNCTION(void, FPointDestroy, IGFPoint * igFPoint);
    
    IG_FUNCTION(IGIPoint *, IPointCreate, IGint x, IGint y);
 
    IG_FUNCTION(IGint, IPointGetX, IGIPoint * igIPoint);
    
    IG_FUNCTION(IGint, IPointGetY, IGIPoint * igIPoint);
    
    IG_FUNCTION(void, IPointDestroy, IGIPoint * igIPoint);
    
    IG_FUNCTION(IGFPointOnLine, FPointOnLine, IGFPoint * a, IGFPoint * b, IGFPoint * p, bool clamp);
    
    static inline IGFPoint igFPoint(float x, float y) {
        IGFPoint igFloatPoint = {x, y};
        return igFloatPoint;
    }

    static inline IGIPoint igIPoint(int x, int y) {
        IGIPoint igIntPoint = {x, y};
        return igIntPoint;
    }
    
#ifdef __cplusplus
}
#endif
    
#endif