/*

Compile with DUB (for testing)
	Edit dub.json, "targetName":"dBuild"
	Alt-P, check DUB builder, uncheck others
	Build only:		Alt-B, dBbuild_release
	Build and Run:	Alt-R, dBbuild - {default}
	of=dBench\dBuild.exe

Compile only with dBench\tools\dBuild_release.bat (alternate method)
	Alt-P, UNcheck DUB builder, check dBuild_release
	Build only:		Alt-B, dBbuild_release
	Build and Run:	Alt-R, dBbuild_release_run
	of=dBench\bin\release\dBuild.exe

todo	none

	dBuild is a front-end for DMD that is designed for use with Eclipse DDT.
	
		Key Features
		
		1. If d files not specified, searches the src folder for all *.d files to pass to DMD (shallow search)
		2. Source folder is src or ..\src
		3. Binary follder is bin\debug or bin\release
		4. Passes all files and option flags to DMD, except:
		
		-clean	delete bin\debug\* and bin\release\* before run
		-quiet	supresses build messages
		-run 	runs the target after build

Notes
	If the dmd option -of=foo is used, dBuild will not convert to an absolute path
	The current working directory will be used: bin\foo, not debug\foo or release\foo
	This should not be an issue for the intended use of DDT passing this parameter, not the user

*/

module dlang.apps.dbuild;

import std.stdio;
import std.algorithm;
import std.array;
import std.conv;
import std.datetime;
import std.getopt;
import std.file;
import std.path;
import std.process;
import std.string;
import std.traits;

enum SUCCESS=0, ERROR=1;

string[] files;
string[] flags;
string dmdFiles, dmdFlags, dmdArgs;	
string topDir, srcDir, binDir, outPath;
string wipPath, wipDir, wipBase;
string mainFile;

bool cleanFlag, helpFlag, quietFlag, runFlag;

