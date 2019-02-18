module dlang.mod.file;

import std.stdio;

void main() {
	
	//writeln("Hello World.");
	
	stdFile();
}

void stdFile() {
	
	import std.file; //DirEntry

	DirEntry root;
	
	root = DirEntry(r"dub.json");
	writeln(root.name);
	
	root = DirEntry(r".\dub.json");
	writeln(root.name);
	
	root = DirEntry(r"..\dlang\dub.json");
	writeln(root.name);
	
	string exepath = thisExePath();
	writeln (exepath);
}