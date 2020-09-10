module dcore.libc;

version(WebAssembly)
{
    alias StdPtr = uint;
    alias StdSize = uint;
}
else
{
    alias StdPtr = void*;
    alias StdSize = size_t;
}

extern(C) nothrow @nogc
{
    StdPtr malloc(StdSize size);
    void free(StdPtr mem);
}

version(WebAssembly)
{
    extern(C) nothrow @nogc
    {
        // Fallbacks for C stdio
        
        int putchar(int c)
        {
            return 0;
        }

        int puts(const char* s)
        {
            return 0;
        }

        int printf(const char* fmt, ...)
        {
            return 0;
        }
    }
}
else
{
    version(FreeStanding)
    {
        static assert(0, "dcore requires libc for this platform");
    }
    else
    {
        extern(C) nothrow @nogc
        {
            int putchar(int c);
            int puts(const char* s);
            int printf(const char* fmt, ...);
            
            double sin(double x);
            double cos(double x);
        }
    }
}

void* memset(void* ptr, int value, size_t num) pure nothrow @nogc
{
    for (size_t i = 0; i < num; i++)
    {
        (cast(ubyte*)ptr)[i] = cast(ubyte)value;
    }

    return ptr;
}
