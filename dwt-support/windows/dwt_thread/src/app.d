/*
 Copyright (C) 2017 by jasc2v8 at yahoo dot com
 License: http://www.boost.org/LICENSE_1_0.txt
 
 This module demonstrates the use of Threads with DWT
 
 The objective is to;
 
 1. Start a long running process (LRP) in a new Thread
 2. Have the gui remain responsive and unfrozen during the LRP
 3. Handle button presses before, during, and after the LRP
 4. Handle a CANCEL request ot terminate the LRP 
 
 This code is based on DWT Snippet130
 Includes andinteresting use of the Format function in import java.lang.util
 
*/

module main;

import std.conv :  to;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.GridData;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.layout.RowLayout;

import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.custom.BusyIndicator;

import java.lang.all; //.Thread, .util

//globals
Shell shell;
Text text;
int okCount = 0;

//shared memory between the gui process and the thread
__gshared bool jobCancel = false, jobDone = true;

//Button size constants
enum buttonW = 75;
enum buttonH = 35;

void main() {
	
    Display display = new Display();
    
    shell = new Shell(display);
    shell.setLayout(new GridLayout());
    shell.setText("DWT Thread Demo");
    
    text = new Text(shell, SWT.MULTI | SWT.BORDER | SWT.V_SCROLL);
    text.setLayoutData(new GridData(GridData.FILL_BOTH));
    
    Composite buttonRow = new Composite (shell, SWT.NO_FOCUS);
    buttonRow.setLayout (new RowLayout ());

    Button start = new Button(buttonRow, SWT.PUSH);
    start.setText("Start");
    start.setLayoutData(new RowData(buttonW,buttonH));

    Button ok = new Button(buttonRow, SWT.PUSH);
    ok.setText("OK");
    ok.setLayoutData(new RowData(buttonW,buttonH));

    Button cancel = new Button(buttonRow, SWT.PUSH);
    cancel.setText("CANCEL");
    cancel.setLayoutData(new RowData(buttonW,buttonH));

	//button handlers
	
    start.addSelectionListener(new class SelectionAdapter {
        override
        public void widgetSelected(SelectionEvent e) {
	       	doLongJob(display);
        }
    });

    ok.addSelectionListener(new class SelectionAdapter {
        override
        public void widgetSelected(SelectionEvent e) {
			if (!jobDone) {
	        	text.append("\nIgnore the Ok button until the job is done!");
	        	return;
        	}
			okCount++;
        	text.append(Format("\nOK press count: {}", okCount));
        }
    });
    
    cancel.addSelectionListener(new class SelectionAdapter {
        override
        public void widgetSelected(SelectionEvent e) {
        	
			if (jobDone) {
	        	text.append("\nIgnore the Cancel button if no job running!");
	        	return;        		
        	} else {
	        	//text.append("\nCancel pressed!");
        		jobCancel = true;
	        }
        }
    });
    
	//open shell
	
    shell.setSize(600, 400);
    shell.open();

    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    
    display.dispose();
}

void doLongJob(Display display) {
	
	//limit to 1 thread
	if (!jobDone) return;
	
	//set flags
	jobCancel = false;
	jobDone = false;
	
    Runnable longJob = new class Runnable {

        public void run() {
	        Thread thread = new Thread({

				//inform start
                display.syncExec(new class Runnable {
                    public void run() {
                    if (text.isDisposed()) return;
	                    text.setText("Start long running task");
                    }
                });

                //perform the long task               
                for (int i = 1; i <= 5; i++) {
                
                    if (jobCancel) break;
                    
                    if (display.isDisposed()) return;
                    display.syncExec(new class Runnable {
                        public void run() {
                            if (text.isDisposed()) return;
	                            text.append(Format("\nPass: {}", i));
                            }
                    });
                        
                    Thread.sleep(500*2); //simulate a long task

                }

               	//if cancel, perform cleanup activity
                if (jobCancel) {
                	
                	//inform cancel
                    if (display.isDisposed()) return;
                	display.syncExec(new class Runnable {
                        public void run() {
                            if (text.isDisposed()) return;
                            text.append("\nTask Cancelled!");
                        }
                    });

					//
                    //perform cleanup here (close files, delete temps, etc.)
                    //
                    
                    //flag done
                    jobDone = true;
                    
                }
 
				 //inform done           
				if (display.isDisposed()) return;
                display.syncExec(new class Runnable {
                    public void run() {
                        if (text.isDisposed()) return;
                        text.append("\nCompleted long running task");
                    }
                });
                
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
