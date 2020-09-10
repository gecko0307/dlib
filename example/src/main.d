module main;
import dcore;

extern(C) void main()
{
    int[] arr = New!(int[])(100);
	printf("%d\n", arr.length);
    Delete(arr);
}
