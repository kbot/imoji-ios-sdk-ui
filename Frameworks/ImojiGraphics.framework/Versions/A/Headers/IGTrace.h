//
//  IGTrace.h
//  ImojiGraphics
//
//  Created by Thor Harald Johansen on 15/05/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef __IG_TRACE__
#define __IG_TRACE__

#include "IGCommon.h"
#include "IGImage.h"
#include "IGPaths.h"

#ifdef __cplusplus
extern "C" {
#endif

    // Extract paths from image alpha channel
    IG_FUNCTION(IGPaths *, PathsFromImageAlpha, IGImage * igImage);

#ifdef __cplusplus
}
#endif

#endif
