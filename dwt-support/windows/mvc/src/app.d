/*
 * Copyright (C) 2017 by jasc2v8 at yahoo dot com
 * License: http://www.boost.org/LICENSE_1_0.txt
 *
 * Model, View, Controller (MVC) standalone app example 
 * 
 * The objective is to make the code modular and easier to manage
 *
 * model		= app.d (see note below)
 * view			= gui.d
 * controller	= app.d
 *
 * Note: You could create a worker class as the model, but it won't be easy to update the view
 *
*/

module main;

import all;

gui view;

void main()
{

	view = new gui();
	
	view.show();
	
	addButtonListeners();
	
	while (!view.isDisposed())
    {
        if (!view.readAndDispatch())
            view.sleep();
    }
    
    view.dispose();
	
}

private void OpenFiles(){
	view.TextAppend("Create your function...");
}

private void addButtonListeners() {
	
	view.btnFilesListener(new class SelectionAdapter
    {
    	override public void widgetSelected(SelectionEvent e)
        {
	        OpenFiles();
	    }
	});
		
	view.btnCancelListener(new class SelectionAdapter
    {
    	override public void widgetSelected(SelectionEvent e)
        {
	        view.doCancel();
	    }
	});
		
}