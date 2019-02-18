/*
 * Copyright (C) 2017 by jasc2v8 at yahoo dot com
 * License: http://www.boost.org/LICENSE_1_0.txt
 *
 * Model, View, Controller (MVC) standalone app example 
 * This module is the View
 *
*/

module gui;

import all;

const int BUTTON_WIDTH = 75;

private Shell shell;
private Display display;
private Text txtEdit;
private Font txtEditFont;
private Button btnCancel;
private Button btnFiles;

class gui {
	
	// Constructor
	this() {
		
	    display = new Display();
	   //shell = new Shell(display, SWT.CLOSE | SWT.TITLE | SWT.MIN); // not resizable
	    shell = new Shell(display); //resizable
	    shell.setText(TITLE);
	    
	    shell.setLayout(new FormLayout());
	    shell.setBounds(0, 0, 16 * 42, 9 * 60);
	    
	    btnCancel = new Button(shell, SWT.PUSH);
	    btnCancel.setText("Cancel");
	    FormData formData = new FormData();
	    formData.right = new FormAttachment(100, -5);
	    formData.bottom = new FormAttachment(100, -5);
	    formData.width = BUTTON_WIDTH;
	    btnCancel.setLayoutData(formData);

        txtEdit = new Text(shell, SWT.MULTI | SWT.BORDER | SWT.H_SCROLL | SWT.V_SCROLL);
		txtEditFont = new Font(txtEdit.getDisplay(), new FontData("Courier New", 12, SWT.NORMAL));
		txtEdit.setFont(txtEditFont);
		formData = new FormData();
		formData.top = new FormAttachment(0, 5);
		formData.bottom = new FormAttachment(btnCancel, -5);
		formData.left = new FormAttachment(0, 5);
		formData.right = new FormAttachment(100, -5);
		txtEdit.setLayoutData(formData);
    
        btnFiles = new Button(shell, SWT.PUSH);
	    btnFiles.setText("File(s)");
	    formData = new FormData();
	    formData.left = new FormAttachment(0, 5);
	    formData.bottom = new FormAttachment(100, -5);
	    formData.width = BUTTON_WIDTH;
	    btnFiles.setLayoutData(formData);
	    
	}//Constructor
	
	public void btnCancelListener(SelectionAdapter a){btnCancel.addSelectionListener(a);}
	public void btnFilesListener(SelectionAdapter a){btnFiles.addSelectionListener(a);}
	
	public void show(){
		shell.open();		
	}
	
	public bool isDisposed() {
		if (shell.isDisposed()) return true;
		else return false;
	}
	
	public bool readAndDispatch() {
		if (display.readAndDispatch()) return true;
		else return false;
	}
	
	public void sleep() {
		display.sleep();
	}
	
	public void TextAppend(string sometext)
	{
		txtEdit.append(sometext ~ "\n");
	}
	
	public void TextSet(string sometext)
	{
		txtEdit.setText(sometext ~ "\n");
	}

	public void doCancel()
	{
		dispose();
		exit(0); //clang
	}
	
	public void dispose() {
		txtEditFont.dispose();
		display.dispose();		
	}
	
	// Destructor
	~this() {
	}
		
}
