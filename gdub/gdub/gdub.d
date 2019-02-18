/*

Copyright (C) 2017 by jasc2v8 at yahoo dot com
License: https://opensource.org/licenses/MIT
Version: 1.0.0
Description: gDub is a GUI for DUB to List, Build, and Run Individual D files
Usage: See helpText below
Notes: Windows only, TODO: modify spawnProcess on line 222 for Posix

*/

module gdub;

import std.algorithm.sorting;
import std.conv;
import std.exception;
import std.file;
import std.format;
import std.path;
import std.process;
import std.string;
import std.stdio;

import org.eclipse.swt.all;
import java.lang.all;

enum srcDir          = "src";
enum sourceDir       = "source";
enum srcDirBackup    = srcDir ~ "_bak";
enum sourceDirBackup = sourceDir ~ "_bak";

enum scaleW = .50, scaleH = .75;
enum SUCCESS=0, ERROR=1;

enum VERSION="1.0.0";

enum shellTitle = "gDub";
enum copyRightText = "Copyright \u00A9 2017 by jasc2v8 at yahoo dot com";
enum aboutText = shellTitle ~ " " ~ VERSION ~ " " ~ copyRightText ~
    "\ngDub is a GUI for DUB to List, Build, and Run Individual D files";

enum string helpText = aboutText ~ "\n" ~ r"
File:   Choose Folder - select a folder of *.d files
        Choose File   - select an individual *.d file
        Open File     - open the selected file in the system editor for *.d files
        Exit          - exit

DUB:    Run File      - build and run the selected file
        Reset DUB     - use after changing DUB dependency (removes .dub and dub.selections.json)
        Force Rebuild - use DUB --force

Help:   View Help     - show this help text
        About         - show version

Usage:  gdub [file | folder [./src]]
        Select file from list then Double-Click or ENTER to build and run file";

Shell shell;
Display display;
SashForm sashForm;
Text statusBox, textBox;
List listBox;

Font myFont;

bool dubForce = true;
string appType;

void main(string[] args) {
	
	buildShell();
	setShellSize(scaleW, scaleH);
	centerShell();
    shell.open();

	//if a file or folder is specified on command line, and it exists, then use it
	if (args.length == 2) {
		if (args[1].exists) {
			if (args[1].isFile) {
				string file;
				listFiles(file);
			}
			if (args[1].isDir) {
				string folder = args[1];
				listFiles(folder);
			}
		}
	} else {
		//if no file or folder is specified on the command line, use cwd
		listFiles(getcwd());
	}

    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }

    display.dispose();
}

string getSelection(List list) {
	string[] selection = list.getSelection();
	if (selection.length == 0) return "";
	return selection[0];
}

void openFile(string file) {
	if (file == "") return;
	string saveStatus = statusBox.getText();
	statusBox.setText("Open File: " ~ file ~ " (Close External Editor to Continue)");
	display.update();
	doPipeShell(file);
	statusBox.setText(saveStatus);
}

void chooseFolder() {
	DirectoryDialog dialog = new DirectoryDialog(shell);
	dialog.setMessage("Choose a Directory to scan for D files");
    dialog.setFilterPath(getcwd());
    string selection = dialog.open();
    if (selection is null) return;
	int fileCount = listFiles(selection);
	statusBox.setText(format("Folder selected: %s, file count: %s", selection, fileCount));
}

void chooseFile() {
    FileDialog dialog = new FileDialog(shell, SWT.OPEN);
    dialog.setFilterNames (["D", "All Files (*.*)"]);
    dialog.setFilterExtensions (["*.d", "*.*"]);
    dialog.setFilterPath(getcwd());
    string selection = dialog.open();
    if (selection is null) return;
	statusBox.setText("File selected: " ~ selection);
	string[] file;
	file ~= getPath(selection);
	listBox.setItems(file);
}

string getPath( string file) {
	//if file is in the cwd path, then return relative, else absolute path
	if (std.string.indexOf(file.absolutePath.dirName, getcwd()) != -1) {
		return file.relativePath;
	} else {
		return file.absolutePath;
	}
}

int listFiles(string sourceFolder) {
	
	string[] fileList = null;
	listBox.removeAll();
	textBox.setText("");

	int fileCount;

	foreach (string file; sourceFolder.dirEntries(SpanMode.shallow))
	{
		if (file.isFile() && file.extension == ".d") {
			fileList ~= getPath(file);
			fileCount++;
        }
    }

	fileList.sort();
	listBox.setItems (fileList);
	return fileCount;
}

