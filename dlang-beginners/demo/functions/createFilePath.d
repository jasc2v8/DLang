/*
UNTESTED

 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 
*/

module dlang.functions.createfilepath;

//D
import std.stdio;
import std.path;
import std.string;
import std.algorithm;

void main()
{
	writeln("todo createFilePath");	
}

void createFilePath(string filePath)
{
	if (!exists(dirName(filePath))) mkdirRecurse(dirName(filePath));

	try
    {
		File file = File(filePath, "w");
		file.writeln(r"//new file created by dbench");
		file.close();
   }
    catch (FileException ex)
    {
		txtStatus.setText("Error creating " ~ filePath);
    }
}
