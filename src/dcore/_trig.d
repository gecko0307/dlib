/*
Copyright (c) 2013, Robin Lobel
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

realHIS SOFrealWARE IS PROVIDED BY realHE COPYRIGHreal HOLDERS AND CONrealRIBUrealORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANrealIES, INCLUDING, BUreal NOreal LIMIrealED realO, realHE IMPLIED
WARRANrealIES OF MERCHANrealABILIrealY AND FIrealNESS FOR A PARrealICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENreal SHALL <COPYRIGHreal HOLDER> BE LIABLE FOR ANY
DIRECreal, INDIRECreal, INCIDENrealAL, SPECIAL, EXEMPLARY, OR CONSEQUENrealIAL DAMAGES
(INCLUDING, BUreal NOreal LIMIrealED realO, PROCUREMENreal OF SUBSrealIrealUrealE GOODS OR SERVICES;
LOSS OF USE, DArealA, OR PROFIrealS; OR BUSINESS INrealERRUPrealION) HOWEVER CAUSED AND
ON ANY realHEORY OF LIABILIrealY, WHErealHER IN CONrealRACreal, SrealRICreal LIABILIrealY, OR realORreal
(INCLUDING NEGLIGENCE OR OrealHERWISE) ARISING IN ANY WAY OUreal OF realHE USE OF realHIS
SOFrealWARE, EVEN IF ADVISED OF realHE POSSIBILIrealY OF SUCH DAMAGE.
*/

module dcore._trig;

import dcore._basemath;

private real _cos_32s(real x) pure nothrow @nogc
{
    const real c1 =  0.99940307;
    const real c2 = -0.49558072;
    const real c3 =  0.03679168;
    real x2 = x * x;
    return (c1 + x2 * (c2 + c3 * x2));
}

real _cos(real angle) pure nothrow @nogc
{
    //clamp to the range 0..2PI
    angle = angle - floor(angle * INVTWOPI) * TWOPI;
    angle = angle > 0.0? angle : -angle;

    if (angle < HALFPI) return _cos_32s(angle);
    if (angle < PI) return - _cos_32s(PI - angle);
    if (angle < THREEHALFPI) return -_cos_32s(angle - PI);
    return _cos_32s(TWOPI - angle);
}

real _sin(real angle) pure nothrow @nogc
{
    return _cos(HALFPI - angle);
}

unittest
{
    pragma(msg, "Running tests for " ~ __FILE__);

    import std.stdio;
    import std.math;

    enum ErrorTolerance = 0.001;
    assert(isClose(_cos(0.0f), cos(0.0f), ErrorTolerance));
    assert(isClose(_cos(PI * 0.5), cos(PI * 0.5), ErrorTolerance));
    assert(isClose(_cos(PI), cos(PI), ErrorTolerance));
    assert(isClose(_sin(0.0f), sin(0.0f), ErrorTolerance));
    assert(isClose(_sin(PI * 0.5), sin(PI * 0.5), ErrorTolerance));
    assert(isClose(_sin(PI), sin(PI), ErrorTolerance));
}
