/+

 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: https://opensource.org/licenses/MIT
 
 Versions:  1.0.0   release

 Description:
 
    Builds the static libraries for the dub package dwtlib
  
    See showHelp() for command line arguments
  
+/

module dwtlib.tools.build_dwtlib;

import std.algorithm, std.ascii, std.array;
import std.conv;
import std.file;
import std.path, std.process;
import std.stdio, std.string;

enum SUCCESS=0, ERROR=1;
enum ERR = "Build_dwtlib ERROR ";

string buildArch, buildArgs, cmd;

bool cleanOnly = false;

version (Windows) {
    immutable isWindows = true;
    immutable buildPlatform = "Windows";
} else {
    immutable isWindows = false;
    immutable buildPlatform = "Posix";  //Ubuntu reports "Posix"
}

version (X86_64) {
    immutable is64bit = true;
} else {
    immutable is64bit = false;
}

//define the dub package paths

immutable dwtDir    = "dwt";
immutable dwtImp    = "imp";
immutable dwtLib    = "lib";
immutable dwtObj    = "obj";
immutable dwtRes    = "res";
immutable dwtSrc    = "src";
immutable dwtJava   = dwtSrc ~ dirSeparator ~ "java";
immutable dwtSource = "source";
immutable dwtViews  = "views";

int main(string[] args)
{

	//if not exists dwt build.d then error
    if (!buildPath(dwtDir, "build.d").exists) {
        writeln(ERR, "dwt build.d not found.");
        return ERROR;
    }
    
    //if any args, strip off arg[0] and pass args to dwt/build.d
    if (args.length > 1) {
        foreach (arg; args[1 .. $])
            buildArgs ~= arg ~ " ";
    }

    //parse help
    if (buildArgs.canFind("-h")) {
        showHelp();
        return SUCCESS;
    }
    
    //add defaults if missing
    if (!buildArgs.canFind("clean ")) buildArgs ~= "clean ";
    if (!buildArgs.canFind("base " )) buildArgs ~= "base ";
    if (!buildArgs.canFind("swt "  )) buildArgs ~= "swt ";
    
    //parse windows args
    if (isWindows) {
        if (buildArgs.canFind("-m64")) {
            buildArch = "64-bit";
            if (buildArgs.canFind("-m32mscoff")) {
                writeln(ERR~"can't have -m32mscoff with a 64-bit build.");
                return ERROR;
            }
        } else {
            buildArch = "32-bit";
            if (buildArgs.canFind("-m32mscoff")) {
                buildArch = "32-bit and write MS-COFF object files";
            }
        }
    } else {
        if (is64bit) {
            buildArch = "64-bit";
        } else {
            buildArch = "32-bit";
        }
    }
    
    //work in the dwt folder
    chdir(dwtDir);
    writeln("Build_dwtlib working in  : ", getcwd());
    
    //if the only arg is "clean", then clean, else clean and build
    if (args.length == 2 && args[1] == "clean") {
        cleanOnly = true;
        writeln ("Build_dwtlib cleaning");
        cmd = "rdmd build.d clean";
    } else {
        writeln ("Build_dwtlib builiding   : " ~ buildPlatform ~ " " ~ buildArch);
        cmd = "rdmd build.d " ~ buildArgs;
    }
    
    writeln("Build_dwtlib command line: ",cmd);
 
    //spawn cmd
    if (0 != wait(spawnShell(cmd))) {
        throw new Exception(ERR~"spawning cmd.");
    }
	
    if (cleanOnly) {
        dwtClean();
    } else {
    
        writeln("Build_dwtlib creating DWT package folder structure");

        //copy files
		//copyFolder("lib", "*", dwtLib);
		
        copyFolder("res", "*.properties", dwtViews);
		
        copyFolder("base/src/java", "*.d", dwtJava);
		
        if (isWindows) {
            copyFolder("org.eclipse.swt.win32.win32.x86/src", "*.d", dwtSrc);
        } else {
            copyFolder("org.eclipse.swt.gtk.linux.x86/src"  , "*.d", dwtSrc);
        }
        
        //remove dwt folders that will conflict with the dub package
        dwtClean();      
    }
    
    //back to start directory
    chdir("..");
    
    //finished
    writeln("Build_dwtlib finished.");
	return SUCCESS;

}

int copyFolder(string sourceFolder, string pattern, string targetFolder) {

    foreach (string file; 
		dirEntries(sourceFolder, pattern, SpanMode.depth).filter!(a => a.isFile))
    {
	    //append source path as subdir to target path
        string targetPath = targetFolder ~ file[sourceFolder.length .. $];
		//if not exist, create folder
        mkdirRecurse(targetPath.dirName);
        copy(file, targetPath);
    }
    
    return SUCCESS;
}

string fixPath(string path) {
    if (isWindows) {
        return path.replace( "/", "\\" );
    } else {
        return path;
    }
}

void dwtClean() {
    rmdirRecurseE(dwtImp);
    //rmdirRecurseE(dwtLib); //keep
    rmdirRecurseE(dwtObj);
    rmdirRecurseE(dwtRes);
    //rmdirRecurseE(dwtSrc);  //keep
    rmdirRecurseE(dwtSource);
    //rmdirRecurseE(dwtViews);  //keep
}
 

void rmdirRecurseE(string path) {
    if (path.exists()) {
        std.file.rmdirRecurse(path);
    }
}

void showHelp()
{

string helpText = `
	
  Executes the DWT build.d file that builds the dwtlib static libraries 'base' and 'swt'

    Usage:rdmd ./build_dub_package.d [-h|--help] [clean base swt] [-m64] [-m32mscoff]
    
    Creates the dub package structure as follows:
  
        ./src/base	base (java) D import files
        ./src/swt   swt D import files, linux or windows
        ./views     swt *.properties string import files
        ./lib       dwt static libraries, differs by platform and arch	
`;
    writeln(helpText);
}

