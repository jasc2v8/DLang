module dlang.modules.getopt;

import std.stdio;
import std.getopt;
import std.typecons;

string data;
int length;
bool verbose;
enum Color { no, yes }; 
Color color; // --color=[yes, no]default initialized to Color.no

bool q;
bool windowsHelp;

GetoptResult helpInfo;

dchar FORWARD_SLASH = '/';

void main(string[] args)
{
	
	//writeln("before=", std.getopt.optionChar);
	//std.getopt.optionChar = cast(dchar) '/';
	//writeln("after =", std.getopt.optionChar);
	
	try
	{
		//use default optionChar = '-'
		helpInfo = getopt(
			args,
		    "length|l",  "Info about length.", &length,    // numeric
			"file|f",    "Info about file.", &data,      // string
			"verbose|v", "Info about verbose.", &verbose,
			"color|c", "Info about color.", &color,
			"quiet|q", "Info about q.", &q
			);   // flag

		if (helpInfo.helpWanted)
		{
			defaultGetoptPrinter("Some information about the program.", helpInfo.options);
			return;
		}
	
		//for Windows users, also check optionChar = '/'
		std.getopt.optionChar = FORWARD_SLASH; //must be global

		helpInfo = getopt(
			args,
		    "help|h",  "Info about help.", &windowsHelp,    // numeric
		    "length|l",  "Info about length.", &length,    // numeric
			"file|f",    "Info about file.", &data,      // string
			"verbose|v", "Info about verbose.", &verbose,
			"color|c", "Info about color.", &color,
			"quiet|q", "Info about q.", &q
			);   // flag

		if (windowsHelp)
		{
			defaultGetoptPrinter("Some information about the program.", helpInfo.options);
			return;
		}
	
	} catch (Exception e) {
		writeln("Syntax error, use -h for help");
		return; 
	}
	
	writeln("data   =", data);
	writeln("length =", length);
	writeln("color  =", color);

	if (verbose) writeln("verbose");
	if (q) writeln("q");
}