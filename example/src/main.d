module main;

import std.math;
import dcore.math.base;
import tests.math;

void main() {
    testPrecision!(dcore.math.base.round, std.math.round, 0.0, 99.0, double)();
    testPerformance!(dcore.math.base.round, std.math.round, 0.0, 99.0, double)();
}
