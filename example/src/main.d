module main;

/*
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
    
    //float x = cos(PI * 0.5f);
    printf("x = %f\n".ptr, cos(PI * 0.5f));
    printf("x = %f\n".ptr, cos(PI));
}
*/

import std.stdio;
import std.math;
import std.algorithm;
import std.range;
import std.format;

import dcore.math.base;
alias mySin = dcore.math.base.sin;
alias myCos = dcore.math.base.cos;
alias refSin = std.math.sin;
alias refCos = std.math.cos;

void testTrigPrecision()
{
    auto testRange = iota(-100, 101)
        .map!(x => x * 0.01f * std.math.PI)
        .array;

    double maxErrorSin = 0.0;
    double maxErrorCos = 0.0;

    foreach (x; testRange)
    {
        double standardSin = refSin(x);
        double standardCos = refCos(x);

        double mySinValue = mySin(x);
        double myCosValue = myCos(x);

        double errorSin = std.math.abs(standardSin - mySinValue);
        double errorCos = std.math.abs(standardCos - myCosValue);

        maxErrorSin = std.algorithm.max(maxErrorSin, errorSin);
        maxErrorCos = std.algorithm.max(maxErrorCos, errorCos);

        writeln(format("x = %.2f PI | sin: %.6f (std) vs %.6f (custom) | cos: %.6f (std) vs %.6f (custom)",
            x / std.math.PI, standardSin, mySinValue, standardCos, myCosValue));
    }

    writeln();
    writeln("Max error:");
    writeln("sin: ", maxErrorSin);
    writeln("cos: ", maxErrorCos);
}

import std.datetime.stopwatch;

void testTrigPerformance()
{
    const int iterations = 1000000;
    auto sw = StopWatch(AutoStart.no);

    sw.start();
    // std.math sin/cos
    foreach (i; 0..iterations)
    {
        auto x = i * 0.00001 * std.math.PI;
        cast(void)refSin(x);
        cast(void)refCos(x);
    }
    sw.stop();
    writeln("std.math: ", sw.peek.total!"msecs", " ms");

    sw.reset();
    
    sw.start();
    // dcore.math.base sin/cos
    foreach (i; 0..iterations)
    {
        auto x = i * 0.00001 * std.math.PI;
        cast(void)mySin(x);
        cast(void)myCos(x);
    }
    sw.stop();
    writeln("dcore.math.base: ", sw.peek.total!"msecs", " ms");
}

void main() {
    writeln("Precision test:");
    testTrigPrecision();
    
    writeln("\nPerformance test:");
    testTrigPerformance();
}