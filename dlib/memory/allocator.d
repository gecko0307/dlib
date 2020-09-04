/*
Copyright (c) 2016-2020 Eugene Wissner

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

/**
 * Abstract allocator interface
 *
 * Copyright: Eugene Wissner 2016-2020.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Eugene Wissner
 */
module dlib.memory.allocator;

version (unittest)
{
    import dlib.memory : defaultAllocator;
}

/**
 * Allocator interface.
 */
interface Allocator
{
    /**
     * Allocates $(D_PARAM size) bytes of memory.
     *
     * Params:
     *     size = Amount of memory to allocate.
     *
     * Returns: The pointer to the new allocated memory.
     */
    void[] allocate(size_t size);

    /**
     * Deallocates a memory block.
     *
     * Params:
     *     p = A pointer to the memory block to be freed.
     *
     * Returns: Whether the deallocation was successful.
     */
    bool deallocate(void[] p);

    /**
     * Increases or decreases the size of a memory block.
     *
     * Params:
     *     p    = A pointer to the memory block.
     *     size = Size of the reallocated block.
     *
     * Returns: Whether the reallocation was successful.
     */
    bool reallocate(ref void[] p, size_t size);

    /**
     * Returns: The alignment offered.
     */
    @property immutable(uint) alignment() const @safe pure nothrow;
}

/**
 * Params:
 *     T         = Element type of the array being created.
 *     allocator = The allocator used for getting memory.
 *     array     = A reference to the array being changed.
 *     length    = New array length.
 *
 * Returns: $(D_KEYWORD true) upon success, $(D_KEYWORD false) if memory could
 *          not be reallocated. In the latter
 */
bool resizeArray(T)(Allocator allocator,
                    ref T[] array,
                    in size_t length)
{
    void[] buf = array;

    if (!allocator.reallocate(buf, length * T.sizeof))
    {
        return false;
    }
    array = cast(T[]) buf;

    return true;
}

///
unittest
{
    int[] p;

    defaultAllocator.resizeArray(p, 20);
    assert(p.length == 20);

    defaultAllocator.resizeArray(p, 30);
    assert(p.length == 30);

    defaultAllocator.resizeArray(p, 10);
    assert(p.length == 10);

    defaultAllocator.resizeArray(p, 0);
    assert(p is null);
}

enum bool isFinalizable(T) = is(T == class) || is(T == interface)
                           || hasElaborateDestructor!T || isDynamicArray!T;

