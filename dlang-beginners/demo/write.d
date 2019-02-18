/*

ref: http://stackoverflow.com/questions/5508497/what-is-the-preferred-console-output-method-in-modern-d

Within the module std.stdio, you'll find write and friends: writeln, writef, and writefln.

write just takes each argument, converts it to a string, and outputs it:
    write(5, " <- that's five"); // prints: 5 <- that's five

writef treats the first string as a format-specifier (much like C's printf), and uses it to format the remaining arguments:
    writef("%d %s", 5, "<- that's five"); // prints: 5 <- that's five

The versions ending with "ln" are equivalent to the version without it, but also append a newline at the end of printing.
All versions are type-safe (and therefore extensible).

*/

module dlang.mod.write;

import std.stdio;

void main() {

	
	//write just takes each argument, converts it to a string, and outputs it:
    write(1, " <- one");

	//writef treats the first string as a format-specifier (much like C's printf), and uses it to format the remaining arguments:
    writef("%d %s", 2, "<- two");

	//versions ending with "ln" aappend a newline at the end of printing.
    writeln(3, " <- three");
    writefln("%d %s", 4, "<- four");
    writefln("%s", 5, "<- five"); //missing a format-specifier

    //writefln("%f", 6, "<- six"); //FormatException, can't convert int 6 to float %f
    writefln("%f %s", 6., "<- six float"); //now 6 is a float
    writefln("%s %s", 6., "<- six string"); //%s will print all types as string, less decimals
    writefln("%06.2f, %s", 66., "<- sixty-six"); //6 total chars including the period, pad leading zeros, 2 decimal points
      
}
