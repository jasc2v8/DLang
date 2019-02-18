/*

 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 
 A demo of dirEntires
 
	The default behavior is as follows.
	Note a dirSeparator and wildcard are needed to be a directory

	D:\DEV\Work\work-d\dlang-beginners>dlang functions
	DIR: ., FILE: functions, MODE: -s
	File not found.
	
	D:\DEV\Work\work-d\dlang-beginners>dlang functions\
	DIR: ., FILE: functions, MODE: -s
	File not found.
	
	D:\DEV\Work\work-d\dlang-beginners>dlang functions\*
	DIR: functions, FILE: *, MODE: -s
	Found: functions GetNumberFormatW.d
	Found: functions GetNumberFormatW_DWT.d
	Found: functions formatCommaSeparatedNumber.d
	Found: functions isDirFileWild.d
	Found: functions stopwatch.d
	Found: functions toXbytes.d
	
	D:\DEV\Work\work-d\dlang-beginners>dlang functions\*.*
	DIR: functions, FILE: *.*, MODE: -s
	Found: functions GetNumberFormatW.d
	Found: functions GetNumberFormatW_DWT.d
	Found: functions formatCommaSeparatedNumber.d
	Found: functions isDirFileWild.d
	Found: functions stopwatch.d
	Found: functions toXbytes.d

*/

module dlang.modules.direntries;

import std.stdio;
import std.string;
import std.conv;
import std.file;
import std.path;
import std.array;
import std.algorithm;
import std.algorithm.sorting;

enum string DIRE_NF_ERR		= "Directory not found.";
enum string FILE_NF_ERR		= "File not found.";
enum string SYNTAX_ERR		= "Syntax error. Arguments are: fileName -Breath, [-S]hallow";
enum SUCCESS = 0, ERROR = 1;

alias writeln say;

string spanModeArg, fileName;
SpanMode spanMode;

int main(string[] args) {

	//say("args length=",args.length);
	
	//args[0] = this exe, args[1]=filename
	if (args.length == 3) spanModeArg = toLower(args[2]);
	if (args.length > 1 ) fileName = args[1];
	if (args.length == 1 ) {
		stderr.writeln(SYNTAX_ERR);
		return ERROR;
	}
	
	
	//prepare search
	if (spanModeArg=="-b") {
		spanMode = SpanMode.breadth; //scan subdir first, then subsubdirs	
	} else {
		spanModeArg="-s";
		spanMode = SpanMode.shallow; //Only spans one directory
	}
	
	string sourceDir  = dirName(fileName);
	string sourceFile = baseName(fileName);
	
//	if (isDir(fileName)) {
//		sourceDir = fileName;
//		fileName = "*";
//	}
	
	writeln("DIR: ", sourceDir, ", FILE: ", sourceFile, ", MODE: ", spanModeArg);
	
	//get list of filenames in an array
	string[] foundFiles;
	try
	{
		foundFiles = dirEntries( sourceDir, sourceFile, spanMode)
        .filter!(a => a.isFile)
        .map!(a => dirName(a) ~ "\0" ~ baseName(a)) //separate with a null so the path will sort properly
        .array;
		
	} catch  (Exception e) {
		say(DIRE_NF_ERR);
		return ERROR;	
	}

	if (foundFiles.length == 0) {
		say(FILE_NF_ERR);
		return ERROR;
	}

	//sort the array
	foundFiles.sort();
	
	//iterate the array to form source and target paths
	foreach (f; foundFiles) {
		say("Found: ", f);	
	}	
	
	return SUCCESS;
	 
}
