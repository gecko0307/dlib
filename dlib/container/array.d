/*
Copyright (c) 2015-2025 Timur Gafarov

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
 * Dynamic (expandable) array with random access
 *
 * Copyright: Timur Gafarov 2015-2025.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov, Roman Vlasov, Andrey Penechko, Eugene Wissner, Roman Chistokhodov, aferust, ijet
 */
module dlib.container.array;

import std.traits;
import dlib.core.memory;

/**
 * GC-free dynamic array implementation.
 * Very efficient for small-sized arrays.
 */
struct Array(T, size_t chunkSize = 32)
{
  private:
    T[chunkSize] staticStorage;
    T[] dynamicStorage;
    uint numChunks = 0;
    uint pos = 0;

    /**
     * Get pointer to stored data
     */
    private T* storage() nothrow
    {
        if (numChunks == 0)
            return staticStorage.ptr;
        else
            return dynamicStorage.ptr;
    }

    private const(T)* readOnlyStorage() const nothrow
    {
        if (numChunks == 0)
            return staticStorage.ptr;
        else
            return dynamicStorage.ptr;
    }

    private void addChunk()
    {
        if (numChunks == 0)
        {
            dynamicStorage = New!(T[])(chunkSize);
        }
        else
        {
            reallocateArray(
                dynamicStorage,
                dynamicStorage.length + chunkSize);
        }
        numChunks++;
    }

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        assert(arr.length == 0);
        arr.addChunk();
        assert(arr.length == 0);
    }

  public:
    /**
     * Returns true if the array uses dynamic memory.
     */
    @property bool isDynamic() const
    {
        return dynamicStorage.length > 0;
    }

    /**
     * Preallocate memory without resizing.
     */
    void reserve(const(size_t) amount)
    {
        if (amount > pos && amount > staticStorage.length)
        {
            if (numChunks == 0)
            {
                dynamicStorage = New!(T[])(amount);
                foreach(i, v; staticStorage)
                    dynamicStorage[i] = v;
            }
            else
            {
                reallocateArray(dynamicStorage, amount);
            }

            numChunks = cast(uint)(amount / 32 + amount % 32);
        }
    }

    ///
    unittest
    {
        Array!int arr;
        arr.reserve(100);
        assert(arr.length == 0);
        assert(arr.dynamicStorage.length == 100);
    }

    /**
     * Resize array and initialize newly added elements with initValue.
     */
    void resize(const(size_t) newLen, T initValue)
    {
        if (newLen > pos)
        {
            reserve(newLen);
            for(size_t i = pos; i < newLen; i++)
            {
                storage[i] = initValue;
            }
        }

        pos = cast(uint)newLen;
    }

    ///
    unittest
    {
        Array!int arr;
        arr.resize(100, 1);
        assert(arr.length == 100);
        assert(arr[50] == 1);
    }

    /**
     * Shift contents of array to the right.
     * It inreases the size of array by 1.
     * The first element becomes default initialized.
     */
    void shiftRight()
    {
        insertBack(T.init);

        for(uint i = pos-1; i > 0; i--)
        {
            storage[i] = storage[i-1];
        }
    }

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr.shiftRight();
        assert(arr.length == 1);
        assert(arr[0] == int.init);

        arr[0] = 1;
        arr.insertBack([2,3]);

        arr.shiftRight();
        assert(arr.length == 4);
        assert(arr[0] == 1);
        assert(arr[1] == 1);
        assert(arr[2] == 2);
        assert(arr[3] == 3);
    }

    /**
     * Shift contents of array to the left by n positions.
     * Does not change the size of array.
     * n of last elements becomes default initialized.
     */
    void shiftLeft(const(uint) n)
    {
        for(uint i = 0; i < pos; i++)
        {
            if (n + i < pos)
                storage[i] = storage[n + i];
            else
                storage[i] = T.init;
        }
    }

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr.shiftLeft(1);
        assert(arr.length == 0);

        arr.insertBack([1,2,3,4,5]);

        arr.shiftLeft(2);
        assert(arr.length == 5);
        assert(arr[0] == 3);
        assert(arr[1] == 4);
        assert(arr[2] == 5);
        assert(arr[3] == int.init);
        assert(arr[4] == int.init);
    }

    /**
     * Append single element c to the end.
     */
    void insertBack(T c)
    {
        if (numChunks == 0)
        {
            staticStorage[pos] = c;
            pos++;
            if (pos == chunkSize)
            {
                addChunk();
                foreach(i, ref v; dynamicStorage)
                    v = staticStorage[i];
            }
        }
        else
        {
            if (pos == dynamicStorage.length)
                addChunk();

            dynamicStorage[pos] = c;
            pos++;
        }
    }

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        foreach(i; 0..16) {
            arr.insertBack(i);
        }
        assert(arr.length == 16);
        arr.insertBack(16);
        assert(arr.length == 17);
        assert(arr[16] == 16);
    }

    /**
     * Append element to the start.
     */
    void insertFront(T c)
    {
        shiftRight();
        storage[0] = c;
    }

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr.insertFront(1);
        arr.insertBack(2);
        arr.insertFront(0);
        assert(arr.data == [0,1,2]);
    }

    /**
     * Append all elements of slice s to the end.
     */
    void insertBack(const(T)[] s)
    {
        foreach(c; s)
            insertBack(cast(T)c);
    }

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr.insertBack([1,2,3,4]);
        assert(arr.data == [1,2,3,4]);
        arr.insertBack([5,6,7,8]);
        assert(arr.data == [1,2,3,4,5,6,7,8]);
    }

    /**
     * Append all elements of slice s to the start.
     */
    void insertFront(const(T)[] s)
    {
        foreach_reverse(c; s)
            insertFront(cast(T)c);
    }

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr.insertFront([5,6,7,8]);
        assert(arr.data == [5,6,7,8]);
        arr.insertFront([1,2,3,4]);
        assert(arr.data == [1,2,3,4,5,6,7,8]);
    }

    /**
     * Same as insertBack, but in operator form.
     */
    auto opOpAssign(string op)(T c) if (op == "~")
    {
        insertBack(c);
        return this;
    }

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr ~= 1;
        arr ~= 2;
        assert(arr.data == [1,2]);
    }

    /**
     * Same as insertBack, but in operator form.
     */
    auto opOpAssign(string op)(const(T)[] s) if (op == "~")
    {
        insertBack(s);
        return this;
    }

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr ~= [1,2,3];
        assert(arr.data == [1,2,3]);
    }

    /**
     * Remove n of elements from the end.
     * Returns: number of removed elements.
     */
    uint removeBack(const(uint) n)
    {
        if (pos == n)
        {
            pos = 0;
            return n;
        }
        else if (pos >= n)
        {
            pos -= n;
            return n;
        }
        else
        {
            uint res = pos;
            pos = 0;
            return res;
        }
    }

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr.insertBack([1,2,3]);
        assert(arr.removeBack(3) == 3);
        assert(arr.length == 0);

        arr.insertBack([1,2,3,4]);
        assert(arr.removeBack(2) == 2);
        assert(arr.data == [1,2]);

        assert(arr.removeBack(3) == 2);
        assert(arr.length == 0);
    }

    /**
     * Remove n of elements from the start.
     * Returns: number of removed elements.
     */
    uint removeFront(const(uint) n)
    {
        if (pos == n)
        {
            pos = 0;
            return n;
        }
        else if (pos > n)
        {
            shiftLeft(n);
            pos -= n;
            return n;
        }
        else
        {
            uint res = pos;
            pos = 0;
            return res;
        }
    }

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr.insertBack([1,2,3]);
        assert(arr.removeFront(3) == 3);

        arr.insertBack([1,2,3,4]);
        assert(arr.removeFront(2) == 2);
        assert(arr.data == [3,4]);

        assert(arr.removeFront(3) == 2);
        assert(arr.length == 0);
    }

    /**
     * Inserts an element by a given index
     * (resizing an array and shifting elements).
     */
    void insertKey(const(size_t) i, T v)
    {
        if (i < pos)
        {
            T* s = storage();

            insertBack(T.init);

            for (size_t p = pos-1; p > i; p--)
            {
                s[p] = s[p-1];
            }

            s[i] = v;
        }
    }

    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr.insertBack([1, 4, 5]);

        arr.insertKey(1, 7);
        assert(arr.length == 4);
        assert(arr.data == [1, 7, 4, 5]);
    }

    /**
     * Removes an element by a given index.
     */
    void removeKey(const(size_t) i)
    {
        if (i < pos)
        {
            T* s = storage();
            for (size_t p = i+1; p <= pos; p++)
            {
                s[p-1] = s[p];
            }

            pos--;
        }
    }

    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr.insertBack([1, 4, 5]);

        arr.removeKey(1);
        assert(arr.length == 2);
        assert(arr.data == [1, 5]);
    }

    alias insertAt = insertKey;
    alias removeAt = removeKey;

    /**
     * If obj is in array, remove its first occurence and return true.
     * Otherwise do nothing and return false.
     */
    bool removeFirst(T obj)
    {
        size_t index;
        bool found = false;

        for (size_t i = 0; i < data.length; i++)
        {
            T o = data[i];

            static if (isArray!T)
            {
                if (o[] == obj[])
                {
                    index = i;
                    found = true;
                    break;
                }
            }
            else
            {
                if (o is obj)
                {
                    index = i;
                    found = true;
                    break;
                }
            }
        }

        if (found)
        {
            removeKey(index);
            return true;
        }

        return false;
    }

    // For backward compatibility
    alias append = insertBack;
    alias appendLeft = insertFront;
    alias remove = removeBack;
    alias removeLeft = removeFront;

    /**
     * Get number of elements in array.
     */
    size_t length() const nothrow
    {
        return pos;
    }

    alias opDollar = length;

    ///
    unittest
    {
        Array!int arr;
        scope(exit) arr.free();

        arr.insertBack([1,2,3]);
        assert(arr.length == 3);
    }

    /**
     * Get slice of data
     */
    T[] data() nothrow
    {
        return storage[0..pos];
    }

    const(T)[] readOnlyData() const nothrow
    {
        return readOnlyStorage[0..pos];
    }

    ///
    unittest
    {
        Array!(int,4) arr;
        scope(exit) arr.free();

        foreach(i; 0..6) {
            arr.insertBack(i);
        }

        assert(arr.data == [0,1,2,3,4,5]);
    }

    /**
     * Access element by index.
     */
    T opIndex(const(size_t) index)
    {
        return data[index];
    }

    /**
     * Access by slice.
     */
    T[] opSlice(const(size_t) start, const(size_t) end)
    {
        return data[start..end];
    }

    /**
     * Set element t for index.
     */
    T opIndexAssign(T t, const(size_t) index)
    {
        data[index] = t;
        return t;
    }

    /**
     * Iterating over array via foreach.
     */
    int opApply(scope int delegate(size_t i, ref T) dg)
    {
        int result = 0;

        foreach(i, ref v; data)
        {
            result = dg(i, v);
            if (result)
                break;
        }

        return result;
    }

    /**
     * Iterating over array via foreach_reverse.
     */
    int opApplyReverse(scope int delegate(size_t i, ref T) dg)
    {
        int result = 0;

        for(size_t i =  length; i-- > 0; )
        {
            result = dg(i, data[i]);
            if (result)
                break;
        }

        return result;
    }

    ///
    unittest
    {
        Array!(int,4) arr;
        scope(exit) arr.free();

        int[4] values;
        arr.insertBack([1,2,3,4]);
        foreach(i, ref val; arr) {
            values[i] = val;
            if(values[i] == 4) {
                break;
            }
        }
        assert(values[] == arr.data);
    }

    /**
     * Iterating over array via foreach.
     */
    int opApply(scope int delegate(ref T) dg)
    {
        int result = 0;

        foreach(i, ref v; data)
        {
            result = dg(v);
            if (result)
                break;
        }

        return 0;
    }

     /**
     * Iterating over array via foreach_reverse.
     */
    int opApplyReverse(scope int delegate(ref T) dg)
    {
        int result = 0;

        for(size_t i = length; i-- > 0; )
        {
            result = dg(data[i]);
            if (result)
                break;
        }

        return result;
    }

    ///
    unittest
    {
        Array!(int,4) arr;
        scope(exit) arr.free();

        int[] values;
        arr.insertBack([1,2,3,4]);
        foreach(ref val; arr) {
            values ~= val;
        }
        assert(values[] == arr.data);
    }

    /**
     * Free dynamically allocated memory used by array.
     */
    void free()
    {
        if (dynamicStorage.length)
            Delete(dynamicStorage);
        numChunks = 0;
        pos = 0;
    }
}

void reallocateArray(T)(ref T[] buffer, const(size_t) len)
{
    T[] buffer2 = New!(T[])(len);
    for(uint i = 0; i < buffer2.length; i++)
        if (i < buffer.length)
            buffer2[i] = buffer[i];
    Delete(buffer);
    buffer = buffer2;
}

///
unittest
{
    auto arr = New!(int[])(3);
    arr[0] = 1; arr[1] = 2; arr[2] = 3;

    reallocateArray(arr, 2);
    assert(arr.length == 2);
    assert(arr[0] == 1);
    assert(arr[1] == 2);

    reallocateArray(arr, 4);
    assert(arr.length == 4);
    assert(arr[0] == 1);
    assert(arr[1] == 2);
}
