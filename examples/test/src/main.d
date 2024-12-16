module main;

import std.math;
import dcore.math.base;
import tests.math;

void main() {
    testPrecision!(dcore.math.base.sqrt, std.math.sqrt, 0.0, 64.0, double)();
    testPerformance!(dcore.math.base.sqrt, std.math.sqrt, 0.0, 64.0, double)();
}
