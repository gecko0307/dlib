module main;

import std.math;
import dcore.math.base;
import tests.math;

void main() {
    testPrecision!(dcore.math.base.floor, std.math.floor, 0.0, -99.0, double)();
    testPerformance!(dcore.math.base.floor, std.math.floor, 0.0, -99.0, double)();
}
