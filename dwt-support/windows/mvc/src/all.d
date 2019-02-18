/*
 * Copyright (C) 2017 by jasc2v8 at yahoo dot com
 * License: http://www.boost.org/LICENSE_1_0.txt
 *
 * Model, View, Controller (MVC) standalone app example 
 * This module imports all required packaged in one statement; import all
 *
 * Order of import statements per: https://wiki.dlang.org/Order_of_import_statements
*/

module all;

public import core.stdc.stdlib;	//clang for exit
public import std.stdio;		//writeln for debugging

//swt.all increases the size of a release version, but much easier to manage!
//x86 build before upx adds 412Kb, after upx adds only 110Kb
public import org.eclipse.swt.all;

//public import java.lang.all; //very nice D binding to java utilies!

public import gui;

const string TITLE = "Model, View, Controller (MVC) Standalone App Example";
