module main;

import std.math;
import dcore.math.base;
import tests.math;

void main() {
    testPrecision!(dcore.math.base.acos, std.math.acos, 0.0, 1.0, double)();
    testPerformance!(dcore.math.base.acos, std.math.acos, 0.0, 1.0, double)();
}
