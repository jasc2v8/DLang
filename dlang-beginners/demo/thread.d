/*
 Programming_in_D by Ali Çehreli, page 596

*/

import std.stdio;
import std.parallelism;
import std.array;
import core.thread;
/* Prints the first letter of 'id' every half a second. It
* arbitrarily returns the value 1 to simulate functions that
* do calculations. This result will be used later in main. */
int anOperation(string id, int duration) {
	writefln("%s will take %s seconds", id, duration);
	foreach (i; 0 .. (duration * 2)) {
		Thread.sleep(500.msecs); /* half a second */
		write(id.front);
		stdout.flush();
	}
	return 1;
}

void main() {
	/* Construct a task object that will execute
	* anOperation(). The function parameters that are
	* specified here are passed to the task function as its
	* function parameters. */
	auto theTask = task!anOperation("theTask", 5);
	/* Start the task object */
	theTask.executeInNewThread();
	/* As 'theTask' continues executing, 'anOperation()' is
	* being called again, this time directly in main. */
	immutable result = anOperation("main's call", 3);
	/* At this point we are sure that the operation that has
	* been started directly from within main has been
	* completed, because it has been started by a regular
	* function call, not as a task. */
	/* On the other hand, it is not certain at this point
	* whether 'theTask' has completed its operations
	* yet. yieldForce() waits for the task to complete its
	* operations; it returns only when the task has been
	* completed. Its return value is the return value of
	* the task function, i.e. anOperation(). */
	immutable taskResult = theTask.yieldForce();
	writeln();
	writefln("All finished; the result is %s.", result + taskResult);
}