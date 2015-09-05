//
//  Vector.h
//  Generic type-safe array-backed list container for C
//
//  Created by Thor Harald Johansen on 16/08/15.
//  Copyright (c) 2015 Thor Harald Johansen. All rights reserved.
//

#ifndef __IG_VECTOR__
#define __IG_VECTOR__

#include <stdint.h>
#include <stdbool.h>

// Define a vector type
#define vectorDefine(vectorType, elementType) \
    struct vectorType { \
        elementType *elements; \
        int count; \
        int capacity; \
        int _elementSize; \
    }; \
    typedef struct vectorType vectorType

// Internal generic vector type
vectorDefine(_Vector, char);

// Platform-dependent integer types
vectorDefine(CharVector, char);
vectorDefine(UCharVector, unsigned char);
vectorDefine(ShortVector, short);
vectorDefine(UShortVector, unsigned short);
vectorDefine(IntVector, int);
vectorDefine(UIntVector, unsigned int);
vectorDefine(LongVector, long);
vectorDefine(ULongVector, unsigned long);

// Platform-independent integer types
vectorDefine(Int8Vector, int8_t);
vectorDefine(UInt8Vector, uint8_t);
vectorDefine(Int16Vector, int16_t);
vectorDefine(UInt16Vector, uint16_t);
vectorDefine(Int32Vector, int32_t);
vectorDefine(UInt32Vector, uint32_t);
vectorDefine(Int64Vector, int64_t);
vectorDefine(UInt64Vector, uint64_t);

vectorDefine(FloatVector, float);
vectorDefine(DoubleVector, double);

vectorDefine(BoolVector, bool);

// Create a vector and return a pointer to it
#define vectorCreate(vectorType, kapacity) ({ \
    vectorType _dummy; \
    (vectorType *) _vectorCreate(sizeof(*_dummy.elements), kapacity); \
})

// Destroy a vector, freeing all its data structures
#define vectorDestroy(vector) _vectorDestroy((_Vector *) (vector))

// Push element to end of vector and return its index, or -1 if vector is NULL.
#define vectorPush(vector, element) ({ \
    typeof(vector) _vector = vector; \
    typeof(*_vector->elements) _element = element; \
    _vectorPush((_Vector *) _vector, (char *) &_element); \
})

// Pop element from end of vector and return its value. Prints an error message to stderr and
// returns a zero-filled value if the vector is empty or NULL.
#define vectorPop(vector) ({ \
    typeof(vector) _vector = vector; \
    typeof(*_vector->elements) _element; \
    _vectorPop((_Vector *) _vector, (char *) &_element); \
    _element; \
})

// Remove element at index and return element value. Equal or higher elements are moved one index
// down. Prints an error message to stderr and returns a zero-filled value if index is out of
// bounds.
#define vectorRemoveAt(vector, index) ({ \
    typeof(vector) _vector = vector; \
    typeof(*_vector->elements) _element; \
    _vectorRemoveAt((_Vector *) _vector, index, (char *) &_element); \
    _element; \
})

// Remove specified element and return index. Equal or higher elements are moved one index
// down. Prints an error message to stderr and returns -1 if vector is NULL. Returns -1 if
// element is not found.
#define vectorRemove(vector, element) ({ \
    typeof(vector) _vector = vector; \
    typeof(*_vector->elements) _element = element; \
    _vectorRemove((_Vector *) _vector, (char *) &_element); \
})

// Insert element at index. Equal or higher elements are moved one index up. Prints an error
// message to stderr and returns false if the vector is NULL or the index is out of bounds.
#define vectorInsertAt(vector, index, element) ({ \
    typeof(vector) _vector = vector; \
    typeof(*_vector->elements) _element = element; \
    _vectorInsertAt((_Vector *) _vector, index, (char *) &_element); \
})

// Make a copy of a vector and return a pointer to it, or NULL if the input vector is NULL.
#define vectorCopy(vector) ((typeof(vector)) _vectorCopy((_Vector *) (vector)))

// Reverse the elements in a vector. Returns false if vector is NULL.
#define vectorReverse(vector) _vectorReverse((_Vector *) (vector))

// Search a vector of structs for a struct having a member of a given value. Returns the index of
// the matching struct, or -1 if no matches were found. Prints an error message to
// stderr and returns -1 if the vector is NULL.
#define vectorSearch(vector, member, value) ({ \
    typeof(vector) _vector = vector; \
    typeof(value) _value = value; \
    int _index = -1; \
    \
    if(_vector != NULL) { \
        for(int _i = 0; _i < _vector->count; _i++) { \
            if(_vector->elements[_i].member == _value) { \
                _index = _i; \
                break; \
            } \
        } \
    } \
    _index; \
})

// Search a vector of struct pointers for a struct having a member of a given value. NULL pointers
// are handled by skipping over them. Returns a matching element (struct pointer), or NULL if no
// matches were found. Prints an error message to stderr and returns NULL if the vector is NULL.
#define vectorSearchIndirect(vector, member, value) ({ \
    typeof(vector) _vector = vector; \
    typeof(value) _value = value; \
    typeof(_vector->elements) _element = NULL; \
    \
    for(int _i = 0; _i < _vector->count; _i++) { \
        if(_vector->elements[_i] != NULL && _vector->elements[_i]->member == _value) { \
            _element = _vector->elements[_i]; \
            break; \
        } \
    } \
    _element; \
})

#ifdef __cplusplus
extern "C" {
#endif

_Vector * _vectorCreate(int elementSize, int capacity);
void _vectorDestroy(_Vector * vector);
int _vectorPush(_Vector * vector, char * element);
void _vectorPop(_Vector * vector, char * element);
void _vectorRemoveAt(_Vector * vector, int index, char * element);
int _vectorRemove(_Vector * vector, char * element);
bool _vectorInsertAt(_Vector * vector, int index, char * element);
_Vector * _vectorCopy(_Vector * vector);
bool _vectorReverse(_Vector *vector);

#ifdef __cplusplus
}
#endif

#endif