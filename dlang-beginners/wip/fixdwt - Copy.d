/+

 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: https://opensource.org/licenses/MIT
 
 Version: 1.0.1 fixed error with isFixed logic
 
    $ rdmd fixdwt
    
    Replace all double semicolons ";;" with single semicolon ";" in DWT *.d files
  
    Alogrithm:
    Search "dwt" or "..\dwt" or "..\..\dwt" for all *.d files recursive
    find ";;"
    if not "(;;)" then replace ;; with ;
  
+/

module dlang.apps.fixdwt;

import std.algorithm;
import std.file;
import std.path;
import std.stdio;
import std.string;

enum SUCCESS=0, ERROR=1;
enum ERR        = "fixDWT ERROR ";

enum dwtDir1    = "dwt";
enum dwtDir2    = ".." ~ dirSeparator ~ "dwt";
enum dwtDir3    = ".." ~ dirSeparator ~ ".." ~ dirSeparator ~"dwt";

string dwtDir;
int count;

version (Windows) {
    immutable isWindows = true;
    immutable buildPlatform = "Windows";
} else {
    immutable isWindows = false;
    immutable buildPlatform = "Posix";  //Ubuntu reports "Posix"
}

int main(string[] args)
{
    
    if (dwtDir1.exists) {
        dwtDir = dwtDir1;
    } else if (dwtDir2.exists) {
        dwtDir = dwtDir2;
    } else if (dwtDir3.exists) {
        dwtDir = dwtDir3;
    } else {
        writeln(ERR, "dwt directory not found.");
        return ERROR;
    }
    
    writeln ("Fixing DWT files in folder: ", dwtDir);
 
    int rtn;
    
    foreach (string file; dirEntries(dwtDir, "*.d", SpanMode.depth).filter!(a => a.isFile))
    {
        rtn = fixFile(file);
    }
    
    writefln("Finished, number of fixes : %s", count);
    
    if (rtn == ERROR) return ERROR;
    
	return SUCCESS;

}

int fixFile(string filePath) {
    
	string bakFile = filePath.stripExtension ~ ".bak";
    string tmpFile = filePath.stripExtension ~ ".tmp";
    string line;
    bool isFixed = false;
    
    try
    {
        auto inpFile = File(filePath, "r");
        auto outFile = File(tmpFile, "w");
        
        while ((line = inpFile.readln()) !is null)
        {
			
            // allow (;;) but not ;;
			if (line.indexOf(";;") != -1 && line.indexOf("(;;)") == -1) {
                line = line.replace(";;", ";");
                isFixed = true;
                count++;
			}
            
            outFile.writeln(line);
        }
    }
        catch (FileException ex)
    {
        writeln(ERR, "Error reading ", filePath);
        return ERROR;
    }
    
    if (isFixed) {
        rename(filePath, bakFile);
        rename(tmpFile, filePath);
        writeln("fixDWT Fixed: ", filePath);
        if (bakFile.exists) remove(bakFile);
        if (tmpFile.exists) remove(tmpFile);
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
