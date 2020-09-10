/*
Copyright (c) 2013 Robin Lobel
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

module dcore.math._trig;

import dcore.math._basemath;

private double cos_32s(double x) pure nothrow @nogc
{
    const double c1 =  0.99940307;
    const double c2 = -0.49558072;
    const double c3 =  0.03679168;
    double x2 = x * x;
    return (c1 + x2 * (c2 + c3 * x2));
}

double cos(double angle) pure nothrow @nogc
{
    //clamp to the range 0..2PI
    angle = angle - floor(angle * INVTWOPI) * TWOPI;
    angle = angle > 0.0? angle : -angle;

    if (angle < HALFPI) return cos_32s(angle);
    if (angle < PI) return - cos_32s(PI - angle);
    if (angle < THREEHALFPI) return -cos_32s(angle - PI);
    return cos_32s(TWOPI - angle);
}

double sin(double angle) pure nothrow @nogc
{
    return cos(HALFPI - angle);
}

unittest
{
    import std.math: stdsin = sin, stdcos = cos;

    enum ErrorTolerance = 0.001;
    assert(isClose(cos(0.0f), stdcos(0.0f), ErrorTolerance));
    assert(isClose(cos(PI * 0.5), stdcos(PI * 0.5), ErrorTolerance));
    assert(isClose(cos(PI), stdcos(PI), ErrorTolerance));
    assert(isClose(sin(0.0f), stdsin(0.0f), ErrorTolerance));
    assert(isClose(sin(PI * 0.5), stdsin(PI * 0.5), ErrorTolerance));
    assert(isClose(sin(PI), stdsin(PI), ErrorTolerance));
}
