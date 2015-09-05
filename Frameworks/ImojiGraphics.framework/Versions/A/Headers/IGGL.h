#ifndef __IG_GL__
#define __IG_GL__

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

#if TARGET_OS_IPHONE
#define IG_USE_GLES
@import OpenGLES;
@import CoreVideo;
#elif TARGET_OS_MAC
#define IG_USE_GL
#include <GL/glew.h>
#include <GLUT/glut.h>
#elif defined __ANDROID__
#define IG_USE_GLES
#include <GLES2/gl2.h>
#include <EGL/egl.h>
#else
#define IG_USE_GL
#include <GL/glew.h>
#include <GL/glut.h>
#endif

#endif
