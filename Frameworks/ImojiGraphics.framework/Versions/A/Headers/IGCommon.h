//
//  IGCommon.h
//  ImojiGraphics
//
//  Created by Thor Harald Johansen on 18/05/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//
//  Because our headers need to be Android NDK compatible, some special rules need to be followed when writing them:
//
//  1. Always declare and define exported functions using the IG_FUNCTION() macro.
//
//  2. Always call exported functions using the IG_CALL() macro when using them internally. NDK will not build your
//     code if you forget this.
//
//  3. Only use IGint and friends in function argument and return types.
//
//  4. Pointers are allowed. They're unsafely cast to ints in Java, where they work as opaque handles. This will
//     continue to work until NDK code must be compiled for 64-bit ARM, at which point the IG.java class will need to
//     be rewritten to use longs.
//
//  5. Because pointers are just opaque handles in Java, you must, where necessary, offer a way to allocate, modify and
//     destroy any pointers you accept or return in exported functions.
//
//  6. Enums are allowed if you typedef them like this...
//
//        typedef IGint IGYourEnum;
//
//     ...on Android and like this...
//
//        typedef enum IGYourEnum IGYourEnum;
//
//     ...on other platforms.
//
//  Other conventions to follow when modifying this code base:
//
//  1. Use lowerCamelCase for variable names and UpperCamelCase for type names.
//
//  2. Prefix all type names with IG, ex. IGNotMyType.
//
//  3. If you find yourself allocating buffers and resizing them frequently, stop it. Vector.h is your friend. Vectors
//     are handy even for fixed-size buffers because vectors store their own length (see vector->count).
//
//  4. Try to avoid including any platform-specific headers. If you really do need to, check your platforms with macros,
//     and try to provide iOS, Android and desktop/generic versions of whatever it is you're implementing.

#ifndef __IG_COMMON_H__
#define __IG_COMMON_H__

// Fixed-point precision for Clipper (number of sub-pixels per axis)
#define CLIPPER_FACTOR 8.0f // Coordinate range of +/- 5792.5 with use_int32

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

#define igMin(a, b) ({ \
    typeof(a) _a = a; \
    typeof(b) _b = b; \
    _a < _b ? _a : _b; \
})

#define igMax(a, b) ({ \
    typeof(a) _a = a; \
    typeof(b) _b = b; \
    _a > _b ? _a : _b; \
})

#include <sys/time.h>
static inline long long currentTimeMillis() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return ((tv.tv_sec * 1000LL) + (tv.tv_usec / 1000LL));
}

#if defined __ANDROID__

#include <jni.h>
#include <android/log.h>

typedef jlong IGlong;
typedef jint IGint;
typedef jshort IGshort;
typedef jbyte IGchar;
typedef jboolean IGbool;
typedef jfloat IGfloat;
typedef jdouble IGdouble;

#define IG_USE_RGBA

#define IG_FUNCTION(return_type, name, ...) return_type Java_com_imojiapp_imojigraphics_IG_ ## name(JNIEnv *env, jclass clazz, ##__VA_ARGS__)

#define IG_CALL(name, ...) Java_com_imojiapp_imojigraphics_IG_ ## name(NULL, NULL, ##__VA_ARGS__)

#define printf(...) __android_log_print(ANDROID_LOG_INFO, "ImojiGraphics", ##__VA_ARGS__)
#define fprintf(file, ...) ((file) == stderr ? __android_log_print(ANDROID_LOG_ERROR, "ImojiGraphics", ##__VA_ARGS__) : fprintf(file, ##__VA_ARGS__))

#else

#include <stdint.h>
#include <stdbool.h>

typedef int64_t IGlong;
typedef int32_t IGint;
typedef int16_t IGshort;
typedef int8_t IGchar;
typedef bool IGbool;
typedef float IGfloat;
typedef double IGdouble;

#if !TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#define IG_USE_RGBA
#else
#define IG_USE_BGRA
#endif

#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#define IG_USE_CORE_VIDEO_TEXTURES
#else
#define IG_USE_PLAIN_TEXTURES
#endif

#if TARGET_IPHONE_SIMULATOR
#define IG_PREFER_CORE_GRAPHICS
#endif

#define IG_FUNCTION(return_type, name, ...) return_type ig ## name(__VA_ARGS__)

#define IG_CALL(name, ...) ig ## name(__VA_ARGS__)

#endif

#endif
