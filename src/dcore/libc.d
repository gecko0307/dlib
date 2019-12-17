module dcore.libc;

version(WebAssembly)
{
    extern(C) nothrow @nogc
    {
        uint malloc(uint size);
        void free(uint mem);

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

        public import dcore.math._trig;
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
            void* malloc(size_t size);
            void free(void* mem);

            int putchar(int c);
            int puts(const char* s);
            int printf(const char* fmt, ...);

            double sin(double x);
            double cos(double x);
        }
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
