/*

Can I call teh win32 API directly from D?

Yes, HOWEVER, then I'll need to import windows.h and link to kernal32.lib, etc.

Probably easier to use the DWT library or create a function;

	getNumberFormat(string number)

	string mynumber = getNumberFormat("1024"); //mynumber = "1,024"
	
Update: see formatCommaSeparatedNumber.d 

*/

module dlang.mod.getnumberformatW;

import std.stdio;

import core.sys.windows.windows;

//extern(C) int printf(const(char*) format) nothrow @nogc;

extern (Windows)
{
    /* ... function declarations ... */
}

void main() {


}