int main(string[] args)
{

	//get files and flags, ignore arg[0] which is dBench.exe
	for (int i=1; i < args.length; i++) {
		if ( args[i].startsWith("-") ) {
			flags ~= args[i];
		} else {
			if (args[i] !="") files ~= args[i];  //.bat files could pass empty args
		}
	}
	
	//check option flags and strip from the command line so they are not passed to dmd args
	//incidently, this will also detect --wip
	string[] buffer;
	for (int i; i < flags.length; i++)
	{
		if ( indexOf(flags[i], "-clean") != -1 ) {
			cleanFlag = true;
		} else if ( indexOf(flags[i], "-help") != -1 ) {
			helpFlag = true;
		} else if ( indexOf(flags[i], "-quiet") != -1 ) {
			quietFlag = true;
		} else if ( indexOf(flags[i], "-run") != -1 ) {
			runFlag = true;
		} else {
			buffer ~= flags[i];
		}
	}

	flags = null; 
	flags = buffer;
	buffer = null;
	
	//show help
	if (helpFlag) {
		showHelp();
		return SUCCESS;
	}

	//if not specified, use defaults
	if ( files.length == 0 ) files ~= "*.d";	
	if ( flags.length == 0 ) flags ~= "-debug";	

	//form path to src and wip
	if ("src".exists) {
		topDir = ".";
		srcDir = "src";	
		binDir = "bin";	
		wipDir = "wip";			
	} else if (r"..\src".exists ) {
		topDir = r"..";
		srcDir = topDir ~ dirSeparator ~ "src";			
		binDir = topDir ~ dirSeparator ~ "bin";			
		wipDir = topDir ~ dirSeparator ~ "wip";			
	} else {
		writeln("ERROR src not found.");
		return ERROR;
	}

	//if no file specified, search ..\src\*.d
	if ( files[0] == "*.d" )
	{
		files = null;
		try
		{
			files = dirEntries( srcDir, "*.d", SpanMode.shallow)
	        .filter!(a => a.isFile)
	        .map!(a => relativePath(a))
	        .array;
			
		} catch  (Exception e) {
			writeln("ERROR directory not found: " ~ srcDir);
			return ERROR;	
		}
	
		if (files.length == 0) {
			writeln("ERROR files not found in: " ~ srcDir);
			return ERROR;
		}
	}

	//find file with main()
	int count;
	foreach (f; files)
	{
		if ( isMain(f) ) {
			mainFile = f;
			count++;
		}
	}

	//check for errors
	if (count == 0) {
		writeln("ERROR: No file is main().");
		return ERROR;
	}
		
	if (count > 1) {
		writeln("ERROR: More than one file is main().");
		return ERROR;
	}
	
	//form the files into one string for dmd
	foreach (f; files)
		dmdFiles ~= f ~ " ";
	
	//form flags
	foreach (f; flags)
		dmdFlags ~= f ~ " ";

	//combine files and flags
	dmdArgs = dmdFiles ~ dmdFlags;	

	if (!binDir.exists) {
		mkdir(binDir);
	}
	
	if (cleanFlag)
	{
		foreach (string file; dirEntries(binDir, SpanMode.depth).filter!(f => f.isFile)) {
		    remove(file);
		}
	}
	
	//if -of not specified, add -of=debug or release
	if (dmdArgs.indexOf("-debug") != -1)
	{
		binDir = binDir ~ dirSeparator ~ "debug";
	} 
	else if (dmdArgs.indexOf("-release") != -1)
	{
		binDir = binDir ~ dirSeparator ~ "release";
	}
	else
	{
		binDir = binDir ~ dirSeparator ~ "debug";
	}
	
	//if no -of, add the file with main() as the target exe
	if (dmdArgs.indexOf("-of") == -1) {
		outPath = binDir ~ dirSeparator ~ baseName(mainFile).stripExtension ~ ".exe";
		dmdArgs = dmdArgs ~ "-of=" ~ outPath;
	}

	//run dmd
	string cmd = "dmd " ~ dmdArgs;
	int returnCode = doPipeShell(cmd);

	if (!quietFlag)            writeln("dBuild command : ", cmd);

	if (!quietFlag)            writeln("dBuild source  : ", dmdFiles);

	if (runFlag && returnCode != ERROR)
	{
		if (!quietFlag)        writeln("dBuild run     : ", outPath);
		
		//flush before run so user can read the above
		if (!quietFlag) stdout.flush();
	
		//run
		auto pid = spawnProcess(outPath);
		scope(exit) wait(pid);

	} else {
		if (!quietFlag) writeln("dBuild target  : ", outPath);
	}
	
	return SUCCESS;

}

bool isMain(string filePath) {
	string line;
	string moduleName;
	
	if ( filePath.exists )
	{
		try
	    {
	        auto file = File(filePath, "r");
	        while ((line = file.readln()) !is null)
	        {
				if (indexOf(line, " main(") != -1) {
					//file.close;  //gotta love D for handling file close!
					return true;
				}
	        }
	    }
	    catch (FileException ex)
	    {
	        writeln("ERROR reading ", filePath);
	    }
	}
	return false;
}

int doPipeShell(string cmd) {
	
	int returnCode = 0;
	
	auto pipes = pipeShell(cmd, Redirect.stdout | Redirect.stderr, null, Config.suppressConsole);
	
	scope(exit) {
	    wait(pipes.pid);
	}
	
	foreach (line; pipes.stdout.byLine) {
	    writeln(to!string(line));	
	}
	
	foreach (line; pipes.stderr.byLine) {
	    writeln(to!string(line));
	    returnCode = 1;
	}
	
	return returnCode;
}

void showHelp()
{

string helpText = r"
dBuild is a front-end for DMD.  All arguments are passed to DMD except:

  -clean Delete bin\debug\* and bin\release\*.
  -quiet Supresses dBuild messages.
  -run   Runs the target after build.
  -help  This help information.
";

    writeln(helpText);

}
void debugWriteArray(string name, string[] array) {
	int count;
	foreach (a; array) {
		writefln("%s[%s]=%s", name, count, array[count]);
		count++;
	}
}