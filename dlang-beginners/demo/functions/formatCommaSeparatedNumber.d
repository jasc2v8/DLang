/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 
 formatCommaSeparatedNumber returns a string formatted with commas
 
		int  1: 1,024
		int  2: 1,024,000
		int  3: 1,024,000.00
		long  : 1,024,000,000
		float : 1,024,000,000,000.00
		double: 1,024,000,000,000,000.00
		string: 1,024,000
		string:         1,024,000,000

*/

module dlang.functions.formatCommaSeparatedNumber;

import std.stdio;
import std.string;

//long descriptive name for self-documenting and uniqueness
//use an alias for convenience
alias formatCommaSeparatedNumber csn;
//alias formatCommaSeparatedNumber fmtN;
//alias formatCommaSeparatedNumber formatN;

void main() {

	int i = 1024;
	write( "int  1: ", csn("%d", i), "\n" );
	//writeln( fmtN("%d", i) );
	//writeln( formatN("%d", i) );

	i = 1024*1000;
	write( "int  2: ", csn( "" , i), "\n" );
	
	i = 1024*1000;
	write( "int  3: ", csn( "" , i) ~ ".00", "\n" );
	
	long l = i * 1000;
	write( "long  : ", csn("%d", l), "\n" );

	float f = l  * 1000;
	write( "float : ", csn("%.2f", f), "\n" );

	double d = f * 1000;
	write( "double: ", csn("%.2f", d), "\n" );

	string s = "1024000";
	write( "string: ", csn(s), "\n" );

	s = "1024000000";
	write( "string: ", csn( format("%18s", s) ), "\n" );

}

string formatCommaSeparatedNumber(string fspec, int number) {
	if (fspec == "") fspec = "%d";
	return formatCommaSeparatedNumber(format(fspec, number));
}

string formatCommaSeparatedNumber(string fspec, long number) {
	if (fspec == "") fspec = "%d";
	return formatCommaSeparatedNumber(format(fspec, number));
}

string formatCommaSeparatedNumber(string fspec, float number) {
	if (fspec == "") fspec = "%.2f";
	return formatCommaSeparatedNumber(format(fspec, number));
}

string formatCommaSeparatedNumber(string fspec, double number) {
	if (fspec == "") fspec = "%.2fd";
	return formatCommaSeparatedNumber(format(fspec, number));
}

string formatCommaSeparatedNumber(string number) {

	int start, end, dot, count;
	
	string buff, result;
	
	//example: number = 1234.5678
	
	//if decimal point, get the fractional part
	dot = lastIndexOf(number, ".");

	if (dot != -1) {

		//if a dot with no zeros, right pad zeros
		if (dot+1 > number.length) {
			number ~= "00";
		}
		
		//get the fractional part in reverse order = 8765.
		start = dot;
		end = number.length;
		foreach_reverse (item; start..end)
			buff ~= number[item..item+1];
	} else {
		dot = number.length;
	}
	
	//get the integer part and add commas in reverse order = 8765.432,1
	start = 0;
	end = dot;
	count = 0;
	foreach_reverse (item; start..end) {
		buff ~= number[item..item+1];
		count++;
		if ( count > 2 && item > 0 && number[item..item+1] != " " ) {
			buff ~= ",";
			count = 0;
		}
	}
	
	//now reverse the buffer from 8765.432,1 to 1,234.5678
	start = 0;
	end = buff.length;
	foreach_reverse (item; start..end)
		result ~= buff[item..item+1];
		
	//return result
	return result;
	
}
