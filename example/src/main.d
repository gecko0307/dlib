module main;

import std.math;
import dcore.math.base;
import tests.math;

void main() {
    testPrecision!(dcore.math.base.cbrt, std.math.cbrt, 0.0, 8.0, double)();
    testPerformance!(dcore.math.base.cbrt, std.math.cbrt, 0.0, 8.0, double)();
}
