module dcore.memory;

import std.traits;

version(WebAssembly)
{
    extern(C) pure nothrow @nogc
    {
        uint malloc(uint size);
        void free(uint mem);
    }
}
else
{
    version(FreeStanding)
    {
        static assert(0, "dcore.memory requires libc for this target");
    }
    else
    {
        import dcore.libc;
    }
}

void* memset(void* ptr, int value, uint num)
{
    for (uint i = 0; i < num; i++)
    {
        (cast(ubyte*)ptr)[i] = cast(ubyte)value;
    }

    return ptr;
}

enum psize = 8;
__gshared ulong _allocatedMemory = 0;

T allocate(T, A...) (A args) if (is(T == class))
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

T* allocate(T, A...) (A args) if (is(T == struct))
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

T allocate(T) (size_t length) if (isArray!T)
{
    alias AT = ForeachType!T;
    size_t size = length * AT.sizeof;
    void* p = cast(void*)malloc(size);
    T arr = cast(T)p[0..size];
    foreach(ref v; arr)
        v = v.init;
    return arr;
}

void deallocate(T)(ref T obj) if (isArray!T)
{
    void* p = cast(void*)obj.ptr;
    free(cast(uint)p);
}

void deallocate(T)(T obj) if (is(T == class) || is(T == interface))
{
    Object o = cast(Object)obj;
    void* p = cast(void*)o;
    free(cast(uint)p);
}

void deallocate(T)(T* obj)
{
    void* p = cast(void*)obj;
    free(cast(uint)p);
}

alias New = allocate;
alias Delete = deallocate;

unittest
{
    int[] arr = New!(int[])(100);
    assert(arr.length == 100);
}
