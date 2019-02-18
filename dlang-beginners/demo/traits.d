
// https://dlang.org/phobos/std_traits.html

import std.stdio;
import std.traits;

void main() {

	string jim = "test";
	
	writeln ( fullyQualifiedName!(jim) ~ " = " ~ jim);

	writeln ( "moduleName="~moduleName!(jim));

	//writeln ( "packageName!packageName);
}