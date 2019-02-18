/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 
 
*/

module dlang.functions.isdirfilewild;

import std.file;
import std.stdio;
import std.string;
//import std.path;

void main() {

	writeln( _isDir( r"C:\Windows" ) );

	writeln( _isFile( r"C:\Windows\win.ini" ) );

	writeln( _isWild( r"C:\Windows\win.*" ) );

}

bool _isDir( string dir ) {
	if (dir=="") return false;
	bool result;
	try
	{
		if (isDir(dir)) result = true;
	} catch  (Exception e) {
		result = false;
	}
	return result;
}

bool _isFile( string file ) {
	if (file=="") return false;
	bool result;
	try
	{
		if ( isFile(file) ) result = true;
	} catch  (Exception e) {
		result = false;
	}
	return result;
}

bool _isWild( string fname ) {
	if (fname=="") return false;
	bool result;
	try
	{
		if ( indexOf(fname, "*") != -1 || indexOf(fname, "?") != -1 ) result = true;
	} catch  (Exception e) {
		result = false;
	}
	return result;
}
