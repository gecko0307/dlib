module tests.sys;

import std.stdio;
import dcore;

void testSysInfo()
{
    SysInfo info;
    if (sysInfo(&info))
    {
        writefln("Architecture: %s", info.architecture);
        writefln("Processors: %s", info.numProcessors);
        writefln("Total memory: %s MB", info.totalMemory / (1024 * 1024));
        writefln("OS: %s %s", info.osName, info.osVersion);
    }
}
