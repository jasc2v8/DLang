/*

new
	https://dlang.org/d-floating-point.html
		 6 decimal digits for float  24 bit
		15 decimal digits for double 53 bit
	
	IEE744:
		7 decimal digits for decimal32
		16 decimal digits for decimal64
		34 decimal digits for decimal128

	//format:  %[flag][min width][precision][length modifier][conversion specifier]

	//format:  %[flag][min width][precision][length modifier][conversion specifier]

	//format examples:

	float f =  12345678.12;
	writeln( "f=" ~ format("%12.2f", f ) );			//f= 12345678.00
	writeln( "f=" ~ format("%20.4f", f ) );
	writeln( "f=" ~ format("%020.4f", f ) );
	writeln( "f=" ~ format("% 20.4f", f ) );
	writeln( "f=" ~ format("%*.*f", 12, 2, f ) );		//f= 12345678.00
	writeln(to!string(f)); //uses "%g"

	//write just takes each argument, converts it to a string, and outputs it:
    write(1, " <- one");

	//writef treats the first string as a format-specifier (much like C's printf), and uses it to format the remaining arguments:
    writef("%d %s", 2, "<- two");

	//versions ending with "ln" aappend a newline at the end of printing.
    writeln(3, " <- three");
    writefln("%d %s", 4, "<- four");
    writefln("%s", 5, "<- five"); //missing a format-specifier

    //writefln("%f", 6, "<- six"); //FormatException, can't convert int 6 to float %f
    writefln("%f %s", 6., "<- six float"); //now 6 is a float
    writefln("%s %s", 6., "<- six string"); //%s will print all types as string, less decimals
    writefln("%06.2f, %s", 66., "<- sixty-six"); //6 total chars including the period, pad leading zeros, 2 decimal points
    
    //there is no format-specifier to print commas
    //writefln("%,d %s", 1000, "<- one thousand"); //FormatException, can't process the comma
    
    //setting the local doesn't add commas
    //setlocale(LC_NUMERIC, "en_US");
    //float n = 1000.;
    //writefln("Set Locale: %f", n);
	
    //setlocale(LC_ALL, "");
    //writefln("%d", 1123456789);
    
	//import core.stdc.stdio : printf;
    import std.string;
    //char[] hi = "hello world";
	//char[] slice = hi[0 .. 5];
	printf("\nhello");
	printf(toStringz("\nhello"));


	import std.c.stdio;
	import std.c.stdlib;

	//NG printf("\n%'d primes", 1001); //does NOT support the apostrophe to print commas

	printf("\n%10.3lf\n", 13000.26);
	
	printfcomma(1001);
	
	//OK char *c = cast(char*) malloc(4);
	//char *c = cast(char*) = "1001";
	
	//NG printf("string = %s\n", i);
	//NG printf("string = %s\n", s);
	//NG printf("string = %s\n", toStringz(s));

    //printf("printf2 %,d\n", 1123456789); //comma not in the D binding to the C library

*/

module dlang.mod.format;

import std.stdio;
import std.string;
import std.conv;

void main() {
	
	formatInt();
	formatLong();
	formatFloat();
	formatDouble();

}

void formatInt() {
	
	writeln("\nFormat int:");
	
	write("maximum value         : " , int.max, "\n");
	//NA write("minimum normal value  : " , int.min_normal, "\n");
	//NA write("mantissa binary digits: " , int.mant_dig, "\n");
	
	int i = -1_234_567_890; //max int = 1_234_567_890
	
	write("1: ", i, "\n");
	
	write( text("2: ", i, "\n") ); //uses %s		

	write( format("3: %s \n", i) );		

	write( format("4: %d \n", i) );		

	write( format("5: %020d \n", i) ); //pad with leading zeros
		
	write( format("6: % 20d \n", i) ); //pad with leading spaces		
	
}

void formatLong() {
	
	writeln("\nFormat long:");
	
	write("maximum value         : " , long.max, "\n");
	//NA write("minimum normal value  : " , long.min_normal, "\n");
	//NA write("mantissa binary digits: " , long.mant_dig, "\n");
	
	long x = +1_234_567_890_123_456_789; //max long
	
	write("1: ", x, "\n");
	
	write( text("2: ", x, "\n") ); //uses %s		

	write( format("3: %s \n", x) );		

	write( format("4: %d \n", x) );		

	write( format("5: %040d \n", x) ); //pad with leading zeros
		
	write( format("6: % 40d \n", x) ); //pad with leading spaces		
	
}

void formatFloat() {
	
	writeln("\nFormat float:");
	
	write("maximum value         : " , float.max, "\n");
	write("minimum normal value  : " , float.min_normal, "\n");
	write("mantissa binary digits: " , float.mant_dig, "\n");

	float x	= 1.23456; // float max is 6 decimal digits = 3.40282e+38
	
	write("1: ", x, "\n");
	
	write( text("2: ", x, "\n") ); //uses %s		

	write( format("3: %s \n", x) );		

	write( format("4: %e \n", x) );	//1.6e truncate *8.99 to *.8 (capital E returns E+XX)	

	write( format("5: %f \n", x) ); //1.6 round *8.99 to *9.00	(captial F returns blanks)	

	write( format("6: %g \n", x) ); //1.5e no decimals (capital G returns blanks)		

	write( format("7: %040.4f \n", x) ); //pad with leading zeros
		
	write( format("8: % 40.4f \n", x) ); //pad with leading spaces		
	
}

void formatDouble() {
	
	writeln("\nFormat double:");
	
	write("maximum value         : " , double.max, "\n");
	write("minimum normal value  : " , double.min_normal, "\n");
	write("mantissa binary digits: " , double.mant_dig, "\n");

	double x = 1234567890123.45; // max is 15 decimal digits = 1.79769e+308
	
	write("1: ", x, "\n");
	
	write( text("2: ", x, "\n") ); //uses %s		

	write( format("3: %s \n", x) );		

	write( format("4: %e \n", x) );	//1.6e truncate *8.99 to *.8 (capital E returns E+XX)	

	write( format("5: %f \n", x) ); //1.6 round *8.99 to *9.00	(captial F returns blanks)	

	write( format("6: %g \n", x) ); //1.5e no decimals (capital G returns blanks)		

	write( format("7: %020.2f \n", x) ); //pad with leading zeros, 15 decimal digits max
		
	write( format("8: % 20.6f \n", x) ); //pad with leading spaces, 15 decimal digits max		
	
}
