/*
Copyright (c) 2013-2025 Timur Gafarov

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
 * Fast Fourier transform
 *
 * Copyright: Timur Gafarov 2013-2025.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.math.fft;

import std.math;
import dlib.math.utils;
import dlib.math.complex;

/// Forward or backward fast Fourier transform. Data must be power of two in length
void fastFourierTransform(Complexf[] data, bool forward)
{
    assert(isPowerOfTwo(data.length));

    uint target = 0;

    for (uint pos = 0; pos < data.length; ++pos)
    {
        if (target > pos)
        {
            Complexf temp = data[target];
            data[target] = data[pos];
            data[pos] = temp;
        }
        uint mask = cast(uint)data.length;
        while (target & (mask >>= 1))
            target &= ~mask;
        target |= mask;
    }

    float pi = forward? -PI : PI;

    for (uint step = 1; step < data.length; step <<= 1)
    {
        uint jump = step << 1;
        float delta = pi / cast(float)step;
        float sine = sin(delta * 0.5f);
        Complexf multiplier = Complexf(-2.0f * sine * sine, sin(delta));
        Complexf factor = Complexf(1.0f);

        for (uint group = 0; group < step; ++group)
        {
            for (uint pair = group; pair < data.length; pair += jump)
            {
                uint match = pair + step;
                Complexf product = factor * data[match];
                data[match] = data[pair] - product;
                data[pair] += product;
            }

            factor = multiplier * factor + factor;
        }
    }
}

///
unittest
{
    Complexf[4] data =
    [
        Complexf(1.0f, 0.0f),
        Complexf(2.0f, 0.0f),
        Complexf(3.0f, 0.0f),
        Complexf(4.0f, 0.0f)
    ];
    
    fastFourierTransform(data, true);
    
    assert(data[0].toString == "10 + 0i");
    assert(data[1].toString == "-2 + 2i");
    assert(data[2].toString == "-2 + 0i");
    assert(data[3].toString == "-2 + -2i");
}
