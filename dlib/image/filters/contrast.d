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
 * Adjust contrast
 *
 * Copyright: Timur Gafarov 2011-2025.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.image.filters.contrast;

import dlib.image.image;
import dlib.image.color;

/// Contrast method
enum ContrastMethod
{
    AverageGray,
    AverageImage,
}

/// Adjust contrast
SuperImage contrast(SuperImage img, SuperImage outp, float k, ContrastMethod method = ContrastMethod.AverageGray)
{
    SuperImage res;
    if (outp)
        res = outp;
    else
        res = img.dup;

    Color4f aver = Color4f(0.0f, 0.0f, 0.0f);

    if (method == ContrastMethod.AverageGray)
    {
        aver = Color4f(0.5f, 0.5f, 0.5f);
    }
    else if (method == ContrastMethod.AverageImage)
    {
        foreach(y; 0..res.height)
        foreach(x; 0..res.width)
        {
            aver += img[x, y];
        }

        aver /= (res.height * res.width);
    }

    foreach(y; 0..res.height)
    foreach(x; 0..res.width)
    {
        auto col = img[x, y];
        col = ((col - aver) * k + aver);
        res[x, y] = col;
    }

    return res;
}

/// ditto
SuperImage contrast(SuperImage a, float k, ContrastMethod method = ContrastMethod.AverageGray)
{
    return contrast(a, null, k, method);
}
