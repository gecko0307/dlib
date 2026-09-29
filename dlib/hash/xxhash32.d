/*
 *  Copyright (C) 2012-2020 Yann Collet
 *  Copyright (C) 2019-2020 Devin Hussey (easyaspi314)
 *
 *  BSD 2-Clause License (https://opensource.org/license/BSD-2-Clause)
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *  * Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above
 *  copyright notice, this list of conditions and the following disclaimer
 *  in the documentation and/or other materials provided with the
 *  distribution.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *  You can contact the author at:
 *  - xxHash homepage: http://www.xxhash.com
 *  - xxHash source repository: https://github.com/Cyan4973/xxHash
 */

/**
 * xxHash32 hash function.
 * 
 * Description:
 * This is a partial D port of xxhash32-ref.c from https://github.com/easyaspi314/xxhash-clean.
 * xxHash is an extremely fast non-cryptographic hash algorithm that is fully-self sufficient
 * and processes data at speeds close to RAM limits. xxHash32 generates 32-bit hashes.
 *
 * Copyright: 2012-2020 Yann Collet, 2019-2020 Devin Hussey
 * License: $(LINK2 opensource.org/license/BSD-2-Clause, BSD 2-Clause License).
 * Authors: Yann Collet, Devin Hussey; D port by Timur Gafarov
 */
module dlib.hash.xxhash32;

private enum uint PRIME32_1 = 0x9E3779B1U; // 0b10011110001101110111100110110001
private enum uint PRIME32_2 = 0x85EBCA77U; // 0b10000101111010111100101001110111
private enum uint PRIME32_3 = 0xC2B2AE3DU; // 0b11000010101100101010111000111101
private enum uint PRIME32_4 = 0x27D4EB2FU; // 0b00100111110101001110101100101111
private enum uint PRIME32_5 = 0x165667B1U; // 0b00010110010101100110011110110001

/// Portably reads a 32-bit little endian integer from data at the given offset.
uint xxRead32(const(ubyte)* data, size_t offset) pure nothrow @nogc
{
    return cast(uint)data[offset + 0]
        | (cast(uint)data[offset + 1] <<  8)
        | (cast(uint)data[offset + 2] << 16)
        | (cast(uint)data[offset + 3] << 24);
}

/// Rotates value left by amt.
private uint xxRotl32(uint value, uint amt) pure nothrow @safe @nogc
{
    return (value << (amt % 32)) | (value >> (32 - (amt % 32)));
}

/// Mixes input into acc.
private uint xxRound(uint acc, uint input) pure nothrow @safe @nogc
{
    acc += input * PRIME32_2;
    acc  = xxRotl32(acc, 13);
    acc *= PRIME32_1;
    return acc;
}

/// Mixes all bits to finalize the hash.
private uint xxAvalanche(uint hash) pure nothrow @safe @nogc
{
    hash ^= hash >> 15;
    hash *= PRIME32_2;
    hash ^= hash >> 13;
    hash *= PRIME32_3;
    hash ^= hash >> 16;
    return hash;
}

/**
 * The xxHash32 hash function.
 *
 * input:   The data to hash.
 * length:  The length of input. It is undefined behavior to have length larger than the capacity of input.
 * seed:    A 32-bit value to seed the hash with.
 * returns: The 32-bit calculated hash value.
 */
uint xxHash32(const(void)[] input, uint seed) pure nothrow @nogc
{
    if (input.length == 0)
        return xxAvalanche(seed + PRIME32_5);
    
    auto data = cast(const(ubyte)*)input.ptr;
    uint hash;
    size_t remaining = input.length;
    size_t offset = 0;

    if (remaining >= 16)
    {
        // Initialize our accumulators
        uint acc1 = seed + PRIME32_1 + PRIME32_2;
        uint acc2 = seed + PRIME32_2;
        uint acc3 = seed + 0;
        uint acc4 = seed - PRIME32_1;

        while (remaining >= 16)
        {
            acc1 = xxRound(acc1, xxRead32(data, offset)); offset += 4;
            acc2 = xxRound(acc2, xxRead32(data, offset)); offset += 4;
            acc3 = xxRound(acc3, xxRead32(data, offset)); offset += 4;
            acc4 = xxRound(acc4, xxRead32(data, offset)); offset += 4;
            remaining -= 16;
        }

        hash =
            xxRotl32(acc1, 1) +
            xxRotl32(acc2, 7) +
            xxRotl32(acc3, 12) +
            xxRotl32(acc4, 18);
    }
    else
    {
        // Not enough data for the main loop, put something in there instead
        hash = seed + PRIME32_5;
    }

    hash += cast(uint)input.length;

    // Process the remaining data
    while (remaining >= 4)
    {
        hash += xxRead32(data, offset) * PRIME32_3;
        hash  = xxRotl32(hash, 17);
        hash *= PRIME32_4;
        offset += 4;
        remaining -= 4;
    }

    while (remaining != 0)
    {
        hash += cast(uint)data[offset] * PRIME32_5;
        hash  = xxRotl32(hash, 11);
        hash *= PRIME32_1;
        --remaining;
        ++offset;
    }
    
    return xxAvalanche(hash);
}
