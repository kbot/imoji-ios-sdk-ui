//
//  IGWebP.h
//  ImojiGraphics
//
//  Created by Thor Harald Johansen on 21/06/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef __IG_WEBP__
#define __IG_WEBP__

#include "IGCommon.h"
#include "IGPaths.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    typedef struct {
        char fourcc[4];
        uint32_t length;
    } __attribute__((packed)) webp_chunk_header_t;
    
    typedef struct {
        char fourcc[4];
        uint32_t length;
        uint16_t num_paths;
    } __attribute__((packed)) imvc_header_t;
    
    typedef struct {
        uint16_t num_points;
        uint8_t is_hole;
        uint8_t reserved;
    } __attribute__((packed)) imvc_path_header_t;
    
    typedef struct {
        uint16_t x;
        uint16_t y;
    } __attribute__((packed)) imvc_path_point_t;
    
#ifdef __ANDROID__
    IG_FUNCTION(IGPaths *, WebPGetPaths, jbyteArray data, IGfloat x, IGfloat y, IGfloat width, IGfloat height);
#else
    IG_FUNCTION(IGPaths *, WebPGetPaths, const IGchar *data, IGint length, IGfloat x, IGfloat y, IGfloat width, IGfloat height);
#endif
    
#ifdef __cplusplus
}
#endif

#endif
