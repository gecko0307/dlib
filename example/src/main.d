module main;

import std.math;
import dcore.math.base;
import tests.math;

void main() {
    testPrecision!(dcore.math.base.ceil, std.math.ceil, -64.0f, 64.0f, double)();
    testPerformance!(dcore.math.base.ceil, std.math.ceil, -64.0f, 64.0f, double)();
}
