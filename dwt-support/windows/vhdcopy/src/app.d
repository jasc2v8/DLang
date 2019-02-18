/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 
 Vbox tools is a gui to:
    1. Copy virtual disks
    2. Set the virtual disk UUID using VBManage.exe 
 
 A cloned disk gets registerd with the Virtual Media Manager
 This can create GUUID conflicts
 A copied disk must be manually added to the VM, which registers with the VMM
 
 todo: don't allow copy overwrite source!
 
*/

module main;

//D
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

//DWT
import org.eclipse.swt.all;

import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;


import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.custom.BusyIndicator;
import java.lang.all; //.Thread, .util

enum string VBManage32 = r"C:\Program Files (x86)\Oracle\\VirtualBox\VboxManage.exe";
enum string VBManage64 = r"C:\Program Files\Oracle\VirtualBox\VboxManage.exe";

//shared memory between the gui process and the thread
//per the D wiki, __gshared is discouraged, except for C bindings
shared bool jobCancel = false, jobDone = true;

Display display;
Shell shell;
Text txtSource, txtTarget, txtStatus;
Button btnCopy, btnSet, btnCancel;

ImageData id;
Image image;

string sourceFile;
string targetFile;

string VBManage = null;


void main()
{
	
    buildShell();

    shell.open();
   
	if (exists(VBManage32)) {
    	VBManage = VBManage32;
    } else if (exists(VBManage64)) {
    	VBManage = VBManage64;  	
    } else {
    	txtStatus.setText("ERROR - VboxManage.exe not found, press Cancel to exit");
    }
    
    if (VBManage !is null) {
		showHelp();
    }

	//debug
	//txtSource.setText(r"E:\large.vhd");
	//txtTarget.setText(r"C:\VHD\large_copy3.vhd");
	//doCopy();
    
    while (!shell.isDisposed())
    {
        if (!display.readAndDispatch())
            display.sleep();
    }

    display.dispose();
}

void displayStatus(string text) {
	if (display.isDisposed()) return;
	display.syncExec(new class Runnable {
		public void run() {
		    if (txtStatus.isDisposed()) return;
		        txtStatus.setText(text);
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
		//timestamp = to!string(msecs) ~ " msecs";
		peek = "less than 1 second";				
	}
	
	return peek;
}

void doCopy() {
	
	//limit to 1 thread
	if (!jobDone) return;

	//get filenames	
	sourceFile = txtSource.getText();
	targetFile = txtTarget.getText();
	
	//if blank exit
	if ((sourceFile == "") | (targetFile == "")) return;
	
	//set flags
	jobCancel = false;
	jobDone = false;
	
    //next workflow after copy
    shell.setDefaultButton(btnSet);

    Runnable longJob = new class Runnable {

        public void run() {

	        Thread thread = new Thread({
	        		
	        		string sourceFile, targetFile;
	        		
                    display.syncExec(new class Runnable {
                        public void run() {
                            if (txtSource.isDisposed()) return;
	                            sourceFile = txtSource.getText();
								targetFile = txtTarget.getText();
                            }
                    });

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
							
							if (statusCount > 1024*4) {
								
								float c = bufferCount * bufferSize * 1.0;

								displayStatus("Copied: " ~ toXbytes(c) ~ 
									" of " ~ toXbytes(totalBytes) ~
									", Duration: " ~ getPeek(sw));
								
								statusCount = 0;
							}
						}
						
	                    if (!jobCancel) {

	                    	sw.stop();
	                    	
	                    	float byteCount;
	                    	
	                    	if (bufferCount <=1) {
	                    		byteCount = totalBytes;
	                    	} else {
	                    		byteCount = bufferCount*bufferSize;
	                    	}

	                    	displayStatus("Finished, bytes copied: " ~ toXbytes(byteCount) ~ 
								" of " ~ toXbytes(totalBytes) ~
								", Duration: " ~ getPeek(sw));
	                    	
							sourceF.close();
							targetF.close();

	                    }
						
				    }
				    catch (Exception e)
				    {
	                    displayStatus("\nError copying disk!");
	  					sourceF.close();
						targetF.close();
						if (exists(targetFile)) remove(targetFile);
				    }

	               	//if cancel, perform cleanup activity
	                if (jobCancel) {
	                	
                    	sw.stop();

	                	//inform user
	                	displayStatus("\nCopy Cancelled!");

	                    //perform cleanup
      					sourceF.close();
						targetF.close();
						if (exists(targetFile)) remove(targetFile);
	                    
	                    //flag done
	                    jobDone = true;
	                    
	                }
 
                //flag done
                jobDone = true;
                
                // wake up UI thread in case it is in a modal loop awaiting thread termination
                display.wake();
                
            }); //thread
            thread.start();

			//loop until jobDone
            while (!jobDone && !shell.isDisposed()) {if (!display.readAndDispatch()) display.sleep();}
            
        } //run
        
    };//Runnable
    
    //start the runnable with or without the busy indicator
    BusyIndicator.showWhile(display, longJob);
    //longJob.run();
    
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

	
//not used, for future reference
void CloneDisk(string filename)
{
	//parse the output filename
	string ext = extension(filename);
	string file = filename[0..$-4];
	string newhd = file ~ "-clone" ~ ext;

	//inform user
//	txtStatus.append("");
//	txtStatus.append("Clone Source: " ~ filename);
//	txtStatus.append("Clone Target: " ~ newhd);
//	txtStatus.append("\nWorking...\n");
	
	//if target exists, rename to .vhd.bak
	if (exists(newhd))
    {
	    try
	    {
	        rename(newhd, newhd ~ ".bak");
	    }	
		catch (FileException ex)
	    {
	        txtStatus.append("Error renaming: " ~ newhd);
	    }
	}

	runProcess([VBManage, "clonehd", filename, newhd]);
	
	txtStatus.append("\nFinished.\n");

	//disableButtons();
}

void SetUUID()
{
	//set the uuid on the target file
	
	if ((sourceFile == "") && (targetFile == "")) return;	
	
	sourceFile = txtSource.getText();
	targetFile = txtTarget.getText();
	
	if (targetFile == "") {
		targetFile = sourceFile;
		setTarget(sourceFile);
	}	

	setSource("");
	runProcess([VBManage, "internalcommands", "sethduuid", targetFile]);

	//next logical workflow	
    shell.setDefaultButton(btnCancel);

}

void runProcess(string[] args) {

	auto pipes = pipeProcess(args[], Redirect.stdout | Redirect.stderr, null, Config.suppressConsole);

    scope(exit) {
        wait(pipes.pid);
    }

	foreach (line; pipes.stdout.byLine) {
	    txtStatus.setText(to!string(line));	
	}

	foreach (line; pipes.stderr.byLine) {
	    txtStatus.setText(to!string(line));	
	}
}

void doSaveAs() {

	if (txtSource.getText() == "") {
	  	showHelp();
    	return;
	}
	
	//save asfile
    FileDialog dialog = new FileDialog(shell, SWT.SAVE);
    dialog.setFilterNames (["VHD", "VDI", "VMDK", "HDD", "All Files (*.*)"]);
    dialog.setFilterExtensions (["*.vhd", "*.vdi", "*.vmdk", "*.hdd", "*.*"]);
    dialog.setFilterPath(dirName(sourceFile));
    string targetFile = dialog.open();
    
    if (targetFile is null) return;
    
    setTarget(targetFile);
   	txtStatus.setText("Verify target filename, then press [Copy Disk] or [Set GUUID]");
    
    //next logical workflow
    shell.setDefaultButton(btnCopy);

}
void doOpen()
{
	if (VBManage is null) return;
	
	//open file
    FileDialog dialog = new FileDialog(shell, SWT.OPEN);
    dialog.setFilterNames (["VHD", "VDI", "VMDK", "HDD", "All Files (*.*)"]);
    dialog.setFilterExtensions (["*.vhd", "*.vdi", "*.vmdk", "*.hdd", "*.*"]);
    dialog.setFilterPath(getcwd());
    sourceFile = dialog.open();
    
    if (sourceFile is null) {
    	.showHelp();
    	return;
    }

    setSource(sourceFile);

   	string ext = sourceFile[$-4..$];
	targetFile = sourceFile[0..$-4] ~ "_copy" ~ ext;
    setTarget(targetFile);
    
   	txtStatus.setText("Verify target filename, then press [Copy Disk] or [Set GUUID]");

    //set default button
    shell.setDefaultButton(btnCopy);
}

void clearText()
{
    txtStatus.setText("");
}

void doClose()
{
	imageDispose(image);
	display.close();
}

void buildShell() {

	const layoutMode = false;
	const nCol = 8;
	const makeColumnsEqualWidth = true;
	const bWidth = 65;
	
	GridData gd = new GridData(); //use to shorten the length of static constants

    display = new Display();
    shell = new Shell(display);
    shell.setText("Virtual Hard Disk Copy Utility \u00A9 2017 by jasc2v8");
 
    setIconFromThisExe();
    
	shell.setLayout(new GridLayout(nCol, !makeColumnsEqualWidth));

	//Source
	Label lblSource = new Label(shell, SWT.NONE | SWT.CENTER);
	lblSource.setLayoutData(new GridData(gd.HORIZONTAL_ALIGN_CENTER));
	lblSource.setText("Source");
	
    txtSource = new Text(shell, SWT.BORDER);
    if (layoutMode) txtSource.setText("SOURCE");
    GridData gridData = new GridData(gd.HORIZONTAL_ALIGN_FILL);
    gridData.widthHint = 600;
    gridData.horizontalSpan = nCol-2;
    txtSource.setLayoutData(gridData);
    
    Button btnSource = new Button(shell, SWT.BORDER);
    btnSource.setText("Open");
    btnSource.setLayoutData(new GridData(bWidth, SWT.DEFAULT));
    
	//Target
	Label lblTarget = new Label(shell, SWT.NONE | SWT.CENTER);
	lblTarget.setLayoutData(new GridData(gd.HORIZONTAL_ALIGN_CENTER));
	lblTarget.setText("Target");
	
    txtTarget = new Text(shell, SWT.SINGLE | SWT.BORDER);
    if (layoutMode) txtTarget.setText("TARGET");
    gridData = new GridData(gd.HORIZONTAL_ALIGN_FILL);
    gridData.horizontalSpan = nCol-2;
    txtTarget.setLayoutData(gridData);

    Button btnTarget = new Button(shell, SWT.BORDER);
    btnTarget.setText("Save As");
    btnTarget.setLayoutData(new GridData(bWidth, SWT.DEFAULT));
    
	//Status
	Label lblStatus = new Label(shell, SWT.NONE | SWT.CENTER);
	lblStatus.setLayoutData(new GridData(gd.HORIZONTAL_ALIGN_CENTER));
	lblStatus.setText("Status");
	
    txtStatus = new Text(shell, SWT.BORDER);
    if (layoutMode) txtStatus.setText("STATUS");
    gridData = new GridData(gd.HORIZONTAL_ALIGN_FILL);
    gridData.horizontalSpan = nCol-2;
    txtStatus.setLayoutData(gridData);
    
    Button btnStatus = new Button(shell, SWT.BORDER); //SWT.NONE
    btnStatus.setText("Clear");
    btnStatus.setLayoutData(new GridData(bWidth, SWT.DEFAULT));

	//Line Spacer
	Label lblSpacer = new Label(shell, SWT.BORDER);
	lblSpacer.setText("SPACER");
    gridData = new GridData(gd.HORIZONTAL_ALIGN_FILL);
    gridData.horizontalSpan = nCol;
    lblSpacer.setLayoutData(gridData);
	lblSpacer.setVisible(layoutMode);

	//Cell Spacer
	lblSpacer = new Label(shell, SWT.BORDER);
	lblSpacer.setText("SPACER");
	lblSpacer.setLayoutData(new GridData(gd.HORIZONTAL_ALIGN_FILL));
	lblSpacer.setVisible(layoutMode);

	//Cell Spacer, 	grabExcessHorizontalSpace = true
	lblSpacer = new Label(shell, SWT.BORDER);
	lblSpacer.setText("SPACER");
	lblSpacer.setLayoutData(new GridData(gd.HORIZONTAL_ALIGN_FILL, gd.VERTICAL_ALIGN_FILL, true, false));
	lblSpacer.setVisible(layoutMode);
	
	//Buttons
    Button btnExtra1 = new Button(shell, SWT.BORDER); //SWT.NONE
    btnExtra1.setText("Extra One");
    btnExtra1.setLayoutData(new GridData(bWidth, SWT.DEFAULT));
	btnExtra1.setVisible(layoutMode);

    Button btnExtra2 = new Button(shell, SWT.BORDER); //SWT.NONE
    btnExtra2.setText("Extra Two");
    btnExtra2.setLayoutData(new GridData(bWidth, SWT.DEFAULT));
	btnExtra2.setVisible(layoutMode);

    Button btnOK = new Button(shell, SWT.BORDER);
    btnOK.setText("OK");
    btnOK.setLayoutData(new GridData(bWidth, SWT.DEFAULT));
	btnOK.setVisible(layoutMode);

    btnCopy = new Button(shell, SWT.BORDER); //SWT.NONE
    btnCopy.setText("Copy Disk");
    btnCopy.setLayoutData(new GridData(bWidth, SWT.DEFAULT));

    btnSet = new Button(shell, SWT.BORDER); //SWT.NONE
    btnSet.setText("Set GUUID");
    btnSet.setLayoutData(new GridData(bWidth, SWT.DEFAULT));

    btnCancel = new Button(shell, SWT.BORDER);
    btnCancel.setText("Cancel");
    btnCancel.setLayoutData(new GridData(bWidth, SWT.DEFAULT));

    shell.setDefaultButton(btnCancel);

	shell.pack();
	centerShell();

	//Button Handlers
	
    //Source, Open
    btnSource.addSelectionListener(new class SelectionAdapter
    {
		override public void widgetSelected(SelectionEvent e)
	    {
		    doOpen();
	    }
    });
    
    //Target, Save As
    btnTarget.addSelectionListener(new class SelectionAdapter
    {
        override public void widgetSelected(SelectionEvent e)
	    {
            doSaveAs();
        }
    });
    
    //Status, Clear
    btnStatus.addSelectionListener(new class SelectionAdapter
	{
	    override public void widgetSelected(SelectionEvent e)
        {
	        txtStatus.setText("");
        }
	});

    //Copy
    btnCopy.addSelectionListener(new class SelectionAdapter
    {
        override public void widgetSelected(SelectionEvent e)
	    {
			doCopy();
        }
    });
    
    //SetUUID
    btnSet.addSelectionListener(new class SelectionAdapter
    {
        override public void widgetSelected(SelectionEvent e)
	    {
			SetUUID();
        }
    });
    

//    //OK
//    btnOK.addSelectionListener(new class SelectionAdapter
//    {
//	    override public void widgetSelected(SelectionEvent e)
//        {
//	        doOK();
//        }
//    });
    	
    //Cancel
    btnCancel.addSelectionListener(new class SelectionAdapter
    {
    	override public void widgetSelected(SelectionEvent e)
        {
	        //doCancel();
	        if (!jobDone) {
		        jobCancel = true;
	        } else {
	        	doClose();
	        }
        }
    });
    
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

void setSource(string t) {
	txtSource.setText(t);
}

void setTarget(string t) {
	txtTarget.setText(t);
}

void setStatus(string t) {
	txtStatus.setText(t);
}

void showHelp()
{
	string helptext = "Press [Open] to set source, [Save As] to set target, then press [Copy Disk] or [Set UUID]";
	txtStatus.setText(helptext);
	
}