module main;

import dcore.stdio;

extern(C):

void main()
{
    // Minimal cross-platform betterC application.
    // Will print to stdout on desktop and to the console in browser.
    
    printf("Hello from D! Привет из D!\n");
}
