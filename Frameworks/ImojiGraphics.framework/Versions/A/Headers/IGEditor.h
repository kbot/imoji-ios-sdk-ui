//
//  IGEditor.h
//  ImojiGraphics
//
//  Created by Thor Harald Johansen on 12/07/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef __IG_EDITOR__
#define __IG_EDITOR__

#include <stdio.h>
#include <math.h>

#include "IGCommon.h"
#include "IGContext.h"
#include "IGImage.h"
#include "IGCanvas.h"
#include "IGBorder.h"
#include "IGPaths.h"
#include "IGTrace.h"
#include "Vector.h"

#ifdef __cplusplus
extern "C" {
#endif

    enum IGTouchType {
        IG_TOUCH_BEGAN = 1,
        IG_TOUCH_MOVED,
        IG_TOUCH_ENDED,
        IG_TOUCH_CANCELED
    };
    
    enum IGEditorState {
        IG_EDITOR_DRAW = 1,
        IG_EDITOR_NUDGE
    };
    typedef enum IGEditorState IGEditorState;
    
    enum IGEditorSubstate {
        IG_EDITOR_IDLE = 1,
        IG_EDITOR_DRAG,
        IG_EDITOR_PINCH,
        IG_EDITOR_HOLD
    };
    typedef enum IGEditorSubstate IGEditorSubstate;
    
#if __ANDROID__
    typedef IGint IGTouchID;
    typedef IGint IGTouchType;
#else
    typedef const void * IGTouchID;
    typedef enum IGTouchType IGTouchType;
#endif

    struct IGTouch {
        IGTouchID uid;
        IGFPoint position;
        IGFPoint origin;
    };
    typedef struct IGTouch IGTouch;
    
    enum IGTouchGestureType {
        IG_GESTURE_NONE = 0,
        IG_GESTURE_SINGLE,
        IG_GESTURE_DOUBLE,
        IG_GESTURE_UNKNOWN
    };
    typedef enum IGTouchGestureType IGTouchGestureType;

    struct IGTouchGesture {
        IGTouchGestureType type;
        
        struct {
            IGFPoint position;
            IGfloat gap;
        } origin;
        
        struct {
            IGFPoint position;
            IGfloat gap;
        } current;
    };
    typedef struct IGTouchGesture IGTouchGesture;
    
    vectorDefine(IGTouches, IGTouch);
    
    static inline IGTouch igTouch(IGTouchID uid, IGfloat x, IGfloat y) {
        IGTouch touch;
        touch.uid = uid;
        touch.position.x = x;
        touch.position.y = y;
        touch.origin = touch.position;
        return touch;
    }
    
    struct IGEditorHistoryItem {
        IGEditorState state;
        IGPaths * edgePaths;
    };
    typedef struct IGEditorHistoryItem IGEditorHistoryItem;
    
    vectorDefine(IGEditorHistory, IGEditorHistoryItem);

    struct IGEditor {
        IGContext * igContext;
        IGImage * igInputImage;
        IGImage * igViewportImage;
        IGCanvas * igViewportCanvas;
        
        struct {
            IGPaths * paths; // Edge polygon(s)
            IGIPoint min; // Upper left bounds
            IGIPoint max; // Lower right bounds
            IGfloat pitch; // Desired polygon pitch as fraction of polygon size
            IGbool nudged;
        } edge;
        
        IGBorder * igBorder;
        IGImage * igBorderImage;
        
        IGEditorState state;
        IGEditorSubstate substate;

        // Viewport state
        IGfloat x, y, scale;
        IGfloat startX, startY, startScale;
        IGTouches * touches;

        IGfloat strokeWidth;

        // Viewport colors
        struct {
            IGfloat background[4];
            IGfloat strokes[4];
            IGfloat dots[4];
        } colors;
        
        IGfloat igInputImageAlpha;
        
        struct {
            IGFPoint lastPosition;
            IGfloat size;
        } nudge;
        
        IGEditorHistory * history;
    };
    typedef struct IGEditor IGEditor;
    
    IG_FUNCTION(IGEditor *, EditorCreate, IGImage * igInputImage);
    
    IG_FUNCTION(void, EditorDestroy, IGEditor * igEditor);
    
    // Renders the editor viewport into the current OpenGL context. The OpenGL context must stay the same for the
    // life time of the editor object.
    IG_FUNCTION(void, EditorDisplay, IGEditor * igEditor);
    
    // Set background color of editor
    IG_FUNCTION(void, EditorSetBackgroundColor, IGEditor * igEditor, IGint red, IGint green, IGint blue, IGint alpha);
    
    // Set color of strokes in draw mode
    IG_FUNCTION(void, EditorSetStrokeColor, IGEditor * igEditor, IGint red, IGint green, IGint blue, IGint alpha);
    
    // Set width (in pixels) of strokes in draw mode
    IG_FUNCTION(void, EditorSetStrokeWidth, IGEditor * igEditor, float strokeWidth);

    // Set color of dots in draw mode; small line dots overlap the big cursor dot
    IG_FUNCTION(void, EditorSetDotColor, IGEditor * igEditor, IGint red, IGint green, IGint blue, IGint alpha);

    // The touch event function handles all touch events in the editor viewport. Call EditorDisplay() after this.
    //
    // The UID must uniquely and persistently identify each touch through its lifetime. On Android, an int is accepted
    // for use with MotionEvent.getPointerId(). On iOS, the memory location of UITouch stays constant, so a void
    // pointer is accepted. In Swift, use unsafeAddressOf().
    //
    // The specific value of the UID is insignificant; it is used for strict equality comparison only. The unit of
    // measurement for the this function is OpenGL viewport pixels. The origin of the coordinate system is the top left
    // corner of the viewport.
    //
    IG_FUNCTION(void, EditorTouchEvent, IGEditor * igEditor, IGTouchType type, IGTouchID uid, IGfloat x, IGfloat y);

    // The unit of measurement for the functions below is input image pixels
    // The origin of the coordinate system is the top left corner of the image
    
    // Instantly center the viewport on the given image point. Call EditorDisplay() after this.
    IG_FUNCTION(void, EditorScrollTo, IGEditor * igEditor, IGfloat x, IGfloat y);
    
    // Instantly zoom viewport to 'zoom' times, centered around the scroll point. Call EditorDisplay() after this.
    IG_FUNCTION(void, EditorZoomTo, IGEditor * igEditor, IGfloat zoom);
    
    // Return true if there are items in the undo history
    IG_FUNCTION(IGbool, EditorCanUndo, IGEditor * igEditor);

    // Performs undo operation. Call EditorDisplay() after this.
    IG_FUNCTION(void, EditorUndo, IGEditor * igEditor);

    // Return copy of edge paths, for use with BorderSetEdgePaths() or WebP embedded chunk
    IG_FUNCTION(IGPaths *, EditorGetEdgePaths, IGEditor * igEditor);
    
    // Return an output image, cropped to bounds of edge paths
    IG_FUNCTION(IGImage *, EditorGetOutputImage, IGEditor * igEditor);

    // Return an output image, cropped and trimmed to the edge paths
    IG_FUNCTION(IGImage *, EditorGetTrimmedOutputImage, IGEditor * igEditor);
    
    // Returns true if an imoji is ready for output via GetOutputImage()
    IG_FUNCTION(IGbool, EditorImojiIsReady, IGEditor * igEditor);

#ifdef __ANDROID__
    // Serializes the current state, including the edge paths, the undo history and the visual settings of the editor
    // into an array and returns it.
    IG_FUNCTION(jbyteArray, EditorSerialize, IGEditor * igEditor);

    // Deserializes the current state, including the edge paths, the undo history and the visual settings of the editor
    // from an array.
    IG_FUNCTION(void, EditorDeserialize, IGEditor * igEditor, jbyteArray data);
#else
    // Serializes the current state, including the edge paths, the undo history and the visual settings of the editor
    // into an array. 'data' should point to a vacant char pointer, 'length' to a vacant size_t. A malloc()'ed array of
    // serialized data will be placed in 'data', and the data length in bytes is written to 'length'. The data should
    // be free()'d after use.
    IG_FUNCTION(void, EditorSerialize, IGEditor * igEditor, char ** data, size_t * length);

    // Deserializes the current state, including the edge paths, the undo history and the visual settings of the editor
    // from an array. 'data' should point to an array of data previously serialized with EditorSerialize(), 'length'
    // should indicate the data length in bytes.
    IG_FUNCTION(void, EditorDeserialize, IGEditor * igEditor, const char * data, size_t length);
#endif
    
#ifdef __cplusplus
}
#endif

#endif