void buildFile(string sourceFile) {

	if (sourceFile == "") return;

	statusBox.setText(appType ~ " App Build and Run: " ~ sourceFile);
	display.update();

	int rtn;	

	BusyIndicator.showWhile(display, new class Runnable {
		override public void run() {
			rtn = doBuild(sourceFile);
		}
	});

	if (rtn == ERROR) {
		statusBox.setText("ERROR Building: " ~ sourceFile);
	} else {
		statusBox.setText("Finished: " ~ sourceFile);
	}

	shell.forceActive(); //bring window to front
}

int doBuild(string sourceFile) {

	int rtn = SUCCESS;
	
	if (srcDir.exists && !srcDirBackup.exists) {
		std.file.rename (srcDir, srcDirBackup);
	}

	if (sourceDir.exists && !sourceDirBackup.exists) {
		std.file.rename (sourceDir, sourceDirBackup);
	}

	//remove the src and source folders and all files
	if (srcDir.exists) rmdirRecurse(srcDir);
	if (sourceDir.exists) rmdirRecurse(sourceDir);

	//create a new src folder
	mkdir(srcDir);

	//copy selected file to src folder
	copy(sourceFile, buildPath(srcDir, sourceFile.baseName));
	
	//form dub cmd
    string run;
	string cmd = "dub --build=release-nobounds";
	if (dubForce) cmd ~= " --force";

	//build and run the selected file that has been copied to src
    
	if (appType == "GUI" ) {
    
        cmd ~= " --config=gui";
		string errorMessage = doPipeShell(cmd);
        
	} else {
    
        cmd ~= " --config=console" ~ "\n";

        version (Windows) {
            cmd ~= "PAUSE";
            std.file.write ("console_app.bat", cmd);
            auto pid = spawnProcess("console_app.bat");
    		rtn = wait(pid);
        }

        version (Posix) {
            cmd ~= `read -n 1 -p "Press any key to continue . . . !"`;        
            std.file.write ("console_app.bat", cmd);
            auto pid = spawnProcess(["bash", "./console_app.bat"]);
    		rtn = wait(pid);
       }       
 	}
	return rtn;
}

string doPipeShell(string cmd) {

	string outputBuffer;

	auto pipes = pipeShell(cmd, Redirect.stdout | Redirect.stderr, null, Config.suppressConsole);

	scope(exit) {
	    wait(pipes.pid);
	}

	foreach (line; pipes.stdout.byLine) {
	    outputBuffer ~= to!string(line) ~ "\n";
	}

	foreach (line; pipes.stderr.byLine) {
	    outputBuffer ~= to!string(line) ~ "\n";
	}

	return outputBuffer;
}

void viewFile(string fileName) {
	textBox.setText("");
	string utf8Data;
	try
    {
        utf8Data  = readText(fileName);
		textBox.append(utf8Data);
    }
    catch (FileException e)
    {
        // Handle errors
    }
	textBox.setSelection(0);

	if (std.string.indexOf(utf8Data, "import org.eclipse.swt.")==-1) {
		appType = "CONSOLE";
	} else {
		appType = "GUI";
	}
}

void setShellSize(float scaleWidth, float scaleHeight) {
	Point size = shell.computeSize(SWT.DEFAULT, SWT.DEFAULT);
	Rectangle monitorArea = shell.getMonitor().getClientArea();
	float W = monitorArea.width * scaleWidth;
	float H = monitorArea.height * scaleHeight;
	shell.setSize(W.to!int, H.to!int);
}

void centerShell() {

    Rectangle bounds = shell.getMonitor().getBounds();
    Rectangle rect = shell.getBounds();
    int x = bounds.x + (bounds.width - rect.width) / 2;
    int y = bounds.y + (bounds.height - rect.height) / 2;
    shell.setLocation(x, y);
}

