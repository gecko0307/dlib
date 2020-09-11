module dcore.libc;

version(FreeStanding)
{
    static assert(0, "dcore requires libc for this platform");
}

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
