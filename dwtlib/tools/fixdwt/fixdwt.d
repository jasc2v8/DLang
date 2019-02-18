/+

 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: https://opensource.org/licenses/MIT
 
    Version:    2.0.0   Add tempFile, -l|--list list only do not fix
                1.1.0   Add special case Tree.d
 
    $ rdmd fixdwt [-l|--list]
    
    Replace all double semicolons ";;" with single semicolon ";" in DWT *.d files
  
    Alogrithm:
    Search "dwt" or "..\dwt" or "..\..\dwt" for all *.d files recursive
    find ";;"
    if not "(;;)" then replace ;; with ;
    
    Assume fixes are in a GitHub repository that tracks changes
    Backup and temp files will flag changes in the repository
    Therefore, use the system temp folder to make changes
    Then overwrite the existing file
    The result is only the fixed file is recognized by GitHub as changed
  
+/

module dlang.apps.fixdwt;

import std.algorithm;
import std.file;
import std.path;
import std.stdio;
import std.string;

enum SUCCESS=0, ERROR=1;
enum ERR        = "fix ERROR ";
enum dwtDir1    = "dwt";
enum dwtDir2    = ".." ~ dirSeparator ~ "dwt";
enum dwtDir3    = ".." ~ dirSeparator ~ ".." ~ dirSeparator ~"dwt";

string dwtDir;
int count;
bool listFlag = false;

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
        writeln(ERR, "fixdwt DWT directory not found.");
        return ERROR;
    }
    
    if (args.length > 1 && args[1].canFind("-l")) listFlag = true;

    writeln ("fixdwt Working in folder: ", dwtDir);
 
    int rtn;
    
    foreach (string file; dirEntries(dwtDir, "*.d", SpanMode.depth).filter!(a => a.isFile))
    {
        rtn = checkFile(file, ";;", ";", "(;;)");
    }
    
    //special cases go here
    string tree = fixPath(dwtDir ~ "/org.eclipse.swt.gtk.linux.x86/src/org/eclipse/swt/widgets/Tree.d");
    rtn = fixFile(tree, "};", "}", "(;;)");
    
    //finished
    writefln("fixdwt Finished, number of fixes: %s", count);
    
    if (rtn == ERROR) return ERROR;
    
	return SUCCESS;

}

int checkFile(string filePath, string oldText, string newText, string okText) {
    
    int rtn;
    string line;
    bool needsFix = false;
    
    try
    {
        auto inpFile = File(filePath, "r");
        
        while ((line = inpFile.readln()) !is null)
        {			
			if (line.indexOf(oldText) != -1 && line.indexOf(okText) == -1) {
                needsFix = true;
                break;
			}
        }
    }
        catch (FileException ex)
    {
        writeln(ERR, "checking ", filePath);
        return ERROR;
    }
    
    if (needsFix) {
        if (listFlag) {
            writeln("fixdwt Needs Fix: ", filePath);
        } else {
            rtn = fixFile(filePath, oldText, newText, okText);
        }
    }
        
    return SUCCESS;
}


int fixFile(string filePath, string oldText, string newText, string okText) {
    
    if (!filePath.exists) {
        writeln(ERR,"File not found: ", filePath);
        return ERROR;
    }

    //WINDOWS ONLY if LSB == 1 then file attr == readonly
    //save attr, set to normal, overwrite file, reset attr
    bool isReadOnly = false;
    immutable uint LSB_MASK = 0x01;
    immutable uint FILE_ATTRIBUTE_NORMAL = 0x80;
    immutable uint savedAttributes = filePath.getAttributes;
    if ((savedAttributes & LSB_MASK) == 1) {
        isReadOnly = true;
        filePath.setAttributes(FILE_ATTRIBUTE_NORMAL);
    }
    
    string line;
    bool isFixed = false;
    string tempFile = tempDir() ~ baseName(filePath);
    
    try
    {
        auto inpFile = File(filePath, "r");
        auto outFile = File(tempFile, "w");
        
        while ((line = inpFile.readln()) !is null)
        {		
			if (line.indexOf(oldText) != -1 && line.indexOf(okText) == -1) {
                line = line.replace(oldText, newText);
                isFixed = true;
                count++;
			}
            outFile.write(line);  //writeln would add \n
        }
    }
        catch (FileException ex)
    {
        writeln(ERR, "Error fixing ", filePath);
        return ERROR;
    }
    
    if (isFixed) {
        copy(tempFile, filePath);
        writeln("fixdwt Fixed: ", filePath);
    }
    
    if (isReadOnly) {
       filePath.setAttributes(savedAttributes);
    }

    if (tempFile.exists) remove(tempFile);

    return SUCCESS;
}

string fixPath(string path) {
    if (isWindows) {
        return path.replace( "/", "\\" );
    } else {
        return path;
    }
}