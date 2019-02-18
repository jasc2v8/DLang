
module dlang.modules.enumdemo;

import std.stdio;
import std.getopt;
import std.typecons;

string data = "file.dat";
int length = 24;
bool verbose;
enum Color { no, yes };
Color color;

void main(string[] args)
{
	
	optionChar = '/';
	
	auto helpInformation = getopt(
		args,
	    "length",  "Info about length.", &length,    // numeric
		"file",    "Info about file.", &data,      // string
		"verbose", "Info about verbose.", &verbose,   // flag
		"color", "Information about this color.", &color);    // enum
	 
	if (helpInformation.helpWanted)
	{
		defaultGetoptPrinter("Some information about the program.",
	    helpInformation.options);
	}
	
	writeln("data  =", data);
	writeln("length=", length);

	writeln("Color= ", Color.no);
	writeln("Color= ", Color.yes);
	
	writeln("Color= ", cast (int) Color.no);
	writeln("Color= ", cast (int) Color.yes);
	
	writeln("color= ", color.no);
	writeln("color= ", color.yes);
	
	if (verbose) writeln("verbose");
}