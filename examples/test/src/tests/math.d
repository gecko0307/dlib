module tests.math;

import std.stdio;
import std.math;
import std.algorithm;
import std.range;
import std.datetime.stopwatch;

void testPrecision(alias f, alias f_ref, alias mi, alias ma, T)()
{
    auto testRange = iota(0, 101)
        .map!(x => cast(T)mi + x * cast(T)0.01 * ma)
        .array;

    double maxError = 0.0;

    foreach (x; testRange)
    {
        double testResult = f(x);
        double refResult = f_ref(x);

        double err = abs(refResult - testResult);

        maxError = max(maxError, err);

        writefln("x = %.2f | f(x): %.6f | f_ref(x): %.6f", x, testResult, refResult);
    }

    writeln();
    writeln("Max error: ", maxError);
}

void testPrecision2(alias f, alias f_ref, alias a, alias b, T)()
{
    double testResult = f(a, b);
    double refResult = f_ref(a, b);
    double err = abs(refResult - testResult);
    
    writefln("a = %.2f, b = %.2f | f(a, b): %.6f | f_ref(a, b): %.6f", a, b, testResult, refResult);
    writeln();
    writeln("Error: ", err);
}

void testPerformance(alias f, alias f_ref, alias mi, alias ma, T)()
{
    const int iterations = 1000000;
    auto sw = StopWatch(AutoStart.no);

    sw.start();
    foreach (i; 0..iterations)
    {
        auto x = cast(T)mi + cast(T)i * cast(T)0.00001 * ma;
        cast(void)f_ref(x);
    }
    sw.stop();
    writeln("f_ref: ", sw.peek.total!"msecs", " ms");

    sw.reset();
    
    sw.start();
    foreach (i; 0..iterations)
    {
        auto x = cast(T)mi + cast(T)i * cast(T)0.00001 * ma;
        cast(void)f(x);
    }
    sw.stop();
    writeln("f: ", sw.peek.total!"msecs", " ms");
}

void testPerformance2(alias f, alias f_ref, alias a, alias b, T)()
{
    const int iterations = 1000000;
    auto sw = StopWatch(AutoStart.no);

    sw.start();
    foreach (i; 0..iterations)
    {
        cast(void)f_ref(a, b);
    }
    sw.stop();
    writeln("f_ref: ", sw.peek.total!"msecs", " ms");

    sw.reset();
    
    sw.start();
    foreach (i; 0..iterations)
    {
        cast(void)f(a, b);
    }
    sw.stop();
    writeln("f: ", sw.peek.total!"msecs", " ms");
}