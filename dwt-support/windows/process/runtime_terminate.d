/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
*/

module main;

import std.stdio : writeln;
import core.runtime : Runtime;

void main()
{
	writeln("Runtime terminate!");
	Runtime.terminate();
}
