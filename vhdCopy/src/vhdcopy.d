/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: https://opensource.org/licenses/MIT
 
 Version: 2.0.0 simplified menu
 
 Vbox tools is a Gui wrapper for VboxManage.exe to copy vhd and set GUUID.
    1. Copy virtual disks using D language buffered stdio.copy
    2. Set the virtual disk UUID using VBManage.exe 
 
 A cloned disk gets registered with the Virtual Media Manager
 This can create GUUID conflicts
 A copied disk must be manually added to the VM, which registers with the VMM
 
*/

module vhdCopy;

import std.stdio;
import std.conv;

import std.array;
import std.concurrency;
import std.file;
import std.path;
import std.process;
import std.range;
import std.string;
import std.algorithm;
import std.parallelism;

import core.time;
import std.datetime : StopWatch;

import org.eclipse.swt.all;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.custom.BusyIndicator;
import java.lang.all; //.Thread, .util

//windows version only, change to your environment
enum string VBManage32 = r"C:\Program Files (x86)\Oracle\VirtualBox\VboxManage.exe";
enum string VBManage64 = r"C:\Program Files\Oracle\VirtualBox\VboxManage.exe";

//shared memory between the gui process and the thread
//__gshared bool jobCancel = false, jobDone = true;
//per the D wiki, __gshared is discouraged, except for C bindings
shared bool jobCancel = false, jobDone = true;

string file, sourceFile, targetFile;

Display display;
Shell shell;
Text textBox;

ImageData id;
Image image;

string VBManage = null;

enum ncols=1;

void main()
{
	
    buildShell();

    shell.open();
   
	if (exists(VBManage32)) {
    	VBManage = VBManage32;
    } else if (exists(VBManage64)) {
    	VBManage = VBManage64;  	
    } else {
//    	textBox.setText("vhdcopy ERROR VboxManage.exe not found, close window to exit");
    }
    
    // if (VBManage !is null) {
		//showHelp();
    // }

    while (!shell.isDisposed())
    {
        if (!display.readAndDispatch())
            display.sleep();
    }

    display.dispose();
}

void displayStatus(Display display, string text) {
	if (display.isDisposed()) return;
	display.syncExec(new class Runnable {
		public void run() {
		    if (textBox.isDisposed()) return;
		        textBox.append(text);
	        }
	});
}

string getPeek(StopWatch sw) {

	int minutes;
	int seconds;
    short msecs;
    string peek;

	Duration dur = to!Duration(sw.peek());
	    
    dur.split!("minutes", "seconds", "msecs")(minutes, seconds, msecs);

	if (minutes == 1) {
		peek = to!string(minutes) ~ " minute, " ~ to!string(seconds) ~ " seconds";
	} else if (minutes > 0) {
		peek = to!string(minutes) ~ " minutes, " ~ to!string(seconds) ~ " seconds";
	} else if (seconds == 1) {
		peek = to!string(seconds) ~ " second";		
	} else if (seconds > 0) {
		peek = to!string(seconds) ~ " seconds";		
	} else {
		peek = "less than 1 second";				
	}
	
	return peek;
}

void doCopy(Display display, string sourceFile, string targetFile) {
	
	//limit to 1 thread
	if (!jobDone) return;

	//if blank exit
	if ((sourceFile == "") | (targetFile == "")) return;
	
	textBox.append("Copy: " ~ sourceFile ~ " to: " ~ targetFile ~ Text.DELIMITER);

	//set flags
	jobCancel = false;
	jobDone = false;
	
    Runnable longJob = new class Runnable {

        public void run() {

	        Thread thread = new Thread({
	
				displayStatus(display, "Copy started" ~ Text.DELIMITER);
				
				auto sourceF = File(sourceFile, "rb");
				auto targetF = File(targetFile, "wb");
				
				enum bufferSize = 4096*16;
				
				long bufferCount = 0;
				long statusCount = 0;

				auto f = DirEntry(sourceFile);
				float totalBytes = f.size * 1.0;
				
				StopWatch sw;
				
				sw.start();
									
				try
				{
					while (!sourceF.eof)
					{
						auto buffer = sourceF.rawRead(new ubyte[bufferSize]);
						targetF.rawWrite(buffer);
						++bufferCount;
						++statusCount;
						
						if (jobCancel) break;

						if (statusCount > 1024*8) {
						
							float c = bufferCount * bufferSize * 1.0;

							displayStatus(display, 
								"Copied: " ~ toXbytes(c) ~ 
								" of " ~ toXbytes(totalBytes) ~
								", in " ~ getPeek(sw) ~ Text.DELIMITER);
								
							statusCount = 0;
						}
					}
				
				}
				catch (Exception e)
				{
					textBox.append("\nError copying disk!");
					sourceF.close();
					targetF.close();
					if (exists(targetFile)) remove(targetFile);
				}

				sw.stop();

				if (jobCancel) {
					
					//inform user
					displayStatus(display, "Copy Cancelled!" ~ Text.DELIMITER);

					//perform cleanup
					sourceF.close();
					targetF.close();
					if (exists(targetFile)) remove(targetFile);
					targetFile = "";
					
					//flag done
					jobDone = true;
					
				} else {

					float byteCount;
						
					if (bufferCount <=1) {
						byteCount = totalBytes;
					} else {
						byteCount = bufferCount*bufferSize;
					}

					displayStatus(display,
							"Copy finished, bytes copied: " ~
							toXbytes(byteCount) ~ 
							", in " ~ getPeek(sw) ~ 
							Text.DELIMITER ~ Text.DELIMITER);
					
						sourceF.close();
						targetF.close();

				}
	
				//flag done
				jobDone = true;
				
				// wake up UI thread in case it is in a modal loop awaiting thread termination
				display.wake();
			
            }); //thread
            thread.start();

			//loop until jobDone
            while (!jobDone && !shell.isDisposed()) {
				if (!display.readAndDispatch()) display.sleep();
			}
            
        } //run
        
    };//Runnable
    
    //start the runnable with or without the busy indicator
    BusyIndicator.showWhile(display, longJob);
    //without: longJob.run();
    
    //reset flags for next run
    jobDone = true;
    jobCancel = false;
    
}

