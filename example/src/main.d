module main;
import dcore;

extern(C) void main() nothrow @nogc
{
    printStr("Hello!");

    Array!int arr;
    arr ~= 10;
    printf("arr.length = %d\n", arr.length);
    arr.free();

    float x = cos(PI * 0.5f);
    printf("x = %f\n".ptr, x);
}
