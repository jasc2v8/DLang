import std.stdio;

string globalVariable;

int main(string[] argv)
{
    writeln("in main");

	Example.staticVariable = 2;

	Tab.staticVariable = 4;

	Example e = new Example(6);

	int r1 = e.getPrivateVariable();
	writeln("main.r1=", r1);

	int r2 = Tab.getStaticVariable();
	writeln("main.r2=", r2);

	readln; //console pause

    return 0;
}

class Example : Tab {

	static int staticVariable;
	private int privateVariable;

	this(int passedVariable) {
		this.privateVariable = passedVariable;
		writeln("in Example class");
		writeln("Example.globalVariable=", globalVariable);
		writeln("Example.passedVariable=", passedVariable);
		writeln("Example.staticVariable=", staticVariable);
		privateVariable = 2;
	}

	public int getPrivateVariable() {
		privateVariable += 1;
		return privateVariable;
	}
}

class Tab {

	static int staticVariable;

	this() {
		writeln("in Tab class");
		globalVariable = "test";
		writeln("Tab.staticVariable=", staticVariable);
	}

	static int getStaticVariable() {
		int i = staticVariable;
		return staticVariable;
	}

}


