module main;

import std.math;
import dcore.math.base;
import tests.math;

void main() {
    testPrecision!(dcore.math.base.tan, std.math.tan, -std.math.PI, std.math.PI, float)();
    testPerformance!(dcore.math.base.tan, std.math.tan, -std.math.PI, std.math.PI, float)();
}
