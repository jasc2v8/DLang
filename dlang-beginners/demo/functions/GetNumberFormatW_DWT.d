/*

Uses the DWT library to perform a number conversion to the locale defined in the OS

Used win32 API GetNumberFormatW from DTW WINAPI.d Line 2510

*/

module dlang.mod.getnumberformatw;

import std.stdio;
import core.stdc.locale;
//import core.stdc.stdio;

//extern(C) int printf(const(char*) format) nothrow @nogc;


void main() {

	wchar[24] formatted; //receives the formatted number strings up to 999 Tb
	//string formatted = "123456789012345678901234";
	
	uint strlen;       //the length of the formatted string
	uint dw = 0;
	int len = 10;
	
	import org.eclipse.swt.internal.win32.OS; //DWT library
	import org.eclipse.swt.internal.win32.WINAPI; //DWT library

	import std.string;
	import std.conv;
	
	//strlen = GetNumberFormatW(LOCALE_USER_DEFAULT, dw, StrToWCHARz ("1234567.89"), null, cast(wchar*)formatted, formatted.length);
	strlen = GetNumberFormatW(LOCALE_USER_DEFAULT, dw, StrToWCHARz ("1234567.89"), null, formatted.ptr, formatted.length);

	write("\nlength=", formatted.length);
	write("\nstrlen=", strlen);
	write("\nformatted=", to!string(formatted)); //prints garbage in buffer, but no exception
	
	wstring number;
	//no string number = formatted[0..strlen];
	//no string number = formatted.idup;
	writeln("");
	foreach (i; formatted) 	write(i);
	writeln("");
	for (int i; i < strlen; i++) write(formatted[i]);
	writeln("");
	for (int i; i < strlen-1; i++) number ~= formatted[i];
	write("[" ~ number ~ "]");

	number = formatted[0 .. strlen-1].idup;
	writeln("");
	write("[" ~ number ~ "]");

	writeln("\nThis is truely a number: " ~ number);
		
	//no string number = toStringz(formatted);
	//string number = fromStringz(formatted);


	//auto c = to!(wchar[])(formatted);
	//writeln(c); // "abcx"
	
	//write("\nGetNumberFormatW=", formatted); //core.exception.UnicodeException@src\rt\util\utf.d(402): illegal UTF-16 value
	//write("\nGetNumberFormatW1=", to!string(formatted)); //prints garbage in buffer, but no exception
	
	//write("\nGetNumberFormatW2=", to!string(chomp(formatted))); //still prints garbage in buffer, but no exception
	
	//src\app.d(53,44): Error: function org.eclipse.swt.internal.win32.OS.WCHARzToStr
	//(const(wchar*) pString, int _length = -1) is not callable using argument types
	//(wchar[24])
	//char[] ctemp = formatted;
	//auto temp  = WCHARzToStr(ctemp);
	
	//src\app.d(55,44): Error: function org.eclipse.swt.internal.win32.OS.WCHARzToStr
	//(const(wchar*) pString, int _length = -1) is not callable using argument types (wchar[24], long)

	//write( "\nGetNumberFormatW2=", WCHARzToStr(formatted, strlen) ); //
	
	
	//write("\nindex ", indexOf(",", formatted)); //-1 not found
	//write("\nindex ", indexOf(" ", formatted)); //-1 not found
	//write("\nindex ", indexOf("", formatted)); //-1 not found
	//write("\nindex ", indexOf(null, formatted)); //won't compile

}
