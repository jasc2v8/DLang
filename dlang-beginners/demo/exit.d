/*

 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
*/

module dlang.modules.exit;

import std.stdio : writeln;
public import core.stdc.stdlib;	//C lib exit

void main()
{
	writeln("C library exit!");
	
	exit(0); //C lib exit
}
