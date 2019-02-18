/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt

 */

module dlang.modules.getmodulename;

import std.stdio;
import std.conv;
import std.array;
import std.file;
import std.path;
import std.range;
import std.string;
import std.algorithm;


void main()
{

    writeln("Module name is: " ~ getModuleName("getModuleName.d"); 
}

string getModuleName(string filePath)
{
	string line;
	string moduleName;
	
	try
    {
        auto file = File(filePath, "r");
        
        while ((line = file.readln()) !is null)
        {
			
			if (startsWith(line, "module")) {
				int dot = lastIndexOf(line, ".");
				if (dot == -1) dot = "module".length;
				int end = lastIndexOf(line, ";");
				if (end == -1) end = line.length-1;
				moduleName = line[dot+1..end];
				break;
			}
        }
    }
    catch (FileException ex)
    {
        // Handle errors
        setStatus("Error reading " ~ filePath ~ ", using default module name of app");
    }

	//if module name not found, return "app"
    if (moduleName == "") moduleName = "app";
    
    return moduleName;
    
}
