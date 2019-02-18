
//https://dlang.org/spec/function.html#variadic

import std.stdio;
import std.traits;
import core.vararg;

void main() {
	
	string jim = "vararg test";

	debug writeln( fullyQualifiedName!(jim) ~ " = " ~ jim);  //app.main.jim = vararg test
	
	logName( jim );
	
}

void logName( ... ) {
	
	string var = va_arg!(string)(_argptr);
	
	writeln( fullyQualifiedName!(var) ~ " = " ~ var);  //app.logName.var = vararg test
}

