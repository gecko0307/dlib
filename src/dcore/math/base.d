/*
Copyright (c) 2019-2024 Timur Gafarov

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

module dcore.math.base;

//version = UseFreeStandingMath;
//version = NoPhobos;

enum double PI = 3.14159265358979323846;
enum double HALFPI = 1.5707964;
enum double QUARTPI = 0.7853982;
enum double INVPI = 0.31830988618;
enum double INVTWOPI = 0.15915494309;
enum double TWOPI = 6.28318530718;
enum double THREEHALFPI = 4.7123889;

bool isNaN(T)(T x) pure nothrow @nogc
{
    pragma(inline, true);
    return x != x;
}

int isInfinity(T)(T x) pure nothrow @nogc
{
    pragma(inline, true);
    return !isNaN(x) && isNaN(x - x);
}

T max(T)(T a, T b) pure nothrow @nogc
{
    pragma(inline, true);
    return (a > b)? a : b;
}

T min(T)(T a, T b) pure nothrow @nogc
{
    pragma(inline, true);
    return (a < b)? a : b;
}

T abs(T)(T v) pure nothrow @nogc
{
    pragma(inline, true);
    return (v > 0.0)? v : -v;
}

T clamp(T)(T v, T mi, T ma) pure nothrow @nogc
{
    pragma(inline, true);
    if (v < mi) return mi;
    else if (v > ma) return ma;
    else return v;
}

bool isClose(T)(T a, T b, T delta) pure nothrow @nogc
{
    pragma(inline, true);
    return abs(a - b) < delta;
}

T sqrtFallback(T)(T x) pure nothrow @nogc
{
    version(UseX87Math)
    {
        T result;
        
        if (is(T == float))
        {
            asm pure nothrow @nogc
            {
                fld dword ptr x;
                fsqrt;
                fstp dword ptr result;
            }
        }
        else
        {
            asm pure nothrow @nogc
            {
                fld qword ptr x;
                fsqrt;
                fstp qword ptr result;
            }
        }
        
        return result;
    }
    else
    {
        double z = cast(double)(x > 1.0) ? x * 0.5 : x + 1.0;
        for (uint i = 1; i <= 10; i++)
        {
            z -= (z * z - x) / (2.0 * z);
        }
        return cast(T)z;
    }
}

T cbrtFallback(T)(T x) pure nothrow @nogc
{
    enum OneOverThree = 1.0 / 3.0;
    if (x < 0) return -cbrt(-x);
    if (isNaN(x) || isInfinity(x)) return x;
    if (x == 0) return 0;
    T a = sqrtFallback(x);
    T b = T.infinity;
    while (a < b)
    {
        b = a;
        a = (2.0 * a + (x / (b * b))) * OneOverThree;
    }
    return a;
}

T tanFallback(T)(T x) pure nothrow @nogc
{
    pragma(inline, true);
    return sin(x) / cos(x);
}

T atanFallback(T)(T x) pure nothrow @nogc
{
    // Implementation from Algol 60
    const T        R1 =  0x1.9310cfe85307cp+3;
    const T        R2 = -0x1.58beca04f1805p+6;
    const T        R3 = -0x1.46d547fed8a3dp+0;
    const T        R4 = -0x1.57bd961f06c89p-4;
    const T        S1 =  0x1.b189e39236635p+4;
    const T        S2 =  0x1.a3b86f7830dc0p+2;
    const T        S3 =  0x1.1273f9e5eff20p+1;
    const T        S4 =  0x1.44831dafbf542p+0;
    const T       RT3 =  0x1.bb67ae8584caap+0;
    const T     PIBY6 =  0x1.0c152382d7365p-1;
    const T   PIBY2M1 =  0x1.243f6a8885a30p-1;
    const T     RT3M1 =  0x1.76cf5d0b09955p-1;
    const T TANPIBY12 =  0x1.126145e9ecd56p-2;
    const T       ONE =  0x1.0000000000000p+0;

    double XX1, XSQ, CONSTANT = 0.0;
    int SIGN = 0, INV = 0;

    if (x < 0) { SIGN = 1; XX1 = -x; } else XX1 = x;
    if (XX1 > ONE) { XX1 = 1.0 / XX1; INV = 1; }
    if (XX1 > TANPIBY12) { XX1 = (RT3M1 * XX1 - 1.0 + XX1) / (XX1 + RT3); CONSTANT = PIBY6; }

    XSQ = XX1 * XX1;
    XX1 = XX1 * (R1 / (XSQ + S1 + R2 / (XSQ + S2 + R3 / (XSQ + S3 + R4 / (XSQ + S4)))));
    XX1 = XX1 + CONSTANT;

    if (INV) XX1 = 1.0 - XX1 + PIBY2M1;
    if (SIGN) XX1 = -XX1;
     
    return XX1;
}

T asinFallback(T)(T x) pure nothrow @nogc
{
    return atan2Fallback(x, sqrt(1.0 - x * x));
}

T acosFallback(T)(T x) pure nothrow @nogc
{
    return atan2Fallback(sqrt(1.0 - x * x), x);
}

T atan2Fallback(T)(T y, T x) pure nothrow @nogc
{
    if (x > 0)
        return atan(y / x);
    else if (x < 0 && y >= 0)
        return atan(y / x) + PI;
    else if (x < 0 && y < 0)
        return atan(y / x) - PI;
    else if (x == 0 && y > 0)
        return HALFPI;
    else if (x == 0 && y < 0)
        return -HALFPI;
    else
        return 0; // Undefined
}

version(FreeStanding)
{
    version = UseFreeStandingMath;
}

version(LDC)
{
    import ldc.intrinsics;
    
    alias ceil = llvm_ceil;
    alias floor = llvm_floor;
    alias sqrt = llvm_sqrt;
    alias sin = llvm_sin;
    alias cos = llvm_cos;
    alias tan = tanFallback;
    
    version(UseFreeStandingMath)
    {
        alias cbrt = cbrtFallback;
        alias asin = asinFallback;
        alias acos = acosFallback;
        alias atan = atanFallback;
        alias atan2 = atan2Fallback;
    }
    else version(NoPhobos)
    {
        extern(C) nothrow @nogc
        {
            double cbrt(double x);
            double asin(double x);
            double acos(double x);
            double atan(double x);
            double atan2(double y, double x);
        }
    }
    else
    {
        import std.math;
        
        alias cbrt = std.math.cbrt;
        alias asin = std.math.asin;
        alias acos = std.math.acos;
        alias atan = std.math.atan;
        alias atan2 = std.math.atan2;
    }
}
else
version(UseFreeStandingMath)
{
    version(X86)
    {
        version = UseX87Math;
    }
    version(X86_64)
    {
        version = UseX87Math;
    }
    
    import dcore.math.trigtables;
    
    T trunc(T)(T x) pure nothrow @nogc
    {
        pragma(inline, true);
        long intPart = cast(long)x;
        return (x < 0 && x != cast(T)intPart) ? intPart - 1 : intPart;
    }
    
    alias floor = trunc;
    
    T ceil(T)(T x) pure nothrow @nogc
    {
        pragma(inline, true);
        long intPart = cast(long)x;
        T xtrunc = (x < 0 && x != cast(T)intPart) ? intPart - 1 : intPart;
        return (xtrunc < x)? xtrunc + 1 : x;
    }
    
    T fmod(T)(T x, T y) pure nothrow @nogc
    {
        pragma(inline, true);
        auto m = trunc(x / y);
        return max(0, x - y * m);
    }
    
    alias sqrt = sqrtFallback;
    alias cbrt = cbrtFallback;
    
    T sin(T)(T x) pure nothrow @nogc
    {
        pragma(inline, true);
        
        T xfmod = x - trunc(x * INVTWOPI) * TWOPI;
        x = (0 > xfmod)? 0 : xfmod;
        
        T rsign = 1.0;
        T adjusted_x = x;
        if (x < 0) 
        {
            adjusted_x = -x;
            rsign = -1.0;
        }
        if (adjusted_x > PI) 
        {
            adjusted_x = min(PI, TWOPI - adjusted_x);
            rsign = -1.0;
        }
        
        T j = adjusted_x * (cast(T)(sinTable.length - 2) * INVPI);
        int zero = cast(int)j;
        T nx = j - zero;
        return ((1.0 - nx) * sinTable[zero][0] + nx * sinTable[zero + 1][0]) * rsign;
    }
    
    T cos(T)(T x) pure nothrow @nogc
    {
        pragma(inline, true);
        
        T xfmod = x - trunc(x * INVTWOPI) * TWOPI;
        x = (0 > xfmod)? 0 : xfmod;
        
        T adjusted_x = x;
        if (x < 0) 
        {
            adjusted_x = -x;
        }
        if (adjusted_x > PI) 
        {
            adjusted_x = min(PI, TWOPI - adjusted_x);
        }
        
        T j = adjusted_x * (cast(T)(cosTable.length - 2) * INVPI);
        int zero = cast(int)j;
        T nx = j - zero;
        return (1.0 - nx) * cosTable[zero][0] + nx * cosTable[zero + 1][0];
    }
    
    alias tan = tanFallback;
    alias asin = asinFallback;
    alias acos = acosFallback;
    alias atan = atanFallback;
    alias atan2 = atan2Fallback;
}
else version(NoPhobos)
{
    extern(C) nothrow @nogc
    {
        double ceil(double x);
        double floor(double x);
        double sqrt(double x);
        double cbrt(double x);
        double sin(double x);
        double cos(double x);
        double tan(double x);
        double asin(double x);
        double acos(double x);
        double atan(double x);
        double atan2(double y, double x);
    }
}
else
{
    import std.math;
    
    alias ceil = std.math.ceil;
    alias floor = std.math.floor;
    alias sqrt = std.math.sqrt;
    alias cbrt = std.math.cbrt;
    alias sin = std.math.sin;
    alias cos = std.math.cos;
    alias tan = std.math.tan;
    alias asin = std.math.asin;
    alias acos = std.math.acos;
    alias atan = std.math.atan;
    alias atan2 = std.math.atan2;
}

T cot(T)(T x) pure nothrow @nogc
{
    pragma(inline, true);
    return cos(x) / sin(x);
}
