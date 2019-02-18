/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 
 datetime is a demo of std.datetime
 
*/

module dlang.classes.changecase;

import std.stdio;

void main() {
	
	ChangeCase cc = new ChangeCase;
	
	writeln( "UPPER CASE   : " ~ cc.upper("hello world") );

	writeln( "lower case   : " ~ cc.lower("HELLO WORLD") );
	
	writeln( "Sentence case: " ~ cc.sentence("hello world") );

	writeln( "Title Case   : " ~ cc.title("hello world") );
	
}

class ChangeCase {

	import std.string;

	public:

		this() {
         //writeln("Object is being created");
	    }

	string upper( string s ) {
		return toUpper(s);
	}
	
	string lower( string s ) {
		return toLower(s);
	}
	
	string sentence( string s ) {
		//"The quick brown fox jumps over the lazy dog."
		return capitalize(s);
	}

	string title( string s ) {
		//"The Quick Brown Fox Jumps Over The Lazy Dog."
		
		for (int i; i < s.length; i++) {

			if (s[i..i+1] != " ") {
				count++;
			} else {
				count = 0;
			}
			
			if (count==1) {
				buff ~= capitalize(s[i..i+1]);
			} else {
				buff ~= s[i..i+1];
			}
			
		}
		
		return buff;
	}
	
	private:
   
		int count;
		string buff;		
}
