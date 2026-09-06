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
 * xxHash64 hash function.
 * 
 * Description:
 * This is a partial D port of xxhash64-ref.c from https://github.com/easyaspi314/xxhash-clean.
 * xxHash is an extremely fast non-cryptographic hash algorithm that is fully-self sufficient
 * and processes data at speeds close to RAM limits. xxHash64 generates 64-bit hashes.
 *
 * Copyright: 2012-2020 Yann Collet, 2019-2020 Devin Hussey
 * License: $(LINK2 opensource.org/license/BSD-2-Clause, BSD 2-Clause License).
 * Authors: Yann Collet, Devin Hussey
 */
module dlib.hash.xxhash64;

private enum ulong PRIME64_1 = 0x9E3779B185EBCA87UL; // 0b1001111000110111011110011011000110000101111010111100101010000111
private enum ulong PRIME64_2 = 0xC2B2AE3D27D4EB4FUL; // 0b1100001010110010101011100011110100100111110101001110101101001111
private enum ulong PRIME64_3 = 0x165667B19E3779F9UL; // 0b0001011001010110011001111011000110011110001101110111100111111001
private enum ulong PRIME64_4 = 0x85EBCA77C2B2AE63UL; // 0b1000010111101011110010100111011111000010101100101010111001100011
private enum ulong PRIME64_5 = 0x27D4EB2F165667C5UL; // 0b0010011111010100111010110010111100010110010101100110011111000101

/// Rotates value left by amt bits.
private ulong xxRotl64(ulong value, uint amt) pure nothrow @safe @nogc
{
    return (value << (amt % 64)) | (value >> (64 - amt % 64));
}

/// Portably reads a 32-bit little endian integer from data at the given offset.
private uint xxRead32(const(ubyte)* data, size_t offset) pure nothrow @nogc
{
    return cast(uint)data[offset + 0]
        | (cast(uint)data[offset + 1] <<  8)
        | (cast(uint)data[offset + 2] << 16)
        | (cast(uint)data[offset + 3] << 24);
}

/// Portably reads a 64-bit little endian integer from data at the given offset.
private ulong xxRead64(const(ubyte)* data, size_t offset) pure nothrow @nogc
{
    return cast(ulong)data[offset + 0]
        | (cast(ulong)data[offset + 1] <<  8)
        | (cast(ulong)data[offset + 2] << 16)
        | (cast(ulong)data[offset + 3] << 24)
        | (cast(ulong)data[offset + 4] << 32)
        | (cast(ulong)data[offset + 5] << 40)
        | (cast(ulong)data[offset + 6] << 48)
        | (cast(ulong)data[offset + 7] << 56);
}

/// Mixes input into acc, this is mostly used in the first loop.
private ulong xxRound(ulong acc, ulong input) pure nothrow @safe @nogc
{
    acc += input * PRIME64_2;
    acc  = xxRotl64(acc, 31);
    acc *= PRIME64_1;
    return acc;
}

/// Merges acc into hash to finalize.
private ulong xxMergeRound(ulong hash, ulong acc) pure nothrow @safe @nogc
{
    hash ^= xxRound(0, acc);
    hash *= PRIME64_1;
    hash += PRIME64_4;
    return hash;
}

/// Mixes all bits to finalize the hash.
private ulong xxAvalanche(ulong hash) pure nothrow @safe @nogc
{
    hash ^= hash >> 33;
    hash *= PRIME64_2;
    hash ^= hash >> 29;
    hash *= PRIME64_3;
    hash ^= hash >> 32;
    return hash;
}

/**
 * The xxHash64 hash function.
 *
 * input:   The data to hash.
 * length:  The length of input. It is undefined behavior to have length larger than the capacity of input.
 * seed:    A 64-bit value to seed the hash with.
 * returns: The 64-bit calculated hash value.
 */
ulong xxHash64(const(void)[] input, ulong seed) pure nothrow @nogc
{
    if (input.length == 0)
        return xxAvalanche(seed + PRIME64_5);
    
    auto data = cast(const(ubyte)*)input.ptr;
    ulong hash = 0;
    size_t remaining = input.length;
    size_t offset = 0;

    if (remaining >= 32)
    {
        // Initialize our accumulators
        ulong acc1 = seed + PRIME64_1 + PRIME64_2;
        ulong acc2 = seed + PRIME64_2;
        ulong acc3 = seed + 0;
        ulong acc4 = seed - PRIME64_1;

        while (remaining >= 32)
        {
            acc1 = xxRound(acc1, xxRead64(data, offset)); offset += 8;
            acc2 = xxRound(acc2, xxRead64(data, offset)); offset += 8;
            acc3 = xxRound(acc3, xxRead64(data, offset)); offset += 8;
            acc4 = xxRound(acc4, xxRead64(data, offset)); offset += 8;
            remaining -= 32;
        }

        hash =
            xxRotl64(acc1, 1) + 
            xxRotl64(acc2, 7) + 
            xxRotl64(acc3, 12) +
            xxRotl64(acc4, 18);

        hash = xxMergeRound(hash, acc1);
        hash = xxMergeRound(hash, acc2);
        hash = xxMergeRound(hash, acc3);
        hash = xxMergeRound(hash, acc4);
    }
    else
    {
        // Not enough data for the main loop, put something in there instead
        hash = seed + PRIME64_5;
    }

    hash += cast(ulong)input.length;

    // Process the remaining data
    while (remaining >= 8)
    {
        hash ^= xxRound(0, xxRead64(data, offset));
        hash  = xxRotl64(hash, 27);
        hash *= PRIME64_1;
        hash += PRIME64_4;
        offset += 8;
        remaining -= 8;
    }

    if (remaining >= 4)
    {
        hash ^= cast(ulong)xxRead32(data, offset) * PRIME64_1;
        hash  = xxRotl64(hash, 23);
        hash *= PRIME64_2;
        hash += PRIME64_3;
        offset += 4;
        remaining -= 4;
    }

    while (remaining != 0)
    {
        hash ^= cast(ulong)data[offset] * PRIME64_5;
        hash  = xxRotl64(hash, 11);
        hash *= PRIME64_1;
        ++offset;
        --remaining;
    }

    return xxAvalanche(hash);
}
