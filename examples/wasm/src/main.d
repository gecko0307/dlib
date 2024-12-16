module main;

import dcore.stdlib;

extern(C):

void jsPrintString(uint str, uint len) nothrow @nogc;
uint jsMalloc(uint) nothrow @nogc;
void jsFree(uint) nothrow @nogc;

void* customMalloc(size_t size) nothrow @nogc
{
    return cast(void*)jsMalloc(size);
}

void customFree(void* mem) nothrow @nogc
{
    jsFree(cast(uint)mem);
}

double testFunc()
{
    string str = "Hello from D! Привет из D!";
    jsPrintString(cast(uint)str.ptr, str.length);
    return 0.0;
}

void _start() {
    mallocCallback = &customMalloc;
    freeCallback = &customFree;
}
