/*
Copyright (c) 2015-2020 Timur Gafarov

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
 * Copyright: Timur Gafarov 2015-2020.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.coding.varint;

/**
 * Protobuf-style variable-sized integers
 */
struct Varint
{
    ubyte[8] buffer;
    size_t size;

    ubyte[] bytes() return
    {
        return buffer[0..size];
    }
}

/**
 * Returns size in bytes necessary to store an integer
 */
size_t getVarintSize(ulong n)
{
    enum ulong N1 = 128;
    enum ulong N2 = 16384;
    enum ulong N3 = 2097152;
    enum ulong N4 = 268435456;
    enum ulong N5 = 34359738368;
    enum ulong N6 = 4398046511104;
    enum ulong N7 = 562949953421312;
    enum ulong N8 = 72057594037927936;

    return (
        n < N1 ? 1
      : n < N2 ? 2
      : n < N3 ? 3
      : n < N4 ? 4
      : n < N5 ? 5
      : n < N6 ? 6
      : n < N7 ? 7
      :          8
    );
}

/**
 * Encode a fixed-size integer to Varint
 */
Varint encodeVarint(ulong n)
{
    Varint res;
    res.size = getVarintSize(n);
    ubyte* ptr = res.buffer.ptr;

    for (uint i = 0; i < res.size; i++)
    {
        if (i == res.size - 1)
            *(ptr++) = n & 0xFF;
        else
            *(ptr++) = cast(ubyte)(n | 0x80);
        n >>= 7;
    }

    return res;
}

/**
 * Decode Varing to fixed-size integer
 */
ulong decodeVarint(Varint vint)
{
    ulong result = 0;
    int bits = 0;
    ubyte* ptr = vint.buffer.ptr;
    ulong ll;

    while (*ptr & 0x80)
    {
        ll = *ptr;
        result += ((ll & 0x7F) << bits);
        ptr++;
        bits += 7;
    }

    ll = *ptr;
    result += ((ll & 0x7F) << bits);

    return result;
}
