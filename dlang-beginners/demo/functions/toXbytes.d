/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 
 toXbytes displays a string as Kb, Mb, Tb, or Pb
 
	1: 1,024.00 = 1.02 Kb
	2: 1,024,000.00 = 1.02 Mb
	3: 1,024,000,000.00 = 1.02 Gb
	4: 1,024,000,000,000.00 = 1.02 Tb
	5: 1,024,000,000,000,000.00 = 1.02 Pb
 
*/

module dlang.functions.toXbytes;

import std.stdio;
import std.string;

void main() {

	int count = 1;
	
	double f = 1_024;

	write("1: ", toCommas(format("%.2f", f)), " = ", toXbytes(f) , "\n");
	
	f = f * 1_000;
	write("2: ", toCommas(format("%.2f", f)), " = ", toXbytes(f) , "\n");

	f = f * 1_000;
	write("3: ", toCommas(format("%.2f", f)), " = ", toXbytes(f) , "\n");

	f = f * 1_000;
	write("4: ", toCommas(format("%.2f", f)), " = ", toXbytes(f) , "\n");

	f = f * 1_000;
	write("5: ", toCommas(format("%.2f", f)), " = ", toXbytes(f) , "\n");

}

string toXbytes(double bytes) {
	
	enum ulong Kb = 1_000;
	enum ulong Mb = Kb * Kb;
	enum ulong Gb = Mb * Kb;
	enum ulong Tb = Gb * Kb;
	enum ulong Pb = Tb * Kb;
	
//	write("Kb=", toCommas( format("%s",Kb) ), "\n" );
//	write("Mb=", toCommas( format("%s",Mb) ), "\n" );
//	write("Gb=", toCommas( format("%s",Gb) ), "\n" );
//	write("Tb=", toCommas( format("%s",Tb) ), "\n" );
//	write("Pb=", toCommas( format("%s",Pb) ), "\n\n" );
	
	float f;
	string xB;
		
	if (bytes > Pb) {
		xB = " Pb"; f = bytes / Pb;
	} else if (bytes > Tb) {
		xB = " Tb"; f = bytes / Tb;
	} else if (bytes > Gb) {
		xB = " Gb"; f = bytes / Gb;
	} else if (bytes > Mb) {
		xB = " Mb"; f = bytes / Mb;
	} else if (bytes > Kb) {
		xB = " Kb"; f = bytes / Kb;
	} else {
		xB = " bytes"; f = bytes;
	}
	return format("%.2f" ~ xB, f);
}

string toCommas(string number) {

	int start;
	int end;
	int dot;
	int count;
	
	string buff;
	string result;
	
	//example: number = 1234.5678
	
	//if decimal point, get the fractional part in reverse order = 8765.
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
