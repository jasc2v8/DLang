/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 
 StopWatch is a demo of std.datetime : StopWatch
 
*/

module dlang.functions.stopwatch;

import std.stdio;
import std.conv;
import core.time;
import core.thread;
import std.datetime : StopWatch;

void main() {
	
	StopWatch sw;

	sw.start();
	
	foreach (i; 0..5) {
   		writeln("Elapsed: " ~ getPeek(sw));
		stdout.flush();
		Thread.sleep( dur!("seconds")( 1 ) );
	}
	
   	sw.stop();
	                    	
	writeln("Duration: " ~ getPeek(sw));
	
}

string getPeek(StopWatch sw) {

	int minutes;
	int seconds;
    short msecs;
    string peek;

	Duration dur = to!Duration(sw.peek());
	    
    dur.split!("minutes", "seconds", "msecs")(minutes, seconds, msecs);

	if (minutes == 1) {
		peek = to!string(minutes) ~ " minute, " ~ to!string(seconds) ~ " seconds";
	} else if (minutes > 0) {
		peek = to!string(minutes) ~ " minutes, " ~ to!string(seconds) ~ " seconds";
	} else if (seconds == 1) {
		peek = to!string(seconds) ~ " second";		
	} else if (seconds > 0) {
		peek = to!string(seconds) ~ " seconds";		
	} else {
		peek = "less than 1 second";				
	}
	
	return peek;
}
