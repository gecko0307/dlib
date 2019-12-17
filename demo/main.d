module main;

import dcore;

version(WebAssembly)
{
    extern(C) void _start() {}
}
else
{
    extern(C) int printf(const char * format, ...);
    
    extern(C) void main()
    {
        float x = cos(PI * 0.5f);
        printf("x = %f\n".ptr, x);
    }
}
