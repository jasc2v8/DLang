module tutorials.examples.h_to_d.simpleheadertodsrcexample;
/*

SimpleHeaderToDsrcExample
by J C Calvarese
converted to D2 by jasc2v8 at yahoo dot com

License: Public Domain

Partially converts a C header file (.h) to a D module (.d).
 * Doesn't convert everything.
 * Converts constants so that I can use them in a resource file and in a D module.
 * End-of-line comments (//) aren't handled as they should be.

*/

import std.file;
//import std.stream;
import std.string;
import std.stdio;

const char[] pgmFilename = "SimpleHeaderToDsrcExample.exe";

string BaseFilenameWithPath(string hFile)
{

    /* Returns the path & filename without the .h extension. */

    int i = lastIndexOf(hFile, ".h");

	if (i == -1) {
		return hFile;
	} else {
		return hFile[0..i];
	}
	
}


int main(string[] args)
{
//    char[] r;
//    char[] v1;
//    char[] v2;
//    char[] s1;
//    char[] s2;

	string r, v1, v2, s1, s2;
	
    int i;
    int line;

    writefln(pgmFilename ~ " (partially converts .h files to .d files)");

    if (args.length < 2) 
    { 
		writeln("Usage: " ~ pgmFilename ~ " [source.h]\n");	
		return 0;
    }

    if (exists(args[1])) /* File Exists . . . */
    {
		writefln(pgmFilename ~ ": Creating " ~ BaseFilenameWithPath(args[1]) ~ ".d...");
	
        File fi = File(args[1]);

        File fo = File(BaseFilenameWithPath(args[1]) ~ ".d", "w");

        while (!fi.eof())  
        {
            r = strip(fi.readln());
            
            line++;
            if (r.length >= 0) 
            {
                /* split varName into name & value */
                i = indexOf(r, ' ');  /* returns -1 if it's not found . . . */

                if (i > 0)
                {
                    s1 = strip(r[0..i]);
                    s2 = strip(r[i..r.length]);
    
                    if(s1 == "#define")
                    {        
                        i = indexOf(s2, ' ');
    
                        if (i == 0)
                            writeln("Error (line %i): missing definition.", line);
                        else
                        {
                            v1 = strip(s2[0..i]);
                            v2 = strip(s2[i..s2.length]);
                           
                            if (v2[0..1] == "\"")
                            {
                                fo.writeln("const char[] " ~ v1 ~ " = " ~ v2 ~ ";");
                            }
                            else
                                if (v2[0..1] == "-")
                                {
                                    fo.writeln("const int " ~ v1 ~ " = " ~ v2 ~ ";");
                                }
                                else
                                {
                                    fo.writeln("const uint " ~ v1 ~ " = " ~ v2 ~ ";");
                                }
                        }
                    }
                    else fo.writeln(r);
                }    
                else fo.writeln("");
            }
        }

        writefln("h_to_d.exe: Finished.");
        fo.close();
        fi.close();
    }
    else
        writefln("File not found: %i", args[1]);
    return 0;
}