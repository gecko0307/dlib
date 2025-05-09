/*
Copyright (c) 2011-2025 Timur Gafarov

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
 * Image convolution
 *
 * Copyright: Timur Gafarov 2011-2025.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.image.filters.convolution;

import std.algorithm;
import dlib.image.image;
import dlib.image.color;

/// Convolve an image with a kernel
SuperImage convolve(SuperImage img,
                    SuperImage outp,
                    float[] kernel,
                    uint kw = 3,
                    uint kh = 3,
                    float divisor = 1.0f,
                    float offset = 0.5f,
                    bool normalize = true,
                    bool useAlpha = true)
in
{
    assert(img.data.length);
    assert(kernel.length == kw * kh);
}
do
{
    SuperImage res;
    if (outp)
        res = outp;
    else
        res = img.dup;

    float kernelSum = reduce!((a,b) => a + b)(kernel);

    foreach(y; 0..img.height)
    foreach(x; 0..img.width)
    {
        float alpha = Color4f(img[x, y]).a;

        Color4f csum = Color4f(0, 0, 0);

        foreach(ky; 0..kh)
        foreach(kx; 0..kw)
        {
            int iy = y + (ky - kh/2);
            int ix = x + (kx - kw/2);

            // Extend
            if (ix < 0) ix = 0;
            if (ix >= img.width) ix = img.width - 1;
            if (iy < 0) iy = 0;
            if (iy >= img.height) iy = img.height - 1;

            // TODO:
            // Wrap

            auto pix = Color4f(img[ix, iy]);
            auto k = kernel[kx + ky * kw];

            csum += pix * k;
        }

        if (normalize)
        {
            offset = 0.0f;
            divisor = kernelSum;

            if (divisor == 0.0f)
            {
                divisor = 1.0f;
                offset = 0.5f;
            }

            if (divisor < 0.0f)
                offset = 1.0f;
        }

        csum = csum / divisor + offset;

        if (!useAlpha)
            csum.a = alpha;

        res[x,y] = csum;
    }

    return res;
}

/// ditto
SuperImage convolve(SuperImage img,
                    float[] kernel,
                    uint kw = 3,
                    uint kh = 3,
                    float divisor = 1.0f,
                    float offset = 0.5f,
                    bool normalize = true,
                    bool useAlpha = true)
{
    return convolve(img, null, kernel, kw, kh, divisor, offset, normalize, useAlpha);
}

/// Various built-in convolution kernels
struct Kernel
{
    enum float[]

    Identity =
    [
        0, 0, 0,
        0, 1, 0,
        0, 0, 0
    ],

    BoxBlur =
    [
        1, 1, 1,
        1, 1, 1,
        1, 1, 1
    ],

    GaussianBlur =
    [
        1, 2, 1,
        2, 4, 2,
        1, 2, 1
    ],

    Sharpen =
    [
        -1, -1, -1,
        -1, 11, -1,
        -1, -1, -1
    ],

    Emboss =
    [
       -1, -1,  0,
       -1,  0,  1,
        0,  1,  1,
    ],

    EdgeEmboss =
    [
        -1.0f, -0.5f, -0.0f,
        -0.5f,  1.0f,  0.5f,
        -0.0f,  0.5f,  1.0f
    ],

    EdgeDetect =
    [
        -1, -1, -1,
        -1,  8, -1,
        -1, -1, -1,
    ],

    Laplace =
    [
        0,  1,  0,
        1, -4,  1,
        0,  1,  0,
    ];
}
