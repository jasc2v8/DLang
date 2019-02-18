/*

 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt

 saveWip  [-install=Y|N] [-keep=N] [-list] [-quiet]
 
 saves D source files to a wip folder with timestamp

	-install | -i		Yes|No to uninstall in C:\Windows (requires Admin).
	-list    | -l		List files without saving to wip.
	-keep    | -k		Keep N versions in wip, purge older files.
	-quiet   | -q		Supress listing files saved to wip.
 
*/

module dlang.apps.savewip;

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

enum string DIRE_NF_ERR		= "Directory not found.";
enum string FILE_NF_ERR		= "File not found.";
enum string INSTALL_PATH	= r"C:\Windows";
enum string MKDIR_ERR		= "Error making new directory";
enum string SYNTAX_ERR		= "Syntax error, use -h for help.";

enum HELP_INFO				= "\nSaves D source files to a wip folder with timestamp.\n";
enum HELP_INSTALL			= r"Yes|No to uninstall in C:\Windows (requires Admin).";
enum HELP_LIST				= "List files without saving to wip.";
enum HELP_KEEP				= "Keep N versions in wip, purge older files.";
enum HELP_QUIET				= "Supress listing files saved to wip.";

enum SUCCESS = 0, ERROR = 1;

SpanMode spanMode;

alias say = writeln;

struct CommandLine {

	string source;
	string target;
	string install	= "";
	int keep 		= -1;
	bool list		= false;
	bool quiet		= false;
}

CommandLine cmd;

string[] files;
string[] flags;
string topDir, srcDir;
string wipPath, wipDir, wipBase;

GetoptResult helpInfo;

bool debug1 = false;

int main(string[] args) {

	//parse command line	
	try
	{
		helpInfo = getopt(
			args,
		    "install|i",	HELP_INSTALL,	&cmd.install,
			"list|l",		HELP_LIST,		&cmd.list,
			"keep|k",		HELP_KEEP,		&cmd.keep,
			"quiet|q",		HELP_QUIET,		&cmd.quiet,
			);

		if (helpInfo.helpWanted)
		{
			defaultGetoptPrinter(HELP_INFO, helpInfo.options);
			return SUCCESS;
		}
	
	} catch (Exception e) {
		writeln(SYNTAX_ERR);
		return ERROR; 
	}
	
	//edit cmd.install
	cmd.install = cmd.install.toUpper;
	
if (debug1) {
	writeln("args[0]", args[0]);
	if (args.length >1) writeln("args[1]", args[1]);
	writeln("cmd.i=", cmd.install);
	writeln("cmd.k=", cmd.keep);
	writeln("cmd.l=", cmd.list);
	writeln("cmd.q=", cmd.quiet);
}

    //Install or Uninstall
    if (cmd.install.startsWith("Y")) {
    	if ( doInstall("Install") ) { return SUCCESS; } else { return ERROR; }
    } else if (cmd.install.startsWith("N")) {
    	if ( doInstall("Remove")  ) { return SUCCESS; } else { return ERROR; }
    }

	//form path to src and wip
	if ("src".exists) {
		topDir = ".";
		srcDir = "src";	
		wipDir = "wip";			
	} else if (r"..\src".exists ) {
		topDir = r"..";
		srcDir = topDir ~ dirSeparator ~ "src";			
		wipDir = topDir ~ dirSeparator ~ "wip";			
	} else {
		writeln("ERROR src not found.");
		return ERROR;
	}
	
	///todo if files passed on command line, save them, else search
	
	//find all files under srcDir and save to wipDir
	foreach (string file; dirEntries(srcDir, SpanMode.shallow).filter!(f => f.isFile)) {
		
		//if app.d, don't get module name instead, maybe future, but why?

		if (!cmd.list) {
			string saved = doSaveWip(file, wipDir);
			if (!cmd.quiet) writeln("Saved to wip: ", saved);
		} else {
			if (!cmd.quiet) writeln("File in src: ", file);
		}
		
	}

	//purge and keep	
	if (cmd.keep >= 0) doKeep(cmd.keep);
	
	return SUCCESS;
	
}//main

	void doKeep(int keep) {
	
		string[] buff;
		string selectedFile = "";
		int timeStampLength = "_20170401_163556_67.wip".length; 
				
		//find all files under srcDir and save to wipDir
		foreach (string file; dirEntries(wipDir, SpanMode.shallow).filter!(f => f.isFile)) {
		
			if (file.endsWith(".wip") && file.length > timeStampLength)
			{
				//app.d_20170401_163556_67.wip
				if (file[0..file.length-timeStampLength] != selectedFile) {
					selectedFile = file[0..file.length-timeStampLength];
					buff ~= selectedFile;
				}
			}
		}	

		///
		if (debug1) foreach(f; buff) writeln("DEBUG1 buff=",f);
				
		//find multiple occurances of the same filename less timestamp
		string[] buff2;
		foreach (f; buff) {

			//if (debug1) writeln("f=",f);

			string sf = baseName(f).stripExtension ~ "*";
			foreach (string f2; dirEntries(wipDir, sf , SpanMode.shallow).filter!(f => f.isFile)) {	
				buff2 ~= f2;
				
				//writeln("DEBUG f2=",f2);
				
			}
			
			// sort
			sort(buff2); 			//ascending
			//buff2.sort!("a > b");	//descending

			int limit = buff2.length - keep;

			for (int i; i< buff2.length; i++)
			{		
				if (debug1) if (i < limit) writeln("DEBUG remove=", buff2[i]);
				if (i < limit) remove(buff2[i]);
			}
		}
		
	}
	
    string doSaveWip(string filePath, string wipDir)
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
        if (!exists(wipDir)) mkdir(wipDir);

		//app.d_20170401_163556_6770.wip
        wipPath = wipDir ~ dirSeparator ~ fileBase ~ "_" ~ timeStringEdited ~ ".wip";

        copy(filePath, wipPath);

        setTimes(wipPath, currentTime, currentTime);

        return wipPath;

    }

int doInstall(string action) {
	
	//get this exe name
	string thisExe = baseName(thisExePath());
	string thatExe = INSTALL_PATH ~ dirSeparator ~ thisExe;
	
//if (debug1) say("copy /y " ~ thisExe ~ " " ~ thatExe);

	if (action=="Install")
	{
    	if (exists(thatExe))
    	{
    		say("Already installed.");
    	} else {
    		
    		auto shellcmd = executeShell("copy /y " ~ thisExe ~ " " ~ thatExe);
    		
    		if (shellcmd.status != 0) {
    			say("Install requires privileges, run as Admin.");
    		} else {
	    		say("Installation complete.");
    		}  		
    	}

	} else if (action=="Remove"){

    	if (exists(thatExe)) {
    		std.file.remove(thatExe);
    		say("Uninstallation complete.");
    	} else {
    		say("Not installed.");
    	}
	}
	
	return SUCCESS;
}