string toXbytes(float d) {
	
	enum ulong Tb = 10^^12;
	enum ulong Gb = 10^^9;
	enum ulong Mb = 10^^6;
	enum ulong Kb = 10^^3;
	
	float f;
	string xB;
	
	if (d > Tb) {
		xB = " Tb"; f = d / Tb;
	} else if (d > Gb) {
		xB = " Gb"; f = d / Gb;
	} else if (d > Mb) {
		xB = " Mb"; f = d / Mb;
	} else if (d > Kb) {
		xB = " Kb"; f = d / Kb;
	} else {
		xB = " bytes";
		f = d;
	}
	
	return format("%3.2f" ~ xB, f);
	
}
	
void setUUID()
{
	
	if ((sourceFile == "") && (targetFile == "")) return;	
	
	if (targetFile != "") sourceFile = targetFile;
	
	runProcess([VBManage, "internalcommands", "sethduuid", sourceFile]);

}

void runProcess(string[] args) {

	auto pipes = pipeProcess(args[], Redirect.stdout | Redirect.stderr, null, Config.suppressConsole);

    scope(exit) {
        wait(pipes.pid);
    }

	foreach (line; pipes.stdout.byLine) {
	    textBox.setText(format("%s", line));	
	}

	foreach (line; pipes.stderr.byLine) {
	    textBox.setText(format("%s", line));	
	}
}

void doSaveAs() {

	if (sourceFile == "") {
	  	showHelp();
    	return;
	}
	
	targetFile = sourceFile.stripExtension ~ "_copy" ~ sourceFile.extension;
	
	//save as file
    FileDialog dialog = new FileDialog(shell, SWT.SAVE);
    dialog.setFilterNames (["VHD", "VDI", "VMDK", "HDD", "All Files (*.*)"]);
    dialog.setFilterExtensions (["*.vhd", "*.vdi", "*.vmdk", "*.hdd", "*.*"]);
    dialog.setFilterPath(dirName(sourceFile));
	dialog.setFileName(targetFile);
    file = dialog.open();
    
    if (file is null) {
		targetFile = "";
		return;
	} else {
		targetFile = file;
	}
    
	//ask before overwrite
	if (targetFile.exists) {
	
		MessageBox messageBox = new MessageBox(shell, 
			SWT.ICON_WARNING | SWT.YES | SWT.NO);
        
        messageBox.setText("Warning");
        messageBox.setMessage("Overwrite " ~ targetFile ~ "?");
        int buttonID = messageBox.open();
        if (buttonID == SWT.YES) {
        	doCopy(display, sourceFile, targetFile);
		}
	} else {
		doCopy(display, sourceFile, targetFile);
    }

}
void doOpen()
{
	
	//open file
    FileDialog dialog = new FileDialog(shell, SWT.OPEN);
    dialog.setFilterNames (["VHD", "VDI", "VMDK", "HDD", "All Files (*.*)"]);
    dialog.setFilterExtensions (["*.vhd", "*.vdi", "*.vmdk", "*.hdd", "*.*"]);
    dialog.setFilterPath(getcwd());
    file = dialog.open();
    
    if (file is null) {
    	.showHelp();
    	return;
    }

    sourceFile = file;

	textBox.append("Virtual Drive Selected: " ~ sourceFile ~ Text.DELIMITER);
}

void doClose()
{
	imageDispose(image);
	display.close();
}

