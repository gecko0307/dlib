module main;
import dcore;

version(WebAssembly)
{
    extern(C) void _start() {}
    
    extern(C) int test()
    {
        return 1000;
    }
}
else
{
    extern(C) void main()
    {
        int[] arr = New!(int[])(100);
        printf("arr.length = %d\n", arr.length);
        Delete(arr);
        
        float x = cos(PI * 0.5f);
        printf("x = %f\n".ptr, x);
    }
}