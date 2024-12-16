module dcore.stdarg;

version(LDC)
{
    alias void* va_list;
    pragma(LDC_va_start) void va_start(T)(va_list ap, ref T) nothrow @nogc;
    pragma(LDC_va_arg) T va_arg(T)(va_list ap) nothrow @nogc;
    pragma(LDC_va_end) void va_end(va_list args) nothrow @nogc;
    pragma(LDC_va_copy) void va_copy(va_list dst, va_list src) nothrow @nogc;
}
else
{
    public import core.stdc.stdarg;
}
