module tests.time;

import std.stdio;
import dcore;

void testTime()
{
    string[12] monthNames = [
        "January", "February", "March",
        "April", "May", "June", "July",
        "August", "September", "October",
        "November", "December"
    ];
    string[7] weekDays = [
        "Sunday", "Monday", "Tuesday",
        "Wednesday", "Thursday", "Friday", "Saturday"
    ];
    
    auto localDateTime = currentTimeLocal();
    auto utcDateTime = currentTimeUTC();
    
    int year = localDateTime.year;
    string month = monthNames[localDateTime.month];
    int day = localDateTime.day;
    string weekDay = weekDays[localDateTime.dayInWeek];
    int hour = localDateTime.hours;
    int minute = localDateTime.minutes;
    int second = localDateTime.seconds;
    
    int utcYear = utcDateTime.year;
    string utcMonth = monthNames[utcDateTime.month];
    int utcDay = utcDateTime.day;
    string utcWeekDay = weekDays[utcDateTime.dayInWeek];
    int utcHour = utcDateTime.hours;
    int utcMinute = utcDateTime.minutes;
    int utcSecond = utcDateTime.seconds;
    
    writefln("Local date/time: %s, %s %s, %s, %s:%s:%s", weekDay, day, month, year, hour, minute, second);
    writefln("UTC+0 date/time: %s, %s %s, %s, %s:%s:%s", utcWeekDay, utcDay, utcMonth, utcYear, utcHour, utcMinute, utcSecond);
}
