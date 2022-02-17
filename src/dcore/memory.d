module dcore.memory;

import std.traits;
import dcore.libc;

T allocate(T, A...) (A args) nothrow @nogc if (is(T == class))
{
    enum size = __traits(classInstanceSize, T);
    void* p = cast(void*)malloc(size);
    T c = cast(T)p;
    static if (is(typeof(c.__ctor(args))))
    {
        c.__ctor(args);
    }
    return c;
}

T* allocate(T, A...) (A args) nothrow @nogc if (is(T == struct))
{
    enum size = T.sizeof;
    void* p = cast(void*)malloc(size);
    T* c = cast(T*)p;
    static if (is(typeof(c.__ctor(args))))
    {
        c.__ctor(args);
    }
    return c;
}

T allocate(T) (size_t length) nothrow @nogc if (isArray!T)
{
    alias AT = ForeachType!T;
    size_t size = length * AT.sizeof;
    void* p = cast(void*)malloc(size);
    T arr = cast(T)p[0..size];
    foreach(ref v; arr)
        v = v.init;
    return arr;
}

void deallocate(T)(ref T obj) nothrow @nogc if (isArray!T)
{
    void* p = cast(void*)obj.ptr;
    version(WebAssembly)
        free(cast(uint)p);
    else
        free(p);
    obj.length = 0;
}

void deallocate(T)(T obj) nothrow @nogc if (is(T == class) || is(T == interface))
{
    Object o = cast(Object)obj;
    void* p = cast(void*)o;
    version(WebAssembly)
        free(cast(uint)p);
    else
        free(p);
}

void deallocate(T)(T* obj) nothrow @nogc
{
    void* p = cast(void*)obj;
    version(WebAssembly)
        free(cast(uint)p);
    else
        free(p);
}

alias New = allocate;
alias Delete = deallocate;

unittest
{
    int[] arr = New!(int[])(100);
    assert(arr.length == 100);
    Delete(arr);
    assert(arr.length == 0);
}
