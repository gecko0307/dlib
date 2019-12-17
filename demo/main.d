module main;

import std.traits;
import dcore;

version(WebAssembly)
{
    extern(C) void _start() {}
}

extern(C) void main()
{
    float x = cos(PI * 0.5f);
    printf("x = %f\n".ptr, x);
}
