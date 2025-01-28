module tests.random;

import std.stdio;
import dcore;

void testRandom()
{
    writefln("Random number: %s", random!float());
}
