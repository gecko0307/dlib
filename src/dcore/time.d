/*
Copyright (c) 2025 Timur Gafarov

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/
module dcore.time;

struct DateTime
{
    int seconds;
    int minutes;
    int hours;
    int day;
    int month;
    int year;
    int dayInWeek;
    int dayInYear;
}

version(WebAssembly)
{
    // Not implemented
}
else version(FreeStanding)
{
    // Not implemented
}
else
{
    import dcore.mutex;
    
    private __gshared Mutex mutex;
    
    void init() nothrow @nogc
    {
        mutex.init();
    }
    
    version(X86_64)
    {
        alias time_t = long;
    }
    else version(X86)
    {
        alias time_t = int;
    }
    
    alias clock_t = int;
    
    struct tm
    {
        int tm_sec;   // seconds, range 0 to 59
        int tm_min;   // minutes, range 0 to 59
        int tm_hour;  // hours, range 0 to 23
        int tm_mday;  // day of the month, range 1 to 31
        int tm_mon;   // month, range 0 to 11
        int tm_year;  // The number of years since 1900
        int tm_wday;  // day of the week, range 0 to 6
        int tm_yday;  // day in the year, range 0 to 365
        int tm_isdst; // daylight saving time
    }
    
    extern(C) nothrow @nogc
    {
        time_t time(time_t* arg);
        clock_t clock();
        
        tm* gmtime(const(time_t)* t);
        tm* localtime(const(time_t)* t);
        
        version(Posix)
        {
            tm* gmtime_s(const(time_t)* t, tm* buf);
            tm* localtime_s(const(time_t)* t, tm* buf);
        }
        
        version(Windows)
        {
            tm* gmtime_s(const(time_t)* t, tm* buf)
            {
                mutex.lock();
                *buf = *gmtime(t);
                mutex.unlock();
                return buf;
            }
            
            tm* localtime_s(const(time_t)* t, tm* buf)
            {
                mutex.lock();
                *buf = *localtime(t);
                mutex.unlock();
                return buf;
            }
        }
    }
    
    DateTime dateTimeFromTm(tm* timeInfo) pure nothrow @nogc
    {
        if (timeInfo is null)
            return DateTime();
        
        DateTime dateTime = {
            seconds: timeInfo.tm_sec,
            minutes: timeInfo.tm_min,
            hours: timeInfo.tm_hour,
            day: timeInfo.tm_mday,
            month: timeInfo.tm_mon,
            year: 1900 + timeInfo.tm_year,
            dayInWeek: timeInfo.tm_wday,
            dayInYear: timeInfo.tm_yday
        };
        
        return dateTime;
    }
    
    DateTime currentTimeLocal() nothrow @nogc
    {
        time_t t = time(null);
        tm timeInfo;
        localtime_s(&t, &timeInfo);
        return dateTimeFromTm(&timeInfo);
    }
    
    DateTime currentTimeUTC() nothrow @nogc
    {
        time_t t = time(null);
        tm timeInfo;
        gmtime_s(&t, &timeInfo);
        return dateTimeFromTm(&timeInfo);
    }
}
