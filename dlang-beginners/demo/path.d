import std.stdio;


void main() {
	//writeln("Hello World.");
	
	//get the package_name
	
	import std.file; //DirEntry

	DirEntry root;
	
	root = DirEntry(r"dub.json");
	root = DirEntry(r".\dub.json");
	root = DirEntry(r"..\build_dmd\dub.json");
	//writeln(root.name);
	
	writeln ( getcwd() );
	
	string exepath = thisExePath();
	writeln (exepath);								//D:\DEV\Work\work-d\build_dmd\build_dmd.exe
	
	import std.path;
	
	writeln(dirSeparator);							//\

	writeln(pathSeparator);							//;
	
	writeln( driveName(exepath) );					//D:
	writeln( dirName(exepath) );					//D:\DEV\Work\work-d\build_dmd
	writeln( baseName(exepath) );					//build_dmd.exe
	writeln( extension(exepath) );					//.exe
	writeln( stripExtension( dirName(exepath) ));	//D:\DEV\Work\work-d\build_dmd
	
	writeln( absolutePath( "dub.json" )); //D:\DEV\Work\work-d\build_dmd\dub.json
	
	writeln(relativePath( r"D:\DEV\Work\work-d\build_dmd\src\app.d" )); //src\app.d
	writeln(relativePath( r"D:\DEV\Work\work-d\build_dmd" )); //.
	writeln(relativePath( r"D:\DEV\Work\work-d" )); //..
	writeln(relativePath( r"D:\DEV\Work" )); //..\..
	writeln(relativePath( r"D:\DEV" )); //..\..\..
	writeln(relativePath( r"D:\" )); //..\..\..\..
	writeln(relativePath( r"D:" )); //D:
	writeln(relativePath( r"D" )); //D
	writeln(relativePath( "[" ~ r"" ~ "]")); //[]
	
	writeln( baseName( stripExtension( dirName(exepath) )));	//build_dmd	
}

