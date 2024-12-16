module tests.trig;

import std.stdio;
import std.math;
import std.algorithm;
import std.range;
import std.format;
import std.datetime.stopwatch;

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
