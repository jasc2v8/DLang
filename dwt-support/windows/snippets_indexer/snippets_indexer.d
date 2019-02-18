/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: https://opensource.org/licenses/MIT
 
 Writes each Snippet module item, number, and description to a text file 
 
 Run using: rdmd snippets_indexer.d

 Snippets modified: 
 Snippet45 - added a description
 Renamed SnippetDwtBitmapV4 to Snippet1DwtBitmapV4 so it will index
 
*/

module SnippetsIndexer;

import std.stdio;
import std.algorithm : sort;  // or import std.algorithm.sorting;
import std.array;
import std.conv;  //to!string
import std.file;
import std.path;
import std.process;
import std.range;
import std.string;
import core.runtime;

string[] buffer;
int count = 0;
const string INDEX_FILE = "snippets_index.txt";

void main()
{
	
	// if snippets subdirectory does not exist, then exit
	if (!exists("snippets")) {
		writeln("snippets subdirectory does NOT exist, exiting...");
		Runtime.terminate();
	}
	
	//get a list of all *.d files in .\snippets
	auto dFiles = dirEntries("snippets", "*.d", SpanMode.shallow);
	
	// process one at a time
	foreach (file; dFiles) {
	    //writeln(file.name);
	    ProcessFile(file.name);
	}

	//inform how many snippets found
    writeln("\nFinished: " ~ to!string(count) ~ " Snippets indexed to " ~ INDEX_FILE);

	//just for fun
	//auto pid = spawnProcess(["notepad", INDEX_FILE]);
}

void ProcessFile(string filename)
{
	//open file
	auto snippet = File(filename, "r");
	
	//loop through file
	int index;
	string line, snippetNumber, snippetDescription;
	while ((line = snippet.readln()) !is null)
	{
            //find the module name
            index = indexOf(line, "module");
            if (index != -1)
            {
				//find the snippet number	
				int i = 0;
				while (!isNumeric(line[i..i+1])) {
					i++;
				}
				
				//get the snippet number, strip the semicolon at the end
	        	snippetNumber = line[i..$-1];

				//now find the description	        	
	        	int j = 0;
				while (j < 20)
				{
					line = snippet.readln();
					index = indexOf(line, " * ");
				    if (index != -1)
				    {
						if (index == 1){
							snippetDescription = line[index+3..$];
						} else {
							snippetDescription = line[index+2..$];
						}
						break;
				    }
				    j++;
				}
				string tmp = padNumber(chop(snippetNumber)) ~ chop(snippetDescription);
				buffer ~= tmp;
				count++;
				break;
            }
    }
   	
	//close the file
	snippet.close();
	
	//sort the index
	sort(buffer);
	
	//now add the numbered index
		
	//if the index file exists, rename to .bak
	if (exists(INDEX_FILE)) {
		try
	    {
	        rename(INDEX_FILE, baseName(INDEX_FILE, ".txt")  ~ ".bak");
	    }
	    catch (FileException ex)
	    {
	        writeln("Error renaming " ~ INDEX_FILE);
	    }
	}
	
	//wite the buffer to the index file
	try
    {
    	auto file = File(INDEX_FILE, "w");
    	
    	//write the header
    	
    	file.writeln("Item # Description");
    	file.writeln("==== = ======================================================" ~ 
		                    "=======================================");
    	
		foreach (int i, lineOutput; buffer)
		{
	        file.writeln(padNumber(to!string(i+1)) ~ " " ~ lineOutput);
	        //file.writeln(to!string(i+1) ~ " " ~ lineOutput);
	    }
    }
    catch (FileException ex)
    {
        writeln("Error writing to " ~ INDEX_FILE);
    }
    
 }
private string padNumber(string line) {

	//find the first number	
	int i = 0;
	while (!isNumeric(line[i..i+1])) {
		i++;
	}

	//pad with leading spaces
	string numb = "   " ~ line[0..$];

	//keep the last 3 digits
	numb = numb[$-3..$];

	return numb;
	
}