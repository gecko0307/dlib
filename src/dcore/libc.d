module dcore.libc;

version(WebAssembly)
{
    extern(C) nothrow @nogc
    {
        uint malloc(uint size);
        void free(uint mem);

        void consoleLog(const char* str);

        int printf(const char* fmt, ...)
        {
            consoleLog(fmt);
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
