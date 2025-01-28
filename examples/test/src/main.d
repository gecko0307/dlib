module main;

import dcore;
import tests.sys;
import tests.process;
import tests.time;
import tests.random;

void main() {
    dcore.init();
    
    testSysInfo();
    testProcess();
    testTime();
    testRandom();
}
