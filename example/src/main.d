module main;
import dcore;
import std.conv;

extern(C) void main() nothrow @nogc
{
    printStr("Hello!");
    
    string[13] archNames = [
        "Unknown",
        "x86",
        "x64",
        "ARM",
        "ARM64",
        "IA64",
        "MIPS32",
        "MIPS64",
        "SPARC7",
        "SPARC8",
        "SPARC9",
        "PPC32",
        "PPC64"
    ];
    
    SysInfo info;
    if (sysInfo(&info))
    {
        printf("Architecture: %s\n", archNames[info.architecture].ptr);
        printf("Processors: %d\n", info.numProcessors);
        printf("Total memory: %lu MB\n", info.totalMemory / (1024 * 1024));
        printf("OS: %s %d.%d\n", info.os.ptr, info.osVersionMajor, info.osVersionMinor);
    }

    Array!int arr;
    arr ~= 10;
    printf("arr.length = %d\n".ptr, arr.length);
    arr.free();
    
    float x = cos(PI * 0.5f);
    printf("x = %f\n".ptr, x);
}
