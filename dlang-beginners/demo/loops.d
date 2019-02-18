
module dlang.mod.loops;

import std.stdio;
import std.conv; //text

void main() {

	
	//
	writeln("for loop:");

	for (int i; i<3; i++) {
		writeln( text("i=", i) );
	}
	
	writeln("foreach loop:");
	
	foreach (j; 0..3) {
		writeln( "j=", j );
	}	

	//
	writeln("while loop:");
	
	int k=0;
	int z=3;

	while (k < z) {
		writefln("count is %s of %s ", k, z);
		k++;
	}
	
	//
	writeln("do while loop:");
	
	int l;
	
	do {
	    write("\nl=",l);
	    l++;
	} while (l<3);
}
