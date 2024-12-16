module main;

import dcore.stdlib;
import dcore.stdio;

extern(C):

void main()
{
    string s = "Привет из D!";
    printf("Hello from D! %s Test\n", s.ptr);
}
