module main;

import std.math;
import dcore.math.base;
import tests.math;

void main() {
    testPrecision!(dcore.math.base.atan, std.math.atan, -std.math.PI, std.math.PI, double)();
    testPerformance!(dcore.math.base.atan, std.math.atan, -std.math.PI, std.math.PI, double)();
}
