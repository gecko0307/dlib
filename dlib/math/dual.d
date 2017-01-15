/*
Copyright (c) 2013-2017 Timur Gafarov 

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

module dlib.math.dual;

private
{
    import std.math;
}

struct Dual(T)
{
    T re;
    T du;

    this(T r)
    {
        re = r;
        du = 0.0;
    }

    this(T r, T d)
    {
        re = r;
        du = d;
    }

    this(in int e)
    {
        re = cast(T)e;
        du = 0.0;
    }

    static Dual!(T) opCast(in T x)
    {
        return Dual!(T)(x, 0.0);
    }
    
    Dual!(T) opAssign(in T x)
    {
        re = x;
        du = 0.0;
        return this;
    }
    
    Dual!(T) opAdd(in T x) const
    {
        return this + Dual!(T)(x);
    }
    
    Dual!(T) opSub(in T x) const
    {
        return this - Dual!(T)(x);
    }
    
    Dual!(T) opMul(in T x) const
    {
        return this * Dual!(T)(x);
    }
    
    Dual!(T) opDiv(in T x) const
    {
        return this / Dual!(T)(x);
    }
    
    Dual!(T) opUnary (string s)() const if (s == "-")
    {
        return Dual!(T)(-re, -du);
    }

    Dual!(T) opAdd(in Dual!(T) x) const
    {
        return Dual!(T)(
            re + x.re,
            du + x.du
        );
    }

    Dual!(T) opSub(in Dual!(T) x) const
    {
        return Dual!(T)(
            re - x.re,
            du - x.du
        );
    }

    Dual!(T) opMul(in Dual!(T) x) const
    {
        return Dual!(T)(
            re * x.re,
            re * x.du + du * x.re
        );
    }

    Dual!(T) opDiv(in Dual!(T) x) const
    {
        return Dual!(T)(
            re / x.re,
            (re * x.du - du * x.re) / (x.re * x.re)
        );
    }

    Dual!(T) opAddAssign(in Dual!(T) x)
    {
        re += x.re;
        du += x.du;
        return this;
    }

    Dual!(T) opSubAssign(in Dual!(T) x)
    {
        re -= x.re;
        du -= x.du;
        return this;
    }

    Dual!(T) opMulAssign(in Dual!(T) x)
    {
        re *= x.re,
        du = re * x.du + du * x.re;
        return this;
    }

    Dual!(T) opDivAssign(in Dual!(T) x)
    {
        re /= x.re,
        du = (re * x.du - du * x.re) / (x.re * x.re);
        return this;
    }

    Dual!(T) sqrt() const
    {
        T tmp = std.math.sqrt(re);
        return Dual!(T)(
            tmp,
            du / (2.0 * tmp)
        );
    }

    Dual!(T) opBinaryRight(string op)(in T v) const if (op == "+")
    {
        return Dual!(T)(v) + this;
    }

    Dual!(T) opBinaryRight(string op)(in T v) const if (op == "-")
    {
        return Dual!(T)(v) - this;
    }

    Dual!(T) opBinaryRight(string op)(in T v) const if (op == "*")
    {
        return Dual!(T)(v) * this;
    }
    
    Dual!(T) opBinaryRight(string op)(in T v) const if (op == "/")
    {
        return Dual!(T)(v) / this;
    }
    
    int opCmp(in double s) const
    {
        return cast(int)((re - s) * 100);
    }
    
    Dual!(T) sin() const
    {
        return Dual!(T)(.sin(re), du * .cos(re));
    }

    Dual!(T) cos() const
    {
        return Dual!(T)(.cos(re), -du * .sin(re));
    }

    Dual!(T) exp() const
    {
        return Dual!(T)(.exp(re), du * .exp(re));
    }

    Dual!(T) pow(T k) const
    {
        return Dual!(T)(re^^k, k * (re^^(k-1)) * du);
    }
}

alias Dual!(float) Dualf;
alias Dual!(double) Duald;
