/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 
*/

module dlang.classes.pathsplitter;

import std.stdio;

void main() {
	
	PathSplitter src = new PathSplitter("dub.json");
	
	writePath(src);
	
	src.Path = r"C:\Windows\System32\ping.exe"; 

	writePath(src);
	
}

void writePath(PathSplitter path) {

	writeln();
	
	writeln( "path.Path : " ~ path.Path() );
	writeln( "path.Dir  : " ~ path.Dir() );
	writeln( "path.Base : " ~ path.Base() );
	writeln( "path.File : " ~ path.File() );
	writeln( "path.Ext  : " ~ path.Ext() );
	
}

class PathSplitter {
	
	import std.path;
	
	private:
		string _path;
		
	public:
		this(string path)	{_path = absolutePath(path);}
		string Drive()		{return driveName(_path);}
		string Path()		{return _path;}
		string Dir()		{return dirName(_path);}
		string Base()		{return baseName(_path);}
		string File()		{return stripExtension(baseName(_path));}
		string Ext()		{return extension(_path);}
		
		void Path(string s) {
			_path = s;
		}
}
