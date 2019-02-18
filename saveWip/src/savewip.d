/*


 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 Version: 2.0.0

 See HELP_INFO below for syntax and usage
 
*/

module jasc2v8.savewip;

import std.array;
import std.algorithm;
import std.algorithm.sorting;
import std.conv;
import std.file;
import std.getopt;
import std.path;
import std.process;
import std.stdio;
import std.string;

enum SRC_DIR = "src";
enum WIP_DIR = "wip";

enum ERROR_MSG 		= "saveWip ERROR: ";
enum WARNING_MSG 	= "saveWip WARNING: ";
enum INFO_MSG		= "saveWip INFO: ";

enum DIRE_NF_ERR	= ERROR_MSG ~ "Directory not found";
enum FILE_NF_ERR	= ERROR_MSG ~ "File not found";
enum MKDIR_ERR		= ERROR_MSG ~ "Error making new directory";
enum SYNTAX_ERR		= ERROR_MSG ~ "Syntax error, use -h for help";

enum HELP_INFO		= "\nSaves source files to a work in progress folder with timestamp\n" ~
					  "\nUsage: saveWip  [file | folder | path/* [./src]] [-keep=#] [-list] [-quiet]\n";
					  
enum HELP_INFO_ADD	= "\nThe ./wip folder is created if not present" ~
					  "\nThe ./src folder is used by default if the source file or folder is not specified\n" ~
					  "\nWildcards not allowed for the file or folder" ~
					  "\nWildcards are allowed for path/*.ext but not for path/file.*\n";

enum HELP_LIST		= "List files without saving to wip";
enum HELP_KEEP		= "Keep # versions in wip, purge older files";
enum HELP_QUIET		= "Supress listing files saved to wip";

enum SUCCESS = 0, ERROR = 1;

SpanMode spanMode;

alias say = writeln;

struct CommandLine {
	int keep 		= -1;
	bool list		= false;
	bool quiet		= false;
}

CommandLine cmd;

GetoptResult helpInfo;

int main(string[] args) {

	//parse command line	
	try
	{
		helpInfo = getopt(
			args,
			"list|l",		HELP_LIST,		&cmd.list,
			"keep|k",		HELP_KEEP,		&cmd.keep,
			"quiet|q",		HELP_QUIET,		&cmd.quiet,
			);

		if (helpInfo.helpWanted)
		{
			defaultGetoptPrinter(HELP_INFO, helpInfo.options);
			say(HELP_INFO_ADD);
			return SUCCESS;
		}
	
	} catch (Exception e) {
		say(SYNTAX_ERR);
		return ERROR; 
	}
	
    //if no file or folder on command line, default to src folder
    if (args.length==1) args ~= SRC_DIR;

	//copy all files or folders on command line, skip arg[0]=this exe
	for (int i=1; i<args.length; i++) {
		copyFiles(args[i]);	
	} 

	//purge and keep	
	if (cmd.keep >= 0) doKeep(cmd.keep);

	return SUCCESS;
		
}//main

void copyFiles(string fileName) {
	
	//if path/*.ext
	if (fileName.baseName.stripExtension == "*") {
		foreach (string file; dirEntries(fileName.dirName, SpanMode.shallow).filter!(f => f.isFile)) {
			if (file.extension == fileName.extension) doSaveWip(file);
		}
	}
	
	//if not exist, try default of .d, else process file or folder
	if (!fileName.exists) {
		
		fileName ~= ".d";
		
		if (fileName.exists) {
			doSaveWip(fileName);
		} else {
			say(FILE_NF_ERR ~ ": " ~ fileName);
		}
		
	} else if (fileName.isDir) {
		
		foreach (string file; dirEntries(fileName, SpanMode.shallow).filter!(f => f.isFile)) {
			doSaveWip(file);
		}

	} else if (fileName.isFile) {
		
		doSaveWip(fileName);
		
	} else {
		say(WARNING_MSG ~ "invalid file or folder, ignore: " ~ fileName);
	}
	
}

void doSaveWip(string filePath)
{
    string fileBase = baseName(filePath);
    string fileName = stripExtension(fileBase);
    string fileExt  = extension(fileBase);

	//get current time
    import core.time;
    import std.datetime;
    auto currentTime = Clock.currTime();
	//truncate to 2 decimals
    //from: 20170401T163556.6770637
    //to  : 20170401T163556.67
    auto timeString = currentTime.toISOString()[0..18];

    //edit time string, change 'T' and '.' to '_'
    //from: 20170401T163556.67
    //to  : 20170401_163556_67
	string timeStringEdited;
    for (int i; i < timeString.length; i++)
    {
        if (timeString[i .. i + 1] == "T")
        {
            timeStringEdited ~= "_";
        }
        else if (timeString[i .. i + 1] == ".")
        {
            timeStringEdited ~= "_";
        }
        else
        {
            timeStringEdited ~= timeString[i .. i + 1];
        }
    }

    //if wip not exists, create the subdir
    if (!exists(WIP_DIR)) mkdir(WIP_DIR);

	//app.d_20170401_163556_6770.wip
    string wipPath = WIP_DIR ~ dirSeparator ~ fileBase ~ "_" ~ timeStringEdited ~ ".wip";
    
	if (!cmd.list) {
	    copy(filePath, wipPath);
	    setTimes(wipPath, currentTime, currentTime);
		if (!cmd.quiet) say("saveWip Saved: ", wipPath);
	} else {
		if (!cmd.quiet) say("saveWip Listed: ", wipPath);
	}	

}

void doKeep(int keep) {

	string[] buff;
	
	int timeStampLength = "_20170401_163556_67.wip".length; 
			
	//find all wip files under WIP_DIR
	foreach (string file; dirEntries(WIP_DIR, SpanMode.shallow).filter!(f => f.isFile)) {
		if (file.endsWith(".wip")) buff ~= file;
	}

	//descending sorts the newer files to the top, older at the bottom
	//sort(buff);			//ascending
	buff.sort!("a > b");	//descending

	for (int i; i < buff.length; i++)
	{		
		int count = 0;
		for (int j; j < buff.length; j++)
		{
			auto end = buff[j].length - timeStampLength;
			if ( buff[j][0..end] == buff[i][0..end] )
			{
				count++;
				if (count > keep && buff[j].exists) remove(buff[j]);
			}
		}
	}
}
