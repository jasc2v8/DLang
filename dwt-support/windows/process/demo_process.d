/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
*/

module main;

import std.stdio;
import std.process;
import std.string;
import std.conv;

void main()
{
	for(;;) {

		writeln("");
		writeln("------------------------------");
		writeln("Demo for std.process functions");
		writeln("------------------------------");
		writeln("(1)demoExecuteShell");
		writeln("(2)demoEscapeShellCommand");
		writeln("(3)demoPipeShell");
		writeln("(4)demoRunProcess");
		writeln("(5)demoCopyCmd");
		writeln("(C)lear Screen");
		writeln("(Q)uit");
		write(": ");

		string choice = strip(readln());
		
		switch (choice.toUpper) {
		case("1"):
			writeln("demoExecuteShell");
			demoExecuteShell();
			break;
		case("2"):
			writeln("demoEscapeShellCommand");
			demoEscapeShellCommand();
			break;
		case("3"):
			writeln("demoPipeShell");
			demoPipeShell(r"dir ..\");
			break;
		case("4"):
			writeln("demoRunProcess");
			runProcess(["cmd", "/C", "dir", "/S", r"..\"]);
			break;
		case("5"):
			writeln("demoCopyCmd");
			demoCopyCmd(r"demo_process.d", r"demo_process.bak");
			break;
		case("C"):
			clearScreen();
			break;
		case("Q"):
			return;
		default:
			continue;
		}
	}
}

void demoPipeShell(string cmd) {

	auto pipes = pipeShell(cmd, Redirect.stdout | Redirect.stderr, null, Config.suppressConsole);

    scope(exit) {
        wait(pipes.pid);
    }

	foreach (line; pipes.stdout.byLine) {
	    writeln(to!string(line));	
	}

	foreach (line; pipes.stderr.byLine) {
	    writeln(to!string(line));	
	}
}

void runProcess(string[] args) {

	//writes stdout and stderr to the console as the process executes
	
	auto pipes = pipeProcess(args[], Redirect.stdout | Redirect.stderr, null, Config.suppressConsole);

    scope(exit) {
        wait(pipes.pid);
    }

	foreach (line; pipes.stdout.byLine) {
	    writeln(to!string(line));	
	}

	foreach (line; pipes.stderr.byLine) {
	    writeln(to!string(line));	
	}
}

void demoExecuteShell()
{

	//auto cmd = executeShell(r"dir > dir.txt"); //no cmd.output

	auto cmd = executeShell(r"dir ..\");

	writeln("status: " ~ to!string(cmd.status)); //DOS status 0 = success
	
	writeln("output: " ~ cmd.output); //after cmd ends
	
}

void demoEscapeShellCommand() {
	
	auto cmd = executeShell(escapeShellCommand("cmd", "/C", "dir", r"..\"));

	writeln("status: " ~ to!string(cmd.status)); //DOS status 0 = success
	
	writeln("output: " ~ cmd.output); //after cmd ends
	
}

void demoCopyCmd(string source, string target) {

	if ((source == "") | (target == "")) return;
	
	writeln("Copying " ~ source ~ ", to " ~ target);

	runProcess(["cmd", "/C", "copy", "/Y", source, target]);
	
}

void clearScreen() {
    auto pipes = pipeProcess(["cmd","echo"], Redirect.stdin );
	scope(exit) wait(pipes.pid);
    pipes.stdin().writeln("cls");
	pipes.stdin.close;
}

