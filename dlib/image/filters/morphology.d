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
 * Morphologic filters
 *
 * Copyright: Timur Gafarov 2011-2025.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.image.filters.morphology;

import dlib.image.color;
import dlib.image.image;
import dlib.image.arithmetics;

/// Morphologic operation
enum MorphOperation
{
    Dilate,
    Erode
}

/// Apply morphologic operation
SuperImage morphOp(MorphOperation op)(SuperImage img, SuperImage outp)
in
{
    assert(img.data.length);
}
do
{
    // TODO:
    // add support for other structuring elements
    // other than box (disk, diamond, etc)
    
    SuperImage res;
    if (outp)
        res = outp;
    else
        res = img.dup;

    uint kw = 3, kh = 3;

    foreach(y; 0..img.height)
    foreach(x; 0..img.width)
    {
        static if (op == MorphOperation.Dilate)
        {
            Color4f resc = Color4f(0, 0, 0, 1);
        }
        static if (op == MorphOperation.Erode)
        {
            Color4f resc = img[x, y];
        }

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

            auto pix = img[ix, iy];

            static if (op == MorphOperation.Dilate)
            {
                if (pix > resc)
                    resc = pix;
            }
            static if (op == MorphOperation.Erode)
            {
                if (pix < resc)
                    resc = pix;
            }
        }

        res[x, y] = resc;
    }

    return res;
}

/// Ditto
SuperImage morph(MorphOperation op) (SuperImage img)
{
    return morphOp!(op)(img, null);
}

/// Dilate
alias dilate = morph!(MorphOperation.Dilate);
/// Erode
alias erode = morph!(MorphOperation.Erode);

/// Morphologic open
SuperImage open(SuperImage img)
{
    return dilate(erode(img));
}

/// ditto
SuperImage open(SuperImage img, SuperImage outp)
{
    if (outp is null)
        outp = img.dup;
    auto outp2 = outp.dup;

    auto e = morphOp!(MorphOperation.Erode)(img, outp2);
    auto d = morphOp!(MorphOperation.Dilate)(outp2, outp);
    outp2.free();
    return d;
}

/// Morphologic close
SuperImage close(SuperImage img)
{
    return erode(dilate(img));
}

/// ditto
SuperImage close(SuperImage img, SuperImage outp)
{
    if (outp is null)
        outp = img.dup;
    auto outp2 = outp.dup;

    auto d = morphOp!(MorphOperation.Dilate)(img, outp2);
    auto e = morphOp!(MorphOperation.Erode)(outp2, outp);
    outp2.free();
    return e;
}

/// Morphologic gradient
SuperImage gradient(SuperImage img)
{
    return subtract(dilate(img), erode(img));
}

/// ditto
SuperImage gradient(SuperImage img, SuperImage outp)
{
    if (outp is null)
        outp = img.dup;
    auto outp2 = outp.dup;

    auto d = morphOp!(MorphOperation.Dilate)(img, outp2);
    auto e = morphOp!(MorphOperation.Erode)(img, outp);
    auto s = subtract(d, e, outp);
    outp2.free();
    return s;
}

/// White top-hat transform
SuperImage topHatWhite(SuperImage img)
{
    return subtract(img, open(img));
}

/// ditto
SuperImage topHatWhite(SuperImage img, SuperImage outp)
{
    if (outp is null)
        outp = img.dup;
    auto o = open(img, outp);
    auto s = subtract(img, o, outp);
    return s;
}

/// Black top-hat transform
SuperImage topHatBlack(SuperImage img)
{
    return subtract(img, close(img));
}

/// ditto
SuperImage topHatBlack(SuperImage img, SuperImage outp)
{
    if (outp is null)
        outp = img.dup;
    auto o = close(img, outp);
    auto s = subtract(img, o, outp);
    return s;
}
