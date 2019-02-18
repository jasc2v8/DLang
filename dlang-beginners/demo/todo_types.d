/*

char[] to string and back;
https://en.wikibooks.org/wiki/D_(The_Programming_Language)/d2/Strings_and_Dynamic_Arrays


variables
cast

string is an alias for immutable(char)[]
The elements of a string can never be altered
dup returns a mutable copy of a string (not const, not immutable) 
idup returns an immutable copy
You can append to a string.
Use a char[] if you have to modify individual characters.

D strings are char[]

string s = "Hello";
immutable means the string characters cannot be changed
s[1..2] = "a" //NG (no good) trying to change a char in the string, Error: slice s[1..2] is not mutable
However, you can append to the string;
s = s ~ " World";
writeln(s); // "Hello World"


*/

module dlang.mod.types;

import std.stdio;

void main() {

	immutable(char)[] s = "hello";
}

