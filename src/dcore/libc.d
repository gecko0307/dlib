module dcore.libc;

version(WebAssembly)
{
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
