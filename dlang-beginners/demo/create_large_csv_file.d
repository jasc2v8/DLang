/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt

	Creates a 250K line CSV that can be opened with Excel
	
*/

module dlang.modules.createlargecsvfile;

import std.stdio;
import std.exception;
import std.conv;
import std.format;
import std.process;
import std.file;

void main()
{
    try
    {
        auto file = File("250Kitems.csv", "w");
 
		for (int i=1; i <= 250_000; i++) {

	        file.write( format("%06d, ", i) );
	        file.write("SERIAL_NUMBER, ");
			file.write("ASSET_TAG, ");
			file.write("MODEL_NUMBER, ");
			file.write("MODEL_DESCRIPTION, ");
			file.write("PHYSICAL_ADDRESS, ");
			file.write("PHYSICAL_CITY, ");
			file.write("PHYSICAL_STATE, ");
			file.write("WARRANTY_START, ");
			file.write("WARRANTY_END\n");
		}
		
		auto cmd = executeShell(escapeShellCommand("cmd", "/C", "explorer", getcwd()));
    }
    catch (ErrnoException ex)
    {
        // Handle errors
    }
}
