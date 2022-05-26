module main;
import dcore;

extern(C) void main() nothrow @nogc
{
    printStr("Hello!");
    
    SysInfo info;
    if (sysInfo(&info))
    {
        printf("Architecture: %d\n", info.architecture);
        printf("Processors: %d\n", info.numProcessors);
    }

    Array!int arr;
    arr ~= 10;
    printf("arr.length = %d\n".ptr, arr.length);
    arr.free();
    
    float x = cos(PI * 0.5f);
    printf("x = %f\n".ptr, x);
}
