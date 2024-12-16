module main;

import std.math;
import dcore.math.base;
import tests.math;

void main() {
    testPrecision2!(dcore.math.base.atan2, std.math.atan2, 1.0f, 1.0f, double)();
    testPerformance2!(dcore.math.base.atan2, std.math.atan2, 1.0f, 1.0f, double)();
}