void buildShell() {

    display = new Display();

    shell = new Shell(display);
	shell.setBackground(display.getSystemColor(SWT.COLOR_LIST_BACKGROUND));
	shell.setText(shellTitle);
	shell.setLayout(new GridLayout());

	//menu bar
	Menu menuBar = new Menu(shell, SWT.BAR);

	//file menu
	MenuItem fileMenuHeader = new MenuItem(menuBar, SWT.CASCADE);
	fileMenuHeader.setText("&File");

	Menu fileMenu = new Menu(shell, SWT.DROP_DOWN);
	fileMenuHeader.setMenu(fileMenu);

	MenuItem filechooseFolderItem = new MenuItem(fileMenu, SWT.PUSH);
	filechooseFolderItem.setText("Choose F&older");
	filechooseFolderItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			chooseFolder();
		}
	});

	MenuItem chooseFileItem = new MenuItem(fileMenu, SWT.PUSH);
	chooseFileItem.setText("Choose F&ile");
	chooseFileItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			chooseFile();
		}
	});

	MenuItem fileOpenFileItem = new MenuItem(fileMenu, SWT.PUSH);
	fileOpenFileItem.setText("&Open File");
	fileOpenFileItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			openFile(getSelection(listBox));
		}
	});

	MenuItem fileExitItem = new MenuItem(fileMenu, SWT.PUSH);
	fileExitItem.setText("E&xit");
	fileExitItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			closeDisplay();
		}
	});

	//DUB menu
	MenuItem dubMenuHeader = new MenuItem(menuBar, SWT.CASCADE);
	dubMenuHeader.setText("&DUB");

	Menu dubMenu = new Menu(shell, SWT.DROP_DOWN);
	dubMenuHeader.setMenu(dubMenu);

	MenuItem dubRunItem = new MenuItem(dubMenu, SWT.PUSH);
	dubRunItem.setText("R&un File");
	dubRunItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			buildFile(getSelection(listBox));
		}
	});

	MenuItem dubResetItem = new MenuItem(dubMenu, SWT.PUSH);
	dubResetItem.setText("&Reset DUB");
	dubResetItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
        	try
            {
                if (".dub".exists) rmdirRecurse(".dub");
                if ("dub.selections.json".exists) std.file.remove("dub.selections.json");
            }
            catch (FileException e)
            {
                statusBox.setText("ERROR DUB Reset Failed: Run as Admin");
                return;
            }
			statusBox.setText("DUB Reset Finished: removed .dub and dub.selections.json");
		}
	});

	MenuItem dubForceItem = new MenuItem(dubMenu, SWT.CHECK);
	dubForceItem.setText("&Force Rebuild");
	dubForceItem.setSelection(dubForce);
	dubForceItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			dubForce = !dubForce;
		}
	});

	//help menu
	MenuItem helpMenuHeader = new MenuItem(menuBar, SWT.CASCADE);
	helpMenuHeader.setText("&Help");

	Menu helpMenu = new Menu(shell, SWT.DROP_DOWN);
	helpMenuHeader.setMenu(helpMenu);

	MenuItem viewHelpItem = new MenuItem(helpMenu, SWT.PUSH);
	viewHelpItem.setText("&View Help");
	viewHelpItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			textBox.setText(helpText);
		}
	});

	MenuItem helpAboutItem = new MenuItem(helpMenu, SWT.PUSH);
	helpAboutItem.setText("&About");
	helpAboutItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			textBox.setText(aboutText);
		}
	});

	//show the menu bar
	shell.setMenuBar(menuBar);

	//now build the Widgets

	myFont = new Font(display, "Courier New", 11, SWT.NORMAL);

	statusBox = new Text(shell, SWT.SINGLE | SWT.BORDER | SWT.READ_ONLY);
	statusBox.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, false));

	sashForm = new SashForm(shell, SWT.VERTICAL);
	sashForm.setLayoutData(new GridData (SWT.FILL, SWT.FILL, true, true));

	listBox = new List (sashForm, SWT.SINGLE | SWT.BORDER | SWT.H_SCROLL | SWT.V_SCROLL);
	listBox.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
	listBox.setFont(myFont);

	textBox = new Text(sashForm, 
		SWT.MULTI | SWT.BORDER | SWT.READ_ONLY | SWT.H_SCROLL | SWT.V_SCROLL);
	textBox.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
	textBox.setFont(myFont);

	//click listener
	listBox.addSelectionListener(new class SelectionAdapter {
		override public void widgetSelected(SelectionEvent e)
		{
			viewFile(getSelection(listBox));
			statusBox.setText(appType ~ " App Selected: " ~ getSelection(listBox));
		}
	});

	//double-click listener
	listBox.addSelectionListener(new class SelectionAdapter {
		override public void widgetDefaultSelected(SelectionEvent e)
		{
			buildFile(getSelection(listBox));
		}
	});

	//ENTER key listener
	listBox.addKeyListener(new class KeyAdapter	{
		override public void keyPressed(KeyEvent e) 
		{
			if(e.keyCode == SWT.CR || e.keyCode == SWT.KEYPAD_CR) {
				buildFile(getSelection(listBox));
			}
		}
	});

    //shell close listener
    shell.addListener(SWT.Close, new class Listener {
		public void handleEvent(Event e)
		{
			e.doit = false;
			closeDisplay();
		}
	});
}

void closeDisplay() {
	//put any font and image dispose statements here
	myFont.dispose();
	display.close();
}
