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
#include <stddef.h>

// Define a vector type
#define vectorDefine(vectorType, elementType) \
    struct vectorType { \
        elementType *elements; \
        size_t count; \
        size_t capacity; \
        size_t readCursor; \
        size_t _elementSize; \
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

#define vectorWrite(vector, element) vectorPush(vector, element)

// Push bytes to end of vector and return its index, or -1 if vector is NULL or
// the length is not a multiple of the element size.
#define vectorPushData(vector, data, length) ({ \
    typeof(vector) _vector = vector; \
    typeof(data) _data = data; \
    typeof(length) _length = length; \
    _vectorPushData((_Vector *) _vector, (char *) _data, _length); \
})

#define vectorWriteData(vector, data, length) vectorPushData(vector, data, length)

// Pop element from end of vector and return its value. Prints an error message to stderr and
// returns a zero-filled value if the vector is empty or NULL.
#define vectorPop(vector) ({ \
    typeof(vector) _vector = vector; \
    typeof(*_vector->elements) _element; \
    _vectorPop((_Vector *) _vector, (char *) &_element); \
    _element; \
})

// Read element at cursor, advance the cursor, and return the element's value. Prints an error
// message to stderr and returns a zero-filled value if the vector is empty or NULL.
#define vectorRead(vector) ({ \
    typeof(vector) _vector = vector; \
    typeof(*_vector->elements) _element; \
    _vectorRead((_Vector *) _vector, (char *) &_element); \
    _element; \
})

// Pop bytes from end of vector and return true. Prints an error message to stderr and
// returns false the vector is too small or NULL, or the length is not a multiple of the
// element size.
#define vectorPopData(vector, data, length) ({ \
    typeof(vector) _vector = vector; \
    typeof(data) _data = data; \
    typeof(length) _length = length; \
    _vectorPopData((_Vector *) _vector, (char *) _data, _length); \
})

// Read bytes at cursor, advance cursor, and return true. Prints an error message to
// stderr and returns false the vector is too small or NULL, or the length is not a
// multiple of the element size.
#define vectorReadData(vector, data, length) ({ \
typeof(vector) _vector = vector; \
typeof(data) _data = data; \
typeof(length) _length = length; \
_vectorReadData((_Vector *) _vector, (char *) _data, _length); \
})

// Move cursor to given position, and return true. Prints an error message to stderr
// and returns false if the position is greater than the vector count.
#define vectorSeek(vector, position) ({ \
typeof(vector) _vector = vector; \
typeof(position) _position = position; \
_vectorSeek((_Vector *) _vector, _position); \
})

// Push element to end of vector and return its index, or -1 if vector is NULL.
#define vectorAvailable(vector) ({ \
    typeof(vector) _vector = vector; \
    _vector->count - _vector->readCursor; \
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

#define vectorBinaryInsert(vector, element, compar) ({ \
    typeof(vector) _vector = vector; \
    typeof(*_vector->elements) _element = element; \
    _vectorBinaryInsert((_Vector *) _vector, (char *) &_element, (compar)); \
})

#define vectorBinarySearch(vector, element, compar) ({ \
    typeof(vector) _vector = vector; \
    typeof(*_vector->elements) _element = element; \
    _vectorBinarySearch((_Vector *) _vector, (char *) &_element, (compar)); \
})

// Make a copy of a vector and return a pointer to it, or NULL if the input vector is NULL.
#define vectorCopy(vector) ((typeof(vector)) _vectorCopy((_Vector *) (vector)))

// Reverse the elements in a vector. Returns false if vector is NULL.
#define vectorReverse(vector) _vectorReverse((_Vector *) (vector))

#define vectorSerialize(vector, toVector) ({ \
    typeof(vector) _vector = vector; \
    typeof(toVector) _toVector = toVector; \
    \
    _vectorSerialize((_Vector *) _vector, _toVector); \
})

#define vectorDeserialize(vector, fromVector) ({ \
    typeof(vector) _vector = vector; \
    typeof(fromVector) _fromVector = fromVector; \
    \
    _vectorDeserialize((_Vector *) _vector, _fromVector); \
})

#ifdef __cplusplus
extern "C" {
#endif

_Vector * _vectorCreate(size_t elementSize, size_t capacity);
void _vectorDestroy(_Vector * vector);
int _vectorPush(_Vector * vector, char * element);
int _vectorPushData(_Vector * vector, char * data, size_t length);
void _vectorPop(_Vector * vector, char * element);
void _vectorRead(_Vector * vector, char * element);
bool _vectorPopData(_Vector * vector, char * data, size_t length);
bool _vectorReadData(_Vector * vector, char * data, size_t length);
bool _vectorSeek(_Vector * vector, size_t position);
void _vectorRemoveAt(_Vector * vector, size_t index, char * element);
int _vectorRemove(_Vector * vector, char * element);
bool _vectorInsertAt(_Vector * vector, size_t index, char * element);
int _vectorBinaryInsert(_Vector * vector, char * element, int (*compar)(const void *, const void *));
_Vector * _vectorCopy(_Vector * vector);
bool _vectorReverse(_Vector *vector);
int _vectorBinarySearch(_Vector * vector, char * element, int (*compar)(const void *, const void *));
void _vectorSerialize(_Vector * vector, UInt8Vector * toVector);
void _vectorDeserialize(_Vector * vector, UInt8Vector * fromVector);

#ifdef __cplusplus
}
#endif

#endif
