module tests.random;

import std.stdio;
import dcore;

void testRandom()
{
    setSeed();
    writefln("Random number: %s", random!float());
}
