/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
*/

module dlang.modules.readln;

import std.stdio;
import std.process;
import std.string;
import std.conv;

void main()
{
	while (!stdin.eof) {

		writeln("");
		writeln("-----------------------------");
		writeln("Demo for readln console input");
		writeln("-----------------------------");
		writeln("(1) One");
		writeln("(2) Two");
		writeln("(3) Three");
		writeln("(C)lear Screen");
		writeln("(Q)uit");
		write(": ");

		string choice = strip(readln());
		
		switch (choice.toUpper) {
		case("1"):
			writeln("1 = One");
			break;
		case("2"):
			writeln("2 = Two");
			break;
		case("3"):
			writeln("3 = Three");
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

void clearScreen() {
    auto pipes = pipeProcess(["cmd","echo"], Redirect.stdin );
	scope(exit) wait(pipes.pid);
    pipes.stdin().writeln("cls");
	pipes.stdin.close;
}

