/*
Copyright (c) 2018-2020 Timur Gafarov

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
 * Generic encoding tools
 *
 * Description:
 * This module works with any encoder and decoder structs that implement 
 * the following basic interfaces:
 * ---
 * struct Encoder
 * {
 *     // Encodes a Unicode code point to user-provided buffer.
 *     // Should return bytes written or 0 at error
 *     size_t encode(uint codePoint, char[] buffer)
 * }
 *
 * struct Decoder
 * {
 *     // An input range that iterates characters of a string, 
 *     // decoding them to Unicode code points
 *     auto decode(string input)
 * }
 * ---
 *
 * Copyright: Timur Gafarov 2018-2020.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.text.encodings;

import dlib.container.array;
import dlib.text.utils;

public
{
    import dlib.text.utf8;
    import dlib.text.utf16;
}

/**
 * Converts a string from one encoding to another.
 * Decoder and encoder are specified at compile time
 *
 * Examples:
 * ---
 * string s = transcode!(UTF16Decoder, UTF8Encoder)(input);
 * ---
 */
string transcode(Decoder, Encoder)(string input)
{
    DynamicArray!char array;
	
    auto decoder = Decoder();
	auto encoder = Encoder();
    
    foreach(c; decoder.decode(input))
    {
        char[4] buffer;
        size_t len = encoder.encode(c, buffer);
        if (len)
            array.append(buffer[0..len]);
    }
    
    auto output = copy(array.data);
    array.free();
    return cast(string)output;
}
