/*
Copyright (c) 2011-2020 Timur Gafarov

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
 * Bicubic resampling
 *
 * Copyright: Timur Gafarov 2011-2020.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.image.resampling.bicubic;

import std.math;
import dlib.image.image;
import dlib.image.color;

T bicubic(T) (T x)
{
    if (x > 2.0)
        return 0.0;

    T a, b, c, d;
    T xm1 = x - 1.0;
    T xp1 = x + 1.0;
    T xp2 = x + 2.0;

    a = ( xp2 <= 0.0 ) ? 0.0 : xp2 * xp2 * xp2;
    b = ( xp1 <= 0.0 ) ? 0.0 : xp1 * xp1 * xp1;
    c = ( x   <= 0.0 ) ? 0.0 : x * x * x;
    d = ( xm1 <= 0.0 ) ? 0.0 : xm1 * xm1 * xm1;

    return ( 0.16666666666666666667 *
           ( a - ( 4.0 * b ) + ( 6.0 * c ) - ( 4.0 * d ) ) );
}

/// Resize image with bicubic filter
SuperImage resampleBicubic(SuperImage img, uint newWidth, uint newHeight)
in
{
    assert (img.data.length);
}
do
{
    SuperImage res = img.createSameFormat(newWidth, newHeight);

    float xFactor = cast(float)img.width  / cast(float)newWidth;
    float yFactor = cast(float)img.height / cast(float)newHeight;

    foreach(x; 0..res.width)
    {
        float ox = x * xFactor - 0.5f;
        int ox1 = cast(int)ox;
        float dx = ox - ox1;

        foreach(y; 0..res.height)
        {
            float oy = y * yFactor - 0.5f;
            int oy1 = cast(int)oy;
            float dy = oy - oy1;

            Color4f colSum = Color4f(0, 0, 0);

            foreach(kx; -1..3)
            {
                int ix = ox1 + kx;

                if (ix < 0) ix = 0;
                if (ix >= img.width) ix = img.width - 1;

                foreach(ky; -1..3)
                {
                    int iy = oy1 + ky;

                    if (iy < 0) iy = 0;
                    if (iy >= img.height) iy = img.height - 1;

                    auto col = img[ix, iy];

                    float k1 = bicubic(dy - cast(float)ky);
                    float k2 = k1 * bicubic(cast(float)kx - dx);

                    colSum += col * k2;
                }
            }

            res[x, y] = colSum;
        }
    }

    return res;
}