void buildShell() {

	const nCol = 1;
	
    display = new Display();
    shell = new Shell(display);
    shell.setText("Virtual Hard Disk Copy Utility");
 
    setIconFromThisExe();
    
	shell.setLayout(new GridLayout(nCol, false));

	//text Widget
	textBox = new Text(shell, SWT.MULTI | SWT.BORDER | SWT.READ_ONLY | SWT.V_SCROLL);
	GridData gdText = new GridData (SWT.FILL, SWT.FILL, true, true);
	//gdText.horizontalSpan = nCol;
	textBox.setLayoutData (gdText);
	
	//menu bar
	Menu menuBar = new Menu(shell, SWT.BAR);

	//file menu
	MenuItem fileMenuHeader = new MenuItem(menuBar, SWT.CASCADE);
	fileMenuHeader.setText("&File");

	Menu fileMenu = new Menu(shell, SWT.DROP_DOWN);
	fileMenuHeader.setMenu(fileMenu);

	MenuItem fileOpenItem = new MenuItem(fileMenu, SWT.PUSH);
	fileOpenItem.setText("&Open");
	fileOpenItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			doOpen();
		}
	});

	MenuItem fileSaveItem = new MenuItem(fileMenu, SWT.PUSH);
	fileSaveItem.setText("&Save As");
	fileSaveItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			doSaveAs();
		}
	});

	MenuItem fileCancelItem = new MenuItem(fileMenu, SWT.PUSH);
	fileCancelItem.setText("&Cancel");
	fileCancelItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			if (!jobDone) jobCancel = true;
		}
	});

	MenuItem fileExitItem = new MenuItem(fileMenu, SWT.PUSH);
	fileExitItem.setText("E&xit");
	fileExitItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			doClose();
		}
	});

	//actions menu

	MenuItem actionsMenuHeader = new MenuItem(menuBar, SWT.CASCADE);
	actionsMenuHeader.setText("&Actions");

	Menu actionsMenu = new Menu(shell, SWT.DROP_DOWN);
	actionsMenuHeader.setMenu(actionsMenu);

	MenuItem clearText = new MenuItem(actionsMenu, SWT.PUSH);
	clearText.setText("&Clear Text Box");
	clearText.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			textBox.setText("");
		}
	});

	MenuItem setUuid = new MenuItem(actionsMenu, SWT.PUSH);
	setUuid.setText("Set &GUUID item");
	setUuid.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			setUUID();
		}
	});

	//help menu

	MenuItem helpMenuHeader = new MenuItem(menuBar, SWT.CASCADE);
	helpMenuHeader.setText("&Help");

	Menu helpMenu = new Menu(shell, SWT.DROP_DOWN);
	helpMenuHeader.setMenu(helpMenu);

	MenuItem helpAboutItem = new MenuItem(helpMenu, SWT.PUSH);
	helpAboutItem.setText("&About");
	helpAboutItem.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			showHelp();
		}
	});

	//show the menu bar
	shell.setMenuBar(menuBar);

	//size the shell and center on monitor
	sizeShell();
	centerShell();

    //Shell Close
    shell.addListener(SWT.Close, new class Listener
    {
	    public void handleEvent(Event e)
	    {
	        e.doit = false;
	        doClose();
	    }
    });
    
}
void sizeShell()
{
	int scale = 2;
    Monitor primary = display.getPrimaryMonitor();
    Rectangle bounds = primary.getBounds();
	shell.setSize(bounds.width / scale, bounds.height / scale);
	//textBox.append(format("W=%s", bounds.width) ~ format(", H=%s", bounds.height));
}
	 
void centerShell()
{
    Monitor primary = display.getPrimaryMonitor();
    Rectangle bounds = primary.getBounds();
    Rectangle rect = shell.getBounds();

    int x = bounds.x + (bounds.width - rect.width) / 2;
    int y = bounds.y + (bounds.height - rect.height) / 2;

    shell.setLocation(x, y);
}

void setIconFromThisExe() {	
	
	//get the handle for this.exe
	auto hMod = OS.GetModuleHandle(null);
	
	//the name of the icon in the .res file is IDI_ICON
    LPCWSTR MYICON = StrToWCHARz ("IDI_ICON");
      
    //get the icon handle from the exe using the given index string, use the default size
    //LR_DEFAULTSIZE is a const via OS.d import WINTYPES.d line 1299
 	auto hIcon = OS.LoadImage(hMod, MYICON, OS.IMAGE_ICON, 0, 0, OS.LR_SHARED | LR_DEFAULTSIZE);
 	
 	//alternate method specifying the icon size
 	//auto hIcon = OS.LoadImage(hMod, MYICON, OS.IMAGE_ICON, 32, 32, OS.LR_SHARED);
    
	//if handle is found, get the image
    if (hIcon !is null) image = Image.win32_new (null, SWT.ICON, hIcon);
    
    //show the icon, if null then show the default icon for exe files 
   	shell.setImage (image);
}

void imageDispose(Image sourceImage) {
    if (sourceImage !is null && !sourceImage.isDisposed()) {
	    sourceImage.dispose();
        sourceImage = null;
    }
}

void showHelp()
{
	string helptext =
    "Virtual Hard Disk Copy Utility \u00A9 2017 by jasc2v8 at yahoo dot com" ~ Text.DELIMITER ~ Text.DELIMITER ~
    "Instructions:" ~ Text.DELIMITER ~
	"File, Open to select virtual hard drive" ~ Text.DELIMITER ~
	"File, Save to save a copy of the virtual hard drive" ~ Text.DELIMITER ~
	"Tools, Clear to clear the Text Box" ~ Text.DELIMITER ~
	"Tools, Set GUUID to change the UUID of the currently selected virtual hard drive";
	
	textBox.setText(helptext);
	
}
