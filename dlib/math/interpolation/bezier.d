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
 * Bézier interpolation functions
 *
 * Copyright: Timur Gafarov 2013-2025.
 * License: $(LINK2 boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors: Timur Gafarov
 */
module dlib.math.interpolation.bezier;

import dlib.math.vector;

/**
 * Computes quadratic Bézier curve
 */
T bezierQuadratic(T)(T A, T B, T C, T t)
{
    T s = cast(T)1.0 - t;
    return s * s * A + 2.0 * s * B + t * t * C;
}

/**
 * Computes cubic Bézier curve
 */
T bezierCubic(T) (T A, T B, T C, T D, T t)
{
    T s = cast(T)1.0 - t;
    T s2 = s * s;
    T s3 = s2 * s;
    return s3 * A +
           3.0 * t * s2 * B +
           3.0 * t * t * s * C +
           t * t * t * D;
}

/// ditto
alias bezier = bezierCubic;

/**
 * Computes cubic Bézier curve tangent
 */
T bezierCubicTangent(T)(T a, T b, T c, T d, T t)
{
    T c1 = (d - (3.0 * c) + (3.0 * b) - a);
    T c2 = ((3.0 * c) - (6.0 * b) + (3.0 * a));
    T c3 = ((3.0 * b) - (3.0 * a));
    return ((3.0 * c1 * t * t) + (2.0 * c2 * t) + c3);
}

/// ditto
alias bezierTangent = bezierCubicTangent;

/**
 * Computes cubic Bézier curve in 2D space
 */
Vector!(T,2) bezierVector2(T)(
    Vector!(T,2) a,
    Vector!(T,2) b,
    Vector!(T,2) c,
    Vector!(T,2) d,
    T t)
{
    return Vector!(T,2)
    (
        bezier(a.x, b.x, c.x, d.x, t),
        bezier(a.y, b.y, c.y, d.y, t)
    );
}

/**
 * Computes cubic Bézier curve in 3D space
 */
Vector!(T,3) bezierVector3(T)(
    Vector!(T,3) a,
    Vector!(T,3) b,
    Vector!(T,3) c,
    Vector!(T,3) d,
    T t)
{
    return Vector!(T,3)
    (
        bezier(a.x, b.x, c.x, d.x, t),
        bezier(a.y, b.y, c.y, d.y, t),
        bezier(a.z, b.z, c.z, d.z, t)
    );
}

/**
 * Computes cubic Bézier curve tangent in 2D space
 */
Vector!(T,2) bezierTangentVector2(T)(
    Vector!(T,2) a,
    Vector!(T,2) b,
    Vector!(T,2) c,
    Vector!(T,2) d,
    T t)
{
    return Vector!(T,2)
    (
        bezierTangent(a.x, b.x, c.x, d.x, t),
        bezierTangent(a.y, b.y, c.y, d.y, t)
    );
}

/**
 * Computes cubic Bézier curve tangent in 3D space
 */
Vector!(T,3) bezierTangentVector3(T)(
    Vector!(T,3) a,
    Vector!(T,3) b,
    Vector!(T,3) c,
    Vector!(T,3) d,
    T t)
{
    return Vector!(T,3)
    (
        bezierTangent(a.x, b.x, c.x, d.x, t),
        bezierTangent(a.y, b.y, c.y, d.y, t),
        bezierTangent(a.z, b.z, c.z, d.z, t)
    );
}
