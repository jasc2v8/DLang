/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 
 datetime is a demo of std.datetime
 
*/

module dlang.functions.datetime;

import std.stdio;
import std.conv;
import core.time;
import core.thread;
import std.datetime;
import std.string;
//import std.format;

void main() {
	
	auto currentTime = Clock.currTime();
	auto timeString = currentTime.toISOExtString();
	auto restoredTime = SysTime.fromISOExtString(timeString);
	
	writeln("currentTime: " ~ to!string( currentTime ) );
	writeln("timeString: " ~ timeString);
	writeln("restoredTime: " ~ to!string( restoredTime ) );

	writeln("DateTimeString: " ~  getDateTimeString() );

	DateTime dateTime = cast(DateTime)Clock.currTime();
	writeln(dateTime.year());
	writeln(dateTime.month());
	writeln(dateTime.day());
	writeln(dateTime.dayOfWeek());
	
	string currentDate =
		to!string( format( "%02s", dateTime.day()) ) ~ "-" ~
		to!string(dateTime.month()) ~ "-" ~
		to!string(dateTime.year());

	writeln("currentDate=" ~ currentDate);
	
	writeln(dateTime.isoWeek());
	
	writeln(dateTime.toISOString());
	writeln(dateTime.toISOExtString());
	writeln(dateTime.toSimpleString());
	writeln(dateTime.toString());
	writeln(dateTime.toSimpleString());
	
	


	}

	auto getDateTimeString() {
		import std.string;
		import std.datetime;
		
		DateTime dateTime = cast(DateTime)Clock.currTime();
		with(dateTime)
		{
			return format(
				"%s " ~ // day of the week (eg. 'Saturday')
				"%02s.%02s.%s " ~// date, month, year
				"[%s:%02s:%02s%s]", // hour:minute:second am/pm
				split("Sunday Monday Tuesday Wednesday Thursday Friday Saturday")[dayOfWeek],
				day, cast(int)month, year,
				hour == 0 || hour == 12 ? 12 : hour % 12, minute, second, hour <= 11 ? "am" : "pm");
		}
	
	
}
