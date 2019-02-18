/*
	leave as an import, or make this a proper Class?

*/

import stdio;

void say(string message) {
	writeln(message);
}
	
void sayErr(string message) {
	stderr.writeln(message);
}
	
void debugWriteArray(string name, string[] array) {
	int count;
	foreach (a; array) {
		writefln("%s[%s]=%s", name, count, array[count]);
		count++;
	}
