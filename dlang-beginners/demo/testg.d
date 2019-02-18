/*sdf
	This is a very brief demo of a very deep subject
*/
module dlang.modules.arrays; //008

import std.stdio;

void main() {

/* dynamic array */
	
	string[] d1 = ["a", "b", "c"];
	
	writeln("\nDynamic array declared with assigment:\n");
	
	foreach (s; d1) write(s, ", " );
	writeln();

/* dynamic array copy by appending */
		
	string[] d2;

	d2 ~= d1;

	writeln("\nDynamic array declared, then appended from another array:\n");
	
	foreach (s; d2) write(s, ", " );
	writeln();
	
/* dynamic array copy as duplicate */
		
	string[] d3;

	d3 = d1;

	writeln("\nDynamic array duplicate, sharing the same memory space:\n");
	
	write("d1: ");
	foreach (s; d1) write(s, ", " );
	writeln();
	
	write("d3: ");
	foreach (s; d3) write(s, ", " );
	writeln();
	
	d1[0]="X";
	write("d1 changed     : ");
	foreach (s; d1) write(s, ", " );
	writeln();
	
	write("d3 also changed: ");
	foreach (s; d3) write(s, ", " );
	writeln();
	
}

