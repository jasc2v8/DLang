//todo re-organize by alpha order
//put images in resource.res
//

/*******************************************************************************
* Copyright (c) 2000, 2007 IBM Corporation and others.
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*
* Contributors:
*     IBM Corporation - initial API and implementation
* Port to the D1 programming language:
*     Frank Benoit <benoit@tionex.de>
* Port to the D2 programming language:
*    simplifed with functions instead of classes
*	 replacee some complex examples with less complex snippets
*    JamesD <jasc2v8@yahoo.com>
*/

module widgetdemo;

import std.stdio;
import std.conv;
import std.path;
import std.file;
import std.format;
import std.algorithm.comparison;

import org.eclipse.swt.all;
import org.eclipse.swt.internal.win32.OS;

Shell shell;
Display display;
Image shellIcon;

Control function(TabFolder tabFolder)[] getTab = 
[
	&getButtonTab,   &getCanvasTab,   &getComboTab,     &getCoolBarTab,
	&getDateTimeTab, &getDialogTab,   &getExpandBarTab, &getGroupTab,
	&getLabelTab,    &getLinkTab,     &getListTab,      &getMenuTab,
	&getProgressTab, &getSashFormTab, &getScaleTab,     &getShellTab,
	&getSliderTab,   &getSpinnerTab,  &getTableTab,     &getTextTab,
	&getToolBarTab,  &getToolTipTab,  &getTreeTab,      &getTabFolderTab,
];

string [] tabName =
[
	"Button",    "Canvas",   "Combo",      "Cool Bar",
	"Date/Time", "Dialog",   "ExpandBar", "Group",
	"Label",     "Link",     "List",        "Menu",
	"Progress",  "SashForm", "Scale",       "Shell",
	"Slider",    "Spinner",  "Table",       "Text",
	"ToolBar",   "ToolTip",  "Tree",        "TabFolder"
];

TabItem[] tabItem;

Image closedFolderImage, openFolderImage, targetImage;

void main(string[] args) {
	
    display = new Display();
    shell = new Shell(display);
	shell.setLayout(new FillLayout());
	shell.setBackground(display.getSystemColor(SWT.COLOR_LIST_BACKGROUND));
	shell.setText("DWT (d-widget-toolkit) Widget Demo");
	LoadImageFromThisExe();

	closedFolderImage = new Image(display, "views" ~ dirSeparator ~ "closedFolder.gif");
	openFolderImage = new Image(display, "views" ~ dirSeparator ~ "openFolder.gif");
	targetImage = new Image(display, "views" ~ dirSeparator ~ "target.gif");

	TabFolder tabFolder = new TabFolder(shell, SWT.BORDER);
	tabFolder.setLayout(new GridLayout());
	
	int nitems = cast (int) tabName.length;
	tabItem.length = nitems;

	for (int i=0; i<nitems; i++) {
		tabItem[i] = new TabItem(tabFolder, SWT.BORDER);
		//tabItem[i].setText ("Tab " ~ to!(string)(i+1));
		tabItem[i].setText(tabName[i]);
		tabItem[i].setControl(getTab[i](tabFolder));
	}

	//Shell Close
    shell.addListener(SWT.Close, new class Listener
	{
		public void handleEvent(Event e)
		{
			doClose();
		}
	});

	setShellSizeCenter();

    shell.open();

	//////////////////////////DEBUG
	//tabFolder.setSelection(nitems-5);

    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}

private Control getTabFolderTab(TabFolder tabFolder) {

    TabFolder tabFolder1;
    Group tabFolderGroup;

	Group group = new Group (tabFolder, SWT.NONE);
	group.setLayout (new FillLayout ());

    string[] TabItems1;
    TabItems1 = ["Tab 0", "Tab 1", "Tab 2"];

	/* Create a group for the TabFolder */
    tabFolderGroup = new Group (group, SWT.NONE);
    tabFolderGroup.setLayout (new GridLayout ());
    tabFolderGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
    //tabFolderGroup.setText ("TabFolder");

	//if (topButton.getSelection ()) style |= SWT.TOP;
	//if (bottomButton.getSelection ()) style |= SWT.BOTTOM;
	//if (borderButton.getSelection ()) style |= SWT.BORDER;

    tabFolder1 = new TabFolder (tabFolderGroup, SWT.TOP);

    for (int i = 0; i < TabItems1.length; i++) {
        TabItem item = new TabItem(tabFolder1, SWT.NONE);
        item.setText(TabItems1[i]);
        item.setToolTipText( format( "Tooltip %s", TabItems1[i] ));
        Text content = new Text(tabFolder1, SWT.WRAP | SWT.MULTI);
        content.setText( format( "Example content for Tab %s", i));
        item.setControl(content);
    }

	return group;
}

private Control getTreeTab(TabFolder tabFolder) {

	Group group = new Group (tabFolder, SWT.NONE);
	group.setLayout (new FillLayout ());

    auto tree = new Tree (group, SWT.BORDER);
    for (int i=0; i<4; i++) {
        auto iItem = new TreeItem (tree, 0);
        iItem.setText ("Item 0 -" ~ to!string(i));
        for (int j=0; j<4; j++) {
            TreeItem jItem = new TreeItem (iItem, 0);
            jItem.setText ("Item 1 -" ~ to!string(j));
            for (int k=0; k<4; k++) {
                TreeItem kItem = new TreeItem (jItem, 0);
                kItem.setText ("Item 2 -" ~ to!string(k));
                for (int l=0; l<4; l++) {
                    TreeItem lItem = new TreeItem (kItem, 0);
                    lItem.setText ("Item 3 -" ~ to!string(l));
                }
            }
        }
    }

	return group;
}

private Control getToolTipTab(TabFolder tabFolder) {

	ToolTip toolTip1, toolTip2, toolTip3, toolTip4;
    Group toolTipGroup;

    Tray tray;
    TrayItem trayItem;

	Group exampleGroup = new Group (tabFolder, SWT.NONE);
	exampleGroup.setLayout (new GridLayout ());
    exampleGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
	//exampleGroup.setText ("ToolBbar");
	
	toolTipGroup = new Group (exampleGroup, SWT.NONE);
    toolTipGroup.setLayout (new GridLayout ());
    toolTipGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, false, false));
    toolTipGroup.setText ("ToolTip");

    Group otherGroup = new Group (exampleGroup, SWT.NONE);
    otherGroup.setLayout (new GridLayout ());
    otherGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, false, false));
    otherGroup.setText ("Other");

    Button visibleButton = new Button(toolTipGroup, SWT.CHECK);
    visibleButton.setText("SWT.BALLOON");
	visibleButton.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent event) {
			toolTip1.setVisible (visibleButton.getSelection ());
		}
	});

    Button vb2 = new Button(toolTipGroup, SWT.CHECK);
    vb2.setText("SWT.ICON_ERROR");
	vb2.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent event) {
			toolTip2.setVisible (vb2.getSelection ());
		}
	});

	Button vb3 = new Button(toolTipGroup, SWT.CHECK);
    vb3.setText("SWT.ICON_INFORMATION");
	vb3.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent event) {
			toolTip3.setVisible (vb3.getSelection ());
		}
	});

	Button vb4 = new Button(toolTipGroup, SWT.CHECK);
    vb4.setText("SWT.ICON_WARNING");
	vb4.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent event) {
			toolTip4.setVisible (vb4.getSelection ());
		}
	});

    toolTip1 = new ToolTip (shell, SWT.BALLOON);
    toolTip1.setText("ToolTip_Title");
    toolTip1.setMessage("Example_string");

    toolTip2 = new ToolTip (shell, SWT.ICON_ERROR);
    toolTip2.setText("ToolTip_Title");
    toolTip2.setMessage("Example_string");

    toolTip3 = new ToolTip (shell, SWT.ICON_INFORMATION);
    toolTip3.setText("ToolTip_Title");
    toolTip3.setMessage("Example_string");

    toolTip4 = new ToolTip (shell, SWT.ICON_WARNING);
    toolTip4.setText("ToolTip_Title");
    toolTip4.setMessage("Example_string");

    Button autoHideButton = new Button(otherGroup, SWT.CHECK);
    autoHideButton.setText("AutoHide");
	autoHideButton.setSelection(true);

	toolTip1.setAutoHide(autoHideButton.getSelection ());

    Button showInTrayButton = new Button(otherGroup, SWT.CHECK);
    showInTrayButton.setText("Show_In_Tray");
    tray = display.getSystemTray();
    showInTrayButton.setEnabled(tray !is null);

    autoHideButton.addSelectionListener (new class SelectionAdapter {
        override public void widgetSelected (SelectionEvent event) {
            toolTip1.setAutoHide(autoHideButton.getSelection ());
        }
    });

    showInTrayButton.addSelectionListener (new class SelectionAdapter {
        override public void widgetSelected (SelectionEvent event) {
			if (showInTrayButton.getSelection ()) {
				if (trayItem is null) {
					trayItem = new TrayItem(tray, SWT.NONE);
					trayItem.setImage(targetImage);
					trayItem.setToolTip(toolTip1);
				}
			} else {
				if (trayItem !is null) {
					trayItem.setToolTip(null);
					trayItem.dispose();
					trayItem = null;
				}
			}
        }
    });

    shell.addDisposeListener(new class DisposeListener {
        override public void widgetDisposed(DisposeEvent event) {
			if (trayItem !is null) {
				trayItem.setToolTip(null);
				trayItem.dispose();
				trayItem = null;
			}
        }
    });

	return exampleGroup;
}

private Control getToolBarTab(TabFolder tabFolder) {

    ToolBar imageToolBar, textToolBar, imageTextToolBar;
    Group imageToolBarGroup, textToolBarGroup, imageTextToolBarGroup;

	Group exampleGroup = new Group (tabFolder, SWT.NONE);
	exampleGroup.setLayout (new GridLayout ());
    exampleGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
	//exampleGroup.setText ("ToolBbar");

	imageToolBarGroup = new Group (exampleGroup, SWT.NONE);
    imageToolBarGroup.setLayout (new GridLayout ());
    imageToolBarGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
    imageToolBarGroup.setText ("Image_ToolBar");

    textToolBarGroup = new Group (exampleGroup, SWT.NONE);
    textToolBarGroup.setLayout (new GridLayout ());
    textToolBarGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
    textToolBarGroup.setText ("Text_ToolBar");

    imageTextToolBarGroup = new Group (exampleGroup, SWT.NONE);
    imageTextToolBarGroup.setLayout (new GridLayout ());
    imageTextToolBarGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
    imageTextToolBarGroup.setText ("ImageText_ToolBar");

	//if (horizontalButton.getSelection()) style |= SWT.HORIZONTAL;
	//if (verticalButton.getSelection()) style |= SWT.VERTICAL;
	//if (flatButton.getSelection()) style |= SWT.FLAT;
	//if (wrapButton.getSelection()) style |= SWT.WRAP;
	//if (borderButton.getSelection()) style |= SWT.BORDER;
	//if (shadowOutButton.getSelection()) style |= SWT.SHADOW_OUT;
	//if (rightButton.getSelection()) style |= SWT.RIGHT;

       /* Create the image tool bar */
        imageToolBar = new ToolBar (imageToolBarGroup, SWT.HORIZONTAL);
        ToolItem item = new ToolItem (imageToolBar, SWT.PUSH);
        item.setImage (closedFolderImage);
        item.setToolTipText("SWT.PUSH");
        item = new ToolItem (imageToolBar, SWT.PUSH);
        item.setImage (closedFolderImage);
        item.setToolTipText ("SWT.PUSH");
        item = new ToolItem (imageToolBar, SWT.RADIO);
        item.setImage (openFolderImage);
        item.setToolTipText ("SWT.RADIO");
        item = new ToolItem (imageToolBar, SWT.RADIO);
        item.setImage (openFolderImage);
        item.setToolTipText ("SWT.RADIO");
        item = new ToolItem (imageToolBar, SWT.CHECK);
        item.setImage (targetImage);
        item.setToolTipText ("SWT.CHECK");
        item = new ToolItem (imageToolBar, SWT.RADIO);
        item.setImage (closedFolderImage);
        item.setToolTipText ("SWT.RADIO");
        item = new ToolItem (imageToolBar, SWT.RADIO);
        item.setImage (closedFolderImage);
        item.setToolTipText ("SWT.RADIO");
        item = new ToolItem (imageToolBar, SWT.SEPARATOR);
        item.setToolTipText("SWT.SEPARATOR");

            Combo combo = new Combo (imageToolBar, SWT.NONE);
            combo.setItems (["250", "500", "750"]);
            combo.setText (combo.getItem (0));
            combo.pack ();

            item.setWidth (combo.getSize ().x);
            item.setControl (combo);

        item = new ToolItem (imageToolBar, SWT.DROP_DOWN);
        item.setImage (targetImage);
        item.setToolTipText ("SWT.DROP_DOWN");
        //item.addSelectionListener(new DropDownSelectionListener());

        /* Create the text tool bar */
        textToolBar = new ToolBar (textToolBarGroup, SWT.HORIZONTAL);
        item = new ToolItem (textToolBar, SWT.PUSH);
        item.setText ("Push");
        item.setToolTipText("SWT.PUSH");
        item = new ToolItem (textToolBar, SWT.PUSH);
        item.setText ("Push");
        item.setToolTipText("SWT.PUSH");
        item = new ToolItem (textToolBar, SWT.RADIO);
        item.setText ("Radio");
        item.setToolTipText("SWT.RADIO");
        item = new ToolItem (textToolBar, SWT.RADIO);
        item.setText ("Radio");
        item.setToolTipText("SWT.RADIO");
        item = new ToolItem (textToolBar, SWT.CHECK);
        item.setText ("Check");
        item.setToolTipText("SWT.CHECK");
        item = new ToolItem (textToolBar, SWT.RADIO);
        item.setText ("Radio");
        item.setToolTipText("SWT.RADIO");
        item = new ToolItem (textToolBar, SWT.RADIO);
        item.setText ("Radio");
        item.setToolTipText("SWT.RADIO");
        item = new ToolItem (textToolBar, SWT.SEPARATOR);
        item.setToolTipText("SWT.SEPARATOR");

            combo = new Combo (textToolBar, SWT.NONE);
            combo.setItems (["250", "500", "750"]);
            combo.setText (combo.getItem (0));
            combo.pack ();
            item.setWidth (combo.getSize ().x);
            item.setControl (combo);

		item = new ToolItem (textToolBar, SWT.DROP_DOWN);
        item.setText ("Drop_Down");
        item.setToolTipText("SWT.DROP_DOWN");

        //item.addSelectionListener(new DropDownSelectionListener());

        /* Create the image and text tool bar */
        imageTextToolBar = new ToolBar (imageTextToolBarGroup, SWT.HORIZONTAL);
        item = new ToolItem (imageTextToolBar, SWT.PUSH);
        item.setImage (closedFolderImage);
        item.setText ("Push");
        item.setToolTipText("SWT.PUSH");
        item = new ToolItem (imageTextToolBar, SWT.PUSH);
        item.setImage (closedFolderImage);
        item.setText ("Push");
        item.setToolTipText("SWT.PUSH");
        item = new ToolItem (imageTextToolBar, SWT.RADIO);
        item.setImage (openFolderImage);
        item.setText ("Radio");
        item.setToolTipText("SWT.RADIO");
        item = new ToolItem (imageTextToolBar, SWT.RADIO);
        item.setImage (openFolderImage);
        item.setText ("Radio");
        item.setToolTipText("SWT.RADIO");
        item = new ToolItem (imageTextToolBar, SWT.CHECK);
        item.setImage (targetImage);
        item.setText ("Check");
        item.setToolTipText("SWT.CHECK");
        item = new ToolItem (imageTextToolBar, SWT.RADIO);
        item.setImage (closedFolderImage);
        item.setText ("Radio");
        item.setToolTipText("SWT.RADIO");
        item = new ToolItem (imageTextToolBar, SWT.RADIO);
        item.setImage (closedFolderImage);
        item.setText ("Radio");
        item.setToolTipText("SWT.RADIO");
        item = new ToolItem (imageTextToolBar, SWT.SEPARATOR);
        item.setToolTipText("SWT.SEPARATOR");

            combo = new Combo (imageTextToolBar, SWT.NONE);
            combo.setItems (["250", "500", "750"]);
            combo.setText (combo.getItem (0));
            combo.pack ();
            item.setWidth (combo.getSize ().x);
            item.setControl (combo);

		item = new ToolItem (imageTextToolBar, SWT.DROP_DOWN);
        item.setImage (targetImage);
        item.setText ("Drop_Down");
        item.setToolTipText("SWT.DROP_DOWN");
        //item.addSelectionListener(new DropDownSelectionListener());

	return exampleGroup;
}

private Control getTableTab(TabFolder tabFolder) {

	Group group = new Group (tabFolder, SWT.NONE);
	group.setLayout (new FillLayout ());
	group.setText ("Note the table column headers are BROKEN in Windows, but they work on Linux");
	
    Table table = new Table (group,  SWT.MULTI | SWT.BORDER | SWT.FULL_SELECTION | SWT.V_SCROLL | SWT.H_SCROLL);
    table.setLinesVisible (true);
    table.setHeaderVisible (true);
    string[] titles = ["Title0", "Title1", "Title2", "Title3", "Title4", "Title5", "Title6"];
    int[]    styles = [SWT.NONE, SWT.LEFT, SWT.RIGHT, SWT.CENTER, SWT.NONE, SWT.NONE, SWT.NONE];
    foreach (i,title; titles) {
        TableColumn column = new TableColumn (table, styles[i]);
        column.setText (title);
    }
    int count = 128;
    for (int i=0; i<count; i++) {
        auto item = new TableItem (table, SWT.NONE);
        item.setText (0, "Row " ~ to!string(i));
        item.setText (1, "SWT.NONE");
        item.setText (2, "SWT.LEFT");
        item.setText (3, "SWT.RIGHT");
        item.setText (4, "SWT.CENTER");
        item.setText (5, "SWT.NONE");
        item.setText (6, "SWT.NONE");
    }

    for (int i=0; i<titles.length; i++) {
        table.getColumn (i).pack ();
    }

    //table.setSize (table.computeSize (SWT.DEFAULT, 200));

	return group;
}

private Control getSpinnerTab(TabFolder tabFolder) {

	Group group = new Group (tabFolder, SWT.NONE);
	group.setLayout (new GridLayout ());
	group.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
	group.setText ("Spinner");

  	//int style = getDefaultStyle();
	//if (horizontalButton.getSelection ()) style |= SWT.HORIZONTAL;
	//if (verticalButton.getSelection ()) style |= SWT.VERTICAL;
	//if (borderButton.getSelection ()) style |= SWT.BORDER;

    //Slider spinner1 = new Slider(group, SWT.HORIZONTAL);
    Spinner spinner1 = new Spinner(group, SWT.HORIZONTAL);

	//increment group
	Group incrementGroup = new Group (group, SWT.NONE);
	incrementGroup.setLayout (new GridLayout ());
	incrementGroup.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));
	incrementGroup.setText ("Increment");

	Spinner incrementSpinner = new Spinner (incrementGroup, SWT.BORDER);
	incrementSpinner.setMaximum (100000);
	//incrementSpinner.setSelection (getDefaultIncrement());
	incrementSpinner.setPageIncrement (100);
	incrementSpinner.setIncrement (1);
	incrementSpinner.setLayoutData (new GridData (SWT.FILL, SWT.CENTER, true, false));

	incrementSpinner.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent e) {
			spinner1.setIncrement (incrementSpinner.getSelection ());
		}
	});

	//page increment

	Group pageIncrementGroup = new Group (group, SWT.NONE);
	pageIncrementGroup.setLayout (new GridLayout ());
	pageIncrementGroup.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));
	pageIncrementGroup.setText ("Page_Increment");

	Spinner pageIncrementSpinner = new Spinner (pageIncrementGroup, SWT.BORDER);
	pageIncrementSpinner.setMaximum (100000);
	//pageIncrementSpinner.setSelection (getDefaultPageIncrement());
	pageIncrementSpinner.setPageIncrement (100);
	pageIncrementSpinner.setIncrement (1);
	pageIncrementSpinner.setLayoutData (new GridData (SWT.FILL, SWT.CENTER, true, false));

	pageIncrementSpinner.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent event) {
			spinner1.setPageIncrement (pageIncrementSpinner.getSelection ());
		}
	});

	//thumb group

	Group thumbGroup = new Group (group, SWT.NONE);
	thumbGroup.setLayout (new GridLayout ());
	thumbGroup.setText ("Thumb");
	thumbGroup.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));

	/* Create the Spinner widget */
	Spinner digitsSpinner = new Spinner (thumbGroup, SWT.BORDER);
	digitsSpinner.setMaximum (100000);
	//thumbSpinner.setSelection (getDefaultThumb());
	digitsSpinner.setPageIncrement (100);
	digitsSpinner.setIncrement (1);
	digitsSpinner.setLayoutData (new GridData (SWT.FILL, SWT.CENTER, true, false));

	/* Add the listeners */
	digitsSpinner.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent event) {
			//spinner1.setThumb (thumbSpinner.getSelection ());
			spinner1.setDigits (digitsSpinner.getSelection ());
		}
	});

	return group;
}

private Control getSliderTab(TabFolder tabFolder) {

	Group group = new Group (tabFolder, SWT.NONE);
	group.setLayout (new GridLayout ());
	group.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
	group.setText ("Slider");

  	//int style = getDefaultStyle();
	//if (horizontalButton.getSelection ()) style |= SWT.HORIZONTAL;
	//if (verticalButton.getSelection ()) style |= SWT.VERTICAL;
	//if (borderButton.getSelection ()) style |= SWT.BORDER;

    Slider slider1 = new Slider(group, SWT.HORIZONTAL);

	//increment group
	Group incrementGroup = new Group (group, SWT.NONE);
	incrementGroup.setLayout (new GridLayout ());
	incrementGroup.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));
	incrementGroup.setText ("Increment");

	Spinner incrementSpinner = new Spinner (incrementGroup, SWT.BORDER);
	incrementSpinner.setMaximum (100000);
	//incrementSpinner.setSelection (getDefaultIncrement());
	incrementSpinner.setPageIncrement (100);
	incrementSpinner.setIncrement (1);
	incrementSpinner.setLayoutData (new GridData (SWT.FILL, SWT.CENTER, true, false));
	
	incrementSpinner.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent e) {
			slider1.setIncrement (incrementSpinner.getSelection ());
		}
	});

	//page increment

	Group pageIncrementGroup = new Group (group, SWT.NONE);
	pageIncrementGroup.setLayout (new GridLayout ());
	pageIncrementGroup.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));
	pageIncrementGroup.setText ("Page_Increment");

	Spinner pageIncrementSpinner = new Spinner (pageIncrementGroup, SWT.BORDER);
	pageIncrementSpinner.setMaximum (100000);
	//pageIncrementSpinner.setSelection (getDefaultPageIncrement());
	pageIncrementSpinner.setPageIncrement (100);
	pageIncrementSpinner.setIncrement (1);
	pageIncrementSpinner.setLayoutData (new GridData (SWT.FILL, SWT.CENTER, true, false));

	pageIncrementSpinner.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent event) {
			slider1.setPageIncrement (pageIncrementSpinner.getSelection ());
		}
	});

	//thumb group

	Group thumbGroup = new Group (group, SWT.NONE);
	thumbGroup.setLayout (new GridLayout ());
	thumbGroup.setText ("Thumb");
	thumbGroup.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));

	/* Create the Spinner widget */
	Spinner thumbSpinner = new Spinner (thumbGroup, SWT.BORDER);
	thumbSpinner.setMaximum (100000);
	//thumbSpinner.setSelection (getDefaultThumb());
	thumbSpinner.setPageIncrement (100);
	thumbSpinner.setIncrement (1);
	thumbSpinner.setLayoutData (new GridData (SWT.FILL, SWT.CENTER, true, false));

	/* Add the listeners */
	thumbSpinner.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent event) {
			slider1.setThumb (thumbSpinner.getSelection ());
		}
	});

	return group;
}

private Control getShellTab(TabFolder tabFolder) {

	Group group = new Group (tabFolder, SWT.NONE);
	group.setLayout (new GridLayout ());

	Button buttonOpen = new Button(group, SWT.PUSH);
	buttonOpen.setText("Open Shells");
	buttonOpen.setLayoutData(new GridData (SWT.END, SWT.CENTER, true, false));

	Button buttonClose = new Button(group, SWT.PUSH);
	buttonClose.setText("Close Shells");
	buttonClose.setLayoutData(new GridData (SWT.END, SWT.CENTER, true, false));

	int [] styles = [SWT.SHELL_TRIM, SWT.DIALOG_TRIM];
	string [] titles = ["SWT.SHELL_TRIM", "SWT.DIALOG_TRIM"];
	Shell [] shells = new Shell [titles.length];

	buttonOpen.addSelectionListener(new class SelectionAdapter {
		override public void widgetSelected(SelectionEvent e)
		{
			for (int i; i < shells.length; i++) {
				shells [i] = new Shell (styles[i]);
				shells[i].setSize (400, 200);
				shells[i].setText (format("Shell %s: %s", i, titles[i]));
				shells[i].open ();
			}
		}
	});

	buttonClose.addSelectionListener(new class SelectionAdapter {
		override public void widgetSelected(SelectionEvent e)
		{
			int nshells = cast (int) shells.length;
			for (int i = 0; i < shells.length; i++) {
				if ( (shells[i] !is null) & !shells [i].isDisposed ()) {
					shells [i].dispose();
				}
			}
		}
	});

	return group;
}

private Control getScaleTab(TabFolder tabFolder) {

	Composite composite = new Composite (tabFolder, SWT.NONE);
	composite.setLayout (new FillLayout ());

    Group horizontalGroup = new Group (composite, SWT.NONE);
	horizontalGroup.setLayout(new GridLayout(1, true));

    Scale scale1 = new Scale (horizontalGroup, SWT.HORIZONTAL);
	scale1.setMaximum (100);
	scale1.setMinimum (0);
	scale1.setSelection (50);
	scale1.setPageIncrement (10);
	scale1.setIncrement (1);

	Label label1 = new Label (horizontalGroup, SWT.NONE);
	label1.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));
	label1.setText("Volume: 50");

	scale1.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent e) {
			label1.setText (format ("Volume: %s", scale1.getSelection ()));
		}
	});

    Group verticalGroup = new Group (composite, SWT.NONE);
    verticalGroup.setLayout(new GridLayout(1, true));

    Scale scale2 = new Scale (verticalGroup, SWT.VERTICAL | SWT.BORDER);
	scale2.setMaximum (100);
	scale2.setMinimum (0);
	scale2.setSelection (50);
	scale2.setPageIncrement (10);
	scale2.setIncrement (1);

	Label label2 = new Label (verticalGroup, SWT.NONE);
	label2.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));
	label2.setText("Volume: 50");

	scale2.addSelectionListener (new class SelectionAdapter {
		override public void widgetSelected (SelectionEvent e) {
			int selectionValue = scale2.getMaximum() - scale2.getSelection() + scale2.getMinimum();
			label2.setText (format ("Volume: %s", selectionValue));
		}
	});

	return composite;
}

private Control getSashFormTab(TabFolder tabFolder) {

	Group group = new Group (tabFolder, SWT.NONE);
    group.setLayout (new FillLayout());
	//group.setText ("SashForm");

	SashForm sashForm1;
	SashForm sashForm2;

	int count;

	sashForm1 = new SashForm(group, SWT.BORDER | SWT.HORIZONTAL);

	Text text1 = new Text(sashForm1, SWT.CENTER | SWT.MULTI);
	text1.setText("Text 1" ~ Text.DELIMITER ~ 
				  "Resize sashform " ~ Text.DELIMITER ~ "Read count in Text 2");

	Text text2 = new Text(sashForm1, SWT.CENTER | SWT.MULTI);
	text2.setText("Text 2");

	sashForm2 = new SashForm(sashForm1, SWT.VERTICAL);

	Label label1 = new Label(sashForm2, SWT.BORDER | SWT.CENTER);
	label1.setText("Label 1\n\nDouble-click to hide/show Button 1");

	Button button1 = new Button(sashForm2, SWT.PUSH);
	button1.setText("Button1: Push to reset after resizing sashform");

	text2.addControlListener(new class ControlListener {
		override public void controlMoved(ControlEvent e) {
		}

		override public void controlResized(ControlEvent e) {
			text2.setText("Text 2" ~ Text.DELIMITER ~ format("Resize Count: %s", count++));
		}
    });

	int[] weights = [2,1,3];

    sashForm1.setWeights(weights);

	label1.addMouseListener(new class MouseListener {
		override public void mouseDoubleClick(MouseEvent e) {
			if(sashForm2.getMaximizedControl() == label1)
				sashForm2.setMaximizedControl(null);
			else
				sashForm2.setMaximizedControl(label1);
		}

		public void mouseDown(MouseEvent e) {

		}

		public void mouseUp(MouseEvent e) {
		}
	});

	button1.addSelectionListener(new class SelectionAdapter {
		override public void widgetSelected(SelectionEvent e)
		{
			tabItem[13].setControl(getTab[13](tabFolder));
		}
	});

	return group;
}

private Control getProgressTab(TabFolder tabFolder) {

	//todo crash if null entered in the spinner control
	//add progressbar group?

    Group group;
    Spinner minimumSpinner, selectionSpinner, maximumSpinner;
	ProgressBar progressBar1, progressBar2, progressBar3, progressBar4, progressBar5;

    group = new Group (tabFolder, SWT.NONE);
    group.setLayout (new GridLayout ());
    group.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
    //group.setText ("ProgressBar");

	//max group

    Group maximumGroup = new Group (group, SWT.NONE);
    maximumGroup.setText ("Maximum");
    maximumGroup.setLayout (new GridLayout ());
    maximumGroup.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));

    maximumSpinner = new Spinner (maximumGroup, SWT.BORDER | SWT.READ_ONLY);
    maximumSpinner.setMaximum (100000);
    maximumSpinner.setSelection (100);
    maximumSpinner.setPageIncrement (100);
    maximumSpinner.setIncrement (1);
    maximumSpinner.setLayoutData (new GridData (SWT.FILL, SWT.CENTER, true, false));

	maximumSpinner.addSelectionListener(new class SelectionAdapter {
	    override public void widgetSelected(SelectionEvent event) {
	        progressBar1.setMaximum (maximumSpinner.getSelection ());
	        progressBar3.setMaximum (maximumSpinner.getSelection () - maximumSpinner.getSelection ());
	        progressBar5.setMaximum (maximumSpinner.getSelection ());
	    }
	});


	//min group

    Group minimumGroup = new Group (group, SWT.NONE | SWT.READ_ONLY);
    minimumGroup.setText ("Minimum");
    minimumGroup.setLayout (new GridLayout ());
    minimumGroup.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));

    minimumSpinner = new Spinner (minimumGroup, SWT.BORDER);
    minimumSpinner.setMaximum (100000);
    minimumSpinner.setSelection(0);
    minimumSpinner.setPageIncrement (100);
    minimumSpinner.setIncrement (1);
    minimumSpinner.setLayoutData (new GridData (SWT.FILL, SWT.CENTER, true, false));

    minimumSpinner.addSelectionListener (new class SelectionAdapter {
        override public void widgetSelected (SelectionEvent event) {
			progressBar1.setMinimum (minimumSpinner.getSelection ());
			progressBar3.setMinimum (maximumSpinner.getSelection () - minimumSpinner.getSelection ());
			progressBar5.setMinimum (minimumSpinner.getSelection ());
        }
    });

	//selection group

    Group selectionGroup = new Group (group, SWT.NONE | SWT.READ_ONLY);
    selectionGroup.setText ("Selection");
    selectionGroup.setLayout (new GridLayout ());
    selectionGroup.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));

	selectionSpinner = new Spinner (selectionGroup, SWT.BORDER);
	selectionSpinner.setMaximum (100000);
	selectionSpinner.setSelection (50);
	selectionSpinner.setPageIncrement (100);
	selectionSpinner.setIncrement (1);
	selectionSpinner.setLayoutData (new GridData (SWT.FILL, SWT.CENTER, true, false));

	selectionSpinner.addSelectionListener(new class SelectionAdapter {
		override public void widgetSelected(SelectionEvent event) {
			progressBar1.setSelection (selectionSpinner.getSelection ());
			progressBar3.setSelection (maximumSpinner.getSelection () - selectionSpinner.getSelection ());
			progressBar5.setSelection (selectionSpinner.getSelection ());
		}
	});

    selectionSpinner.setEnabled (true);
    minimumSpinner.setEnabled (true);
    maximumSpinner.setEnabled (true);

	//progress group

	Group progressGroup = new Group (group, SWT.NONE | SWT.READ_ONLY);
    progressGroup.setText ("Progress Bars");
	GridLayout gridLayout = new GridLayout();
	gridLayout.numColumns = 5;
	progressGroup.setLayout (gridLayout);
    progressGroup.setLayoutData (new GridData (GridData.FILL_HORIZONTAL));
	
	progressBar1 = new ProgressBar (progressGroup, SWT.VERTICAL);
	progressBar1.setMaximum (maximumSpinner.getSelection ());
	progressBar1.setMinimum (minimumSpinner.getSelection ());
	progressBar1.setSelection (selectionSpinner.getSelection ());

	progressBar2 = new ProgressBar (progressGroup, SWT.INDETERMINATE);

	progressBar3 = new ProgressBar (progressGroup, SWT.VERTICAL | SWT.SMOOTH);
	progressBar3.setMaximum (maximumSpinner.getSelection ());
	progressBar3.setMinimum (minimumSpinner.getSelection ());
	progressBar3.setSelection (selectionSpinner.getSelection ());

	progressBar4 = new ProgressBar (progressGroup, SWT.INDETERMINATE | SWT.SMOOTH);

	progressBar5 = new ProgressBar (progressGroup, SWT.VERTICAL | SWT.BORDER);
	progressBar5.setMaximum (maximumSpinner.getSelection ());
	progressBar5.setMinimum (minimumSpinner.getSelection ());
	progressBar5.setSelection (selectionSpinner.getSelection ());

	return group;
}

private Control getMenuTab(TabFolder tabFolder) {

	Menu menuBar, fileMenu, helpMenu, cascadeMenu;
	MenuItem fileMenuHeader, fileSaveItem, fileExitItem;
	MenuItem helpMenuHeader, helpAboutItem;
	MenuItem cascadeMenuHeader, pushItem, checkItem, radioItem;

	Label label;
	enum ncols = 4;
	bool oldRadioState = false;
	string state;

	Group group = new Group (tabFolder, SWT.NONE);
	GridLayout gridLayout = new GridLayout();
	gridLayout.numColumns = ncols;
    gridLayout.makeColumnsEqualWidth = false;
	group.setLayout (gridLayout);

	Button btnShow = new Button (group, SWT.PUSH);
	btnShow.setText("Show Menu");

	Button btnHide = new Button (group, SWT.PUSH);
	btnHide.setText("Hide Menu");

	Button btnClear = new Button (group, SWT.PUSH);
	btnClear.setText("Clear Text");

	Label labelWidget = new Label (group, SWT.NONE);
	labelWidget.setText("Right click for Popup Menu");
	labelWidget.setVisible(false);

	Text textWidget = new Text(group, SWT.MULTI | SWT.BORDER | SWT.READ_ONLY);
	GridData gdText = new GridData (SWT.FILL, SWT.FILL, true, true);
	gdText.horizontalSpan = ncols;
	textWidget.setLayoutData (gdText);

	
	btnShow.addSelectionListener(new class SelectionAdapter {
		override public void widgetSelected(SelectionEvent e)
		{
			labelWidget.setVisible(true);

			menuBar = new Menu(shell, SWT.BAR);

			//file menu

			fileMenuHeader = new MenuItem(menuBar, SWT.CASCADE);
			fileMenuHeader.setText("&File");

			fileMenu = new Menu(shell, SWT.DROP_DOWN);
			fileMenuHeader.setMenu(fileMenu);

			fileSaveItem = new MenuItem(fileMenu, SWT.PUSH);
			fileSaveItem.setText("&Save");
			fileSaveItem.addListener(SWT.Selection, new class Listener {
				override public void handleEvent(Event event) {
					textWidget.append("item selected: SAVE" ~ Text.DELIMITER);
				}
			});

			fileExitItem = new MenuItem(fileMenu, SWT.PUSH);
			fileExitItem.setText("E&xit");
			fileExitItem.addListener(SWT.Selection, new class Listener {
				override public void handleEvent(Event event) {
					textWidget.append("item selected: EXIT" ~ Text.DELIMITER);
				}
			});

			//help menu

			helpMenuHeader = new MenuItem(menuBar, SWT.CASCADE);
			helpMenuHeader.setText("&Help");

			helpMenu = new Menu(shell, SWT.DROP_DOWN);
			helpMenuHeader.setMenu(helpMenu);

			helpAboutItem = new MenuItem(helpMenu, SWT.PUSH);
			helpAboutItem.setText("&About");
			helpAboutItem.addListener(SWT.Selection, new class Listener {
				override public void handleEvent(Event event) {
					textWidget.append("item selected: ABOUT" ~ Text.DELIMITER);
				}
			});

			//cascade menu

			cascadeMenuHeader = new MenuItem(menuBar, SWT.CASCADE);
			cascadeMenuHeader.setText("&CASCADE menu");

			cascadeMenu = new Menu(shell, SWT.DROP_DOWN);
			cascadeMenuHeader.setMenu(cascadeMenu);

			pushItem = new MenuItem(cascadeMenu, SWT.PUSH);
			pushItem.setText("&PUSH item\tCtrl+P");
			pushItem.addListener(SWT.Selection, new class Listener {
				override public void handleEvent(Event event) {
					textWidget.append("item selected: PUSH item" ~ Text.DELIMITER);
				}
			});

			checkItem = new MenuItem(cascadeMenu, SWT.CHECK);
			checkItem.setText("CHEC&K item\tCtrl+K");
			checkItem.setAccelerator(SWT.CTRL + 'K');
			checkItem.addListener(SWT.Selection, new class Listener {
				override public void handleEvent(Event event) {
					if (checkItem.getSelection()) {
						state = "Checked";
					} else {
						state = "Unchecked";
					}
					textWidget.append("item selected: CHECK item is " ~ state ~ Text.DELIMITER);
				}
			});

			new MenuItem(cascadeMenu, SWT.SEPARATOR).setText("test");

			radioItem = new MenuItem(cascadeMenu, SWT.RADIO);
			radioItem.setText("&RADIO item\tCtrl+R");
			radioItem.setAccelerator(SWT.CTRL + 'R');
			radioItem.addListener(SWT.Selection, new class Listener {
				override public void handleEvent(Event event) {
					bool newRadioState = radioItem.getSelection();
					//new state == true
					//if old state == true then new state and old state = false
					//if old state == false then new state and old state = true
					if (oldRadioState) {
						radioItem.setSelection(false);
						oldRadioState = false;
						newRadioState = false;
						state = "Unchecked";
					} else {
						radioItem.setSelection(true);
						oldRadioState = true;
						newRadioState = true;
						state = "Checked";
					}
					textWidget.append("item selected: RADIO item is " ~ state ~ Text.DELIMITER);
				}
			});

			//popup menu

			Menu menu = new Menu (shell, SWT.POP_UP);
			MenuItem item1 = new MenuItem (menu, SWT.PUSH);
			item1.setText ("Push Item");
			MenuItem item20 = new MenuItem (menu, SWT.CHECK);
			item20.setText ("Check Item");
			MenuItem item2 = new MenuItem (menu, SWT.CASCADE);
			item2.setText ("Cascade Item");
			Menu subMenu = new Menu (menu);
			item2.setMenu (subMenu);
			MenuItem subItem1 = new MenuItem (subMenu, SWT.PUSH);
			subItem1.setText ("Subitem 1");
			MenuItem subItem2 = new MenuItem (subMenu, SWT.PUSH);
			subItem2.setText ("Subitem 2");

			labelWidget.setMenu (menu);
			textWidget.setMenu (menu);
			group.setMenu (menu);

			//dropdown menu

			//Menu menuDropDown = new Menu (shell, SWT.DROP_DOWN);
			//MenuItem item10 = new MenuItem (menuDropDown, SWT.PUSH);
			//item10.setText ("Push Item");
			//MenuItem item11 = new MenuItem (menuDropDown, SWT.CHECK);
			//item11.setText ("Check Item");
			//MenuItem item12 = new MenuItem (menuDropDown, SWT.CASCADE);
			//item12.setText ("Cascade Item");
			//Menu subMenu = new Menu (menuDropDown);
			//item12.setMenu (subMenu);
			//MenuItem subItem10 = new MenuItem (subMenu, SWT.PUSH);
			//subItem10.setText ("Subitem 1");
			//MenuItem subItem11 = new MenuItem (subMenu, SWT.PUSH);
			//subItem11.setText ("Subitem 2");
			//labelWidget.setMenu (menuDropDown);

			//show the menu bar

			shell.setMenuBar(menuBar);
			
		}
	});

	btnHide.addSelectionListener(new class SelectionAdapter {
		override public void widgetSelected(SelectionEvent e)
		{
			labelWidget.setVisible(false);
			shell.setMenuBar(null);
		}
	});

	btnClear.addSelectionListener(new class SelectionAdapter {
		override public void widgetSelected(SelectionEvent e)
		{
			textWidget.setText(null);
		}
	});

	return group;
}

private Control getListTab(TabFolder tabFolder) {

	Label label;
	List list;
    Group listGroup;
	enum nitems = 20;
	enum horizontalIndent = 30;
	enum textWidgetInstructions = "Select items in SWT.MULTI above";

    string[nitems] listData;

	for (int i; i<nitems; i++) {
		listData [i] = format("Item number %s", i);
	}

	listGroup = new Group (tabFolder, SWT.NONE);
	GridLayout gridLayout = new GridLayout();
	gridLayout.numColumns = 5;
    gridLayout.makeColumnsEqualWidth = true;
	listGroup.setLayout (gridLayout);

    //listGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, false));
    //listGroup.setText ("List");

	GridData gdLabel = new GridData (SWT.FILL, SWT.CENTER, false, false);
	gdLabel.horizontalIndent = horizontalIndent;

	label = new Label (listGroup, SWT.NONE);
	label.setText("SWT.SINGLE");
	label.setLayoutData (gdLabel);
	label = new Label (listGroup, SWT.NONE);
	label.setText("SWT.MULTI");
	label.setLayoutData (gdLabel);
	label = new Label (listGroup, SWT.NONE);
	label.setText("SWT.H_SCROLL");
	label.setLayoutData (gdLabel);
	label = new Label (listGroup, SWT.NONE);
	label.setText("SWT.V_SCROLL");
	label.setLayoutData (gdLabel);
	label = new Label (listGroup, SWT.NONE);
	label.setText("SWT.BORDER");
	label.setLayoutData (gdLabel);

	GridData gdList = new GridData (SWT.FILL, SWT.CENTER, false, false);
	gdList.widthHint = 90;
	gdList.heightHint = 200;
	gdList.horizontalIndent = horizontalIndent;

	list = new List (listGroup, SWT.SINGLE);
    list.setItems (listData);
	list.setLayoutData (gdList);

	List listMulti = new List (listGroup, SWT.MULTI);
    listMulti.setItems (listData);
	listMulti.setLayoutData (gdList);

	list = new List (listGroup, SWT.H_SCROLL);
    list.setItems (listData);
	list.setLayoutData (gdList);

	list = new List (listGroup, SWT.V_SCROLL);
    list.setItems (listData);
	list.setLayoutData (gdList);

	list = new List (listGroup, SWT.BORDER);
    list.setItems (listData);
	list.setLayoutData (gdList);

	new Label (listGroup, SWT.NONE);

	Text textWidget = new Text(listGroup, SWT.MULTI | SWT.BORDER | SWT.READ_ONLY);
	GridData gdText = new GridData (SWT.FILL, SWT.FILL, false, true);
	gdText.horizontalSpan = 5;
	gdText.horizontalIndent = horizontalIndent;
	textWidget.setLayoutData (gdText);
	textWidget.setText(textWidgetInstructions);

	Button btnReset = new Button (listGroup, SWT.PUSH);
	btnReset.setText("Reset");
	btnReset.setLayoutData (gdLabel);

	listMulti.addSelectionListener(new class SelectionAdapter {
		override public void widgetSelected(SelectionEvent e)
		{
			string[] selections = listMulti.getSelection();
			string outText;
			textWidget.setText("You selected: " ~ Text.DELIMITER);
			for (int j=0; j < selections.length; j++) {
				//outText ~= selections[j] ~ ", ";
				//textWidget.append("You selected: " ~ outText ~ Text.DELIMITER);
				textWidget.append(selections[j] ~ Text.DELIMITER);
			}
		}
	});

	btnReset.addSelectionListener(new class SelectionAdapter {
		override public void widgetSelected(SelectionEvent e)
		{
			textWidget.setText(textWidgetInstructions);
			listMulti.deselectAll();
		}
	});

	return listGroup;
}

private Control getLinkTab(TabFolder tabFolder) {

	Group linkGroup;
	Link link;

	linkGroup = new Group (tabFolder, SWT.NONE);
	GridLayout gridLayout = new GridLayout();
	gridLayout.numColumns = 2;
    gridLayout.makeColumnsEqualWidth = false;
	linkGroup.setLayout (gridLayout);
	//linkGroup.setText ("Link");

	int style = 0;
	style |= SWT.NONE;

	new Label (linkGroup, SWT.NONE).setText("Click on the links: ");

	link = new Link (linkGroup, style);
	link.setText ("For more information about the D language, visit <a>dlang.org</a> or <a>code.dlang.org</a>");

	new Label(linkGroup, SWT.NONE);
	new Label(linkGroup, SWT.NONE);

	Label lblSelection = new Label (linkGroup, SWT.NONE);
	lblSelection.setText("Selection: ");

	GridData gd = new GridData ();
	gd.widthHint = 150;

	Text txtSelection = new Text (linkGroup, SWT.NONE);
	txtSelection.setText("");
	txtSelection.setLayoutData (gd);

	link.addListener(SWT.Selection, new class Listener {
		override public void handleEvent(Event event) {
			txtSelection.setText(event.text);
		}
	});

	return linkGroup;
}

private Control getLabelTab(TabFolder tabFolder) {

	Group group = new Group (tabFolder, SWT.NONE);
	GridLayout gridLayout = new GridLayout();
	gridLayout.numColumns = 2;
    gridLayout.makeColumnsEqualWidth = false;
	group.setLayout (gridLayout);
	//group.setText ("Label");

	Group textLabelGroup = new Group(group, SWT.NONE);
	gridLayout = new GridLayout ();
	gridLayout.numColumns = 3;
	gridLayout.makeColumnsEqualWidth = true;
	textLabelGroup.setLayout (gridLayout);
	textLabelGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
	textLabelGroup.setText ("Text Labels");

	//textLabelGroup.setBackground(display.getSystemColor(SWT.COLOR_GRAY));

	/* Create a group for the image labels */
	Group imageLabelGroup = new Group (group, SWT.SHADOW_NONE);
	GridLayout gridLayout2 = new GridLayout ();
	gridLayout2.numColumns = 3;
	gridLayout2.makeColumnsEqualWidth = true;
	imageLabelGroup.setLayout (gridLayout2);
	imageLabelGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));
	imageLabelGroup.setText ("Image Labels");

	GridData gd = new GridData ();
	gd.widthHint = 150;
	gd.heightHint = 50;
	Label label;

	//text group

	new Label(textLabelGroup, SWT.NONE);
	new Label(textLabelGroup, SWT.NONE);
	new Label(textLabelGroup, SWT.NONE);

	label = new Label (textLabelGroup, SWT.BORDER | SWT.HORIZONTAL | SWT.CENTER);
	label.setText("SWT.HORIZONTAL");
	label.setLayoutData (gd);

	label = new Label (textLabelGroup, SWT.BORDER | SWT.VERTICAL | SWT.CENTER);
	label.setText("SWT.VERTICAL");
	label.setLayoutData (gd);

	label = new Label(textLabelGroup, SWT.NONE);

	new Label(textLabelGroup, SWT.NONE);
	new Label(textLabelGroup, SWT.NONE);
	new Label(textLabelGroup, SWT.NONE);

	label = new Label (textLabelGroup, SWT.BORDER | SWT.SHADOW_IN);
	label.setText("SWT.SHADOW_IN");
	label.setLayoutData (gd);

	label = new Label (textLabelGroup, SWT.BORDER | SWT.SHADOW_OUT);
	label.setText("SWT.SHADOW_OUT");
	label.setLayoutData (gd);

	new Label(textLabelGroup, SWT.NONE);

	new Label(textLabelGroup, SWT.NONE);
	new Label(textLabelGroup, SWT.NONE);
	new Label(textLabelGroup, SWT.NONE);

	label = new Label (textLabelGroup, SWT.BORDER);
	label.setText("SWT.BORDER This is a long line that doesn't wrap");
	label.setLayoutData (gd);

	label = new Label (textLabelGroup, SWT.BORDER | SWT.WRAP);
	label.setText("SWT.WRAP This is a long line that wraps");
	label.setLayoutData (gd);

	label = new Label(textLabelGroup, SWT.NONE);

	new Label(textLabelGroup, SWT.NONE);
	new Label(textLabelGroup, SWT.NONE);
	new Label(textLabelGroup, SWT.NONE);

	label = new Label (textLabelGroup, SWT.BORDER | SWT.LEFT);
	label.setText("SWT.LEFT");
	label.setLayoutData (gd);

	label = new Label (textLabelGroup, SWT.BORDER | SWT.CENTER);
	label.setText("SWT.CENTER");
	label.setLayoutData (gd);

	label = new Label (textLabelGroup, SWT.BORDER | SWT.RIGHT);
	label.setText("SWT.RIGHT");
	label.setLayoutData (gd);

	new Label(textLabelGroup, SWT.NONE);
	new Label(textLabelGroup, SWT.NONE);
	new Label(textLabelGroup, SWT.NONE);

	label = new Label (textLabelGroup, SWT.NONE | SWT.WRAP);
	label.setText("SWT.SEPARATORS: HORIZONTAL, VERTICAL");
	label.setLayoutData (gd);

	label = new Label (textLabelGroup, SWT.SEPARATOR | SWT.HORIZONTAL);
	label.setText("SWT.SEPARATOR");
	label.setLayoutData (gd);

	label = new Label (textLabelGroup, SWT.SEPARATOR | SWT.VERTICAL);
	label.setText("SWT.SEPARATOR");
	label.setLayoutData (gd);

	//image group
	label = new Label (imageLabelGroup, SWT.BORDER);
	label.setImage (closedFolderImage);
	label = new Label (imageLabelGroup, SWT.BORDER);
	label.setImage (openFolderImage);
	label = new Label(imageLabelGroup, SWT.BORDER);
	label.setImage (targetImage);

	return group;
}

private Control getGroupTab(TabFolder tabFolder) {

	Group group = new Group (tabFolder, SWT.NONE);

	GridLayout gridLayout = new GridLayout();
	gridLayout.numColumns = 3;
    gridLayout.makeColumnsEqualWidth = true;
	group.setLayout (gridLayout);

	Group group1 = new Group (group, SWT.SHADOW_ETCHED_IN);
	group1.setText("SWT.SHADOW_ETCHED_IN");
	group1.setLayout(new FillLayout());

	Label label = new Label(group1, SWT.NULL);
    label.setAlignment(SWT.CENTER);
    label.setText("\nOne\n\n");

	Group group2 = new Group (group, SWT.SHADOW_ETCHED_OUT);
	group2.setText("SWT.SHADOW_ETCHED_OUT");
	group2.setLayout(new FillLayout());

	Label label2 = new Label(group2, SWT.NULL);
    label2.setAlignment(SWT.CENTER);
    label2.setText("\nTwo\n\n");

	new Label(group, SWT.NONE);

	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);

	Group group3 = new Group (group, SWT.SHADOW_IN);
	group3.setText("SWT.SHADOW_IN");
	group3.setLayout(new FillLayout());

	Label label3 = new Label(group3, SWT.NULL);
    label3.setAlignment(SWT.CENTER);
    label3.setText("\nThree\n\n");

	Group group4 = new Group (group, SWT.SHADOW_OUT);
	group4.setText("SWT.SHADOW_OUT");
	group4.setLayout(new FillLayout());

	Label label4 = new Label(group4, SWT.NULL);
    label4.setAlignment(SWT.CENTER);
    label4.setText("\nFour\n\n");

	Group group5 = new Group (group, SWT.SHADOW_NONE);
	group5.setText("SWT.SHADOW_NONE");
	group5.setLayout(new FillLayout());

	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);

	Label label5 = new Label(group5, SWT.NULL);
    label5.setAlignment(SWT.CENTER);
    label5.setText("\nFive\n\n");

	Group group6 = new Group (group, SWT.BORDER);
	group6.setText("SWT.BORDER");
	group6.setLayout(new FillLayout());

	Label label6 = new Label(group6, SWT.NULL);
	label6.setAlignment(SWT.CENTER);
	label6.setText("\nSix\n\n");

	Group group7 = new Group (group, SWT.NULL);
	group7.setText("SWT.NULL");
	group7.setLayout(new FillLayout());

	Label label7 = new Label(group7, SWT.NULL);
    label7.setAlignment(SWT.CENTER);
    label7.setText("\nSeven\n\n");

	return group;
}

private Control getExpandBarTab(TabFolder tabFolder) {

	Group group = new Group (tabFolder, SWT.NONE);
	group.setLayout(new FillLayout());
	//group.setText ("ExpandBar");

	ExpandBar expandBar = new ExpandBar (group, SWT.V_SCROLL);

	// First item
	Composite composite = new Composite (expandBar, SWT.NONE);
	GridLayout layout = new GridLayout ();
	layout.marginLeft = layout.marginTop = layout.marginRight = layout.marginBottom = 10;
    layout.verticalSpacing = 10;
    composite.setLayout(layout);
	//composite.setLayout(new GridLayout ());
	(new Button (composite, SWT.PUSH)).setText("SWT.PUSH");
	(new Button (composite, SWT.RADIO)).setText("SWT.RADIO");
	(new Button (composite, SWT.CHECK)).setText("SWT.CHECK");
	(new Button (composite, SWT.TOGGLE)).setText("SWT.TOGGLE");
	ExpandItem item = new ExpandItem (expandBar, SWT.NONE, 0);
	item.setText("Item1");
	item.setHeight(composite.computeSize(SWT.DEFAULT, SWT.DEFAULT).y);
	item.setControl(composite);
	item.setImage(closedFolderImage);

	// Second item
	composite = new Composite (expandBar, SWT.NONE);
    layout = new GridLayout (2, false);
    layout.marginLeft = layout.marginTop = layout.marginRight = layout.marginBottom = 10;
    layout.verticalSpacing = 10;
    composite.setLayout(layout); 
	(new Label (composite, SWT.NONE)).setImage(display.getSystemImage(SWT.ICON_ERROR));
	(new Label (composite, SWT.NONE)).setText("SWT.ICON_ERROR");
	(new Label (composite, SWT.NONE)).setImage(display.getSystemImage(SWT.ICON_INFORMATION));
	(new Label (composite, SWT.NONE)).setText("SWT.ICON_INFORMATION");
	(new Label (composite, SWT.NONE)).setImage(display.getSystemImage(SWT.ICON_WARNING));
	(new Label (composite, SWT.NONE)).setText("SWT.ICON_WARNING");
	(new Label (composite, SWT.NONE)).setImage(display.getSystemImage(SWT.ICON_QUESTION));
	(new Label (composite, SWT.NONE)).setText("SWT.ICON_QUESTION");
	item = new ExpandItem (expandBar, SWT.NONE, 1);
	item.setText("Item2");
	item.setHeight(composite.computeSize(SWT.DEFAULT, SWT.DEFAULT).y);
	item.setControl(composite);
	item.setImage(openFolderImage);
	item.setExpanded(true);

    // Third item
    composite = new Composite (expandBar, SWT.NONE);
    layout = new GridLayout (2, true);
    layout.marginLeft = layout.marginTop = layout.marginRight = layout.marginBottom = 10;
    layout.verticalSpacing = 10;
    composite.setLayout(layout);
    Label label = new Label (composite, SWT.NONE);
    label.setText("Scale"); 
    new Scale (composite, SWT.NONE);
    label = new Label (composite, SWT.NONE);
    label.setText("Spinner");   
    new Spinner (composite, SWT.BORDER);
    label = new Label (composite, SWT.NONE);
    label.setText("Slider");    
    new Slider (composite, SWT.NONE);
    item = new ExpandItem (expandBar, SWT.NONE, 2);
    item.setText("Item3: What is your favorite range widget?");
    item.setHeight(composite.computeSize(SWT.DEFAULT, SWT.DEFAULT).y);
    item.setControl(composite);
    item.setImage(targetImage);

	//item1.setExpanded(true);
    expandBar.setSpacing(8);

	return group;
}
private Control getDialogTab(TabFolder tabFolder) {

	string[] FilterExtensions   = ["*.txt", "*.bat", "*.doc", "*"];
     string[] FilterNames = [ "Text (.txt)", "Batch (.bat)", "Doc (.doc)", "All (.*)"];

	Group group = new Group (tabFolder, SWT.NONE);

	//group.setLayout (new GridLayout ());
	//GridData gridData = new GridData (GridData.HORIZONTAL_ALIGN_CENTER);
	//gridData.horizontalSpan = 2;
	//group.setLayoutData (gridData);
	//group.setText("Dialog Type");

	GridLayout gridLayout = new GridLayout();
	gridLayout.numColumns = 3;
    gridLayout.makeColumnsEqualWidth = false;
	group.setLayout (gridLayout);

	string[] strings = [
		"ColorDialog", "DirectoryDialog", "FileDialog", "FontDialog", "PrintDialog", "MessageBox",
	];

	new Label(group, SWT.LEFT).setText("Choose Dialog to Demo: ");

	Combo combo = new Combo (group, SWT.READ_ONLY);
	combo.setItems (strings);
	combo.setText (strings [0]);
	combo.setVisibleItemCount(cast (int) strings.length);

	Button btnReset = new Button(group, SWT.NONE);
	btnReset.setText ("Reset Text");

	Text textWidget = new Text(group, SWT.H_SCROLL | SWT.V_SCROLL | SWT.BORDER);
	GridData gridData = new GridData (GridData.FILL_BOTH);
	gridData.horizontalSpan = 3;
	textWidget.setLayoutData(gridData);
	Font initialFont = textWidget.getFont();

	btnReset.addSelectionListener (new class() SelectionAdapter {
		override public void widgetSelected (SelectionEvent event) {
			textWidget.setText("");
			textWidget.setBackground(display.getSystemColor(SWT.COLOR_LIST_BACKGROUND));
			textWidget.setFont(initialFont);
		}
	});

	combo.addSelectionListener (new class() SelectionAdapter {
		override public void widgetSelected (SelectionEvent event) {

			string name = combo.getText();

			if (name == "ColorDialog") {
				ColorDialog dialog = new ColorDialog (shell);
				dialog.setRGB (new RGB (100, 100, 100));
				dialog.setText ("Title");
				RGB rgb = dialog.open ();
				textWidget.append ("ColorDialog" ~ Text.DELIMITER);
				string result;
				if (rgb is null) {
					result = "null";
				} else {
					result = rgb.toString();
				}
				textWidget.append ("Result: " ~ result ~ Text.DELIMITER ~ Text.DELIMITER);
				Color backgroundColor;
				if(rgb !is null){
					backgroundColor = new Color(display, rgb);
					textWidget.setBackground(backgroundColor);
				}
				if(backgroundColor !is null) backgroundColor.dispose();
				return;
			}

			if (name == "DirectoryDialog") {
				DirectoryDialog dialog = new DirectoryDialog (shell);
				dialog.setMessage ("Example");
				dialog.setText ("Title");
				string result = dialog.open ();
				textWidget.append ("DirectoryDialog" ~ Text.DELIMITER);
				textWidget.append ("Result: " ~ result ~ Text.DELIMITER ~ Text.DELIMITER);
				return;
			}

			if (name == "FileDialog") {
				FileDialog dialog = new FileDialog (shell);
				dialog.setFileName ("readme.txt");
				dialog.setFilterNames (FilterNames);
				dialog.setFilterExtensions (FilterExtensions);
				dialog.setText ("Title");
				string result = dialog.open();
				textWidget.append ("FileDialog" ~ Text.DELIMITER);
				textWidget.append ("Result: " ~ result ~ Text.DELIMITER);
				if ((dialog.getStyle () & SWT.MULTI) !is 0) {
					string[] files = dialog.getFileNames ();
					for (int i=0; i<files.length; i++) {
						textWidget.append ("\t" ~ files [i] ~ Text.DELIMITER);
					}
				}
				textWidget.append (Text.DELIMITER);
				return;
			}

			if (name == "FontDialog") {
				FontDialog dialog = new FontDialog (shell);
				dialog.setText ("Title");
				FontData fontData = dialog.open ();
				textWidget.append ("FontDialog" ~ Text.DELIMITER);
				textWidget.append (format("Result: %s", fontData ) ~ Text.DELIMITER ~ Text.DELIMITER);
				Font font;
				if(fontData !is null){
					font = new Font(display, fontData);
					textWidget.setFont(font);
				}
				if(font !is null) font.dispose();
				return;
			}

			if (name == "PrintDialog") {
				PrintDialog dialog = new PrintDialog (shell);
				dialog.setText("Title");
				PrinterData result = dialog.open ();
				textWidget.append ("PrintDialog" ~ Text.DELIMITER);
				textWidget.append (format( "Result: %s", result ) ~ Text.DELIMITER ~ Text.DELIMITER);
				textWidget.append ("TODO - fix PrintDialog, Snippet133 won't work either!");
				textWidget.append (Text.DELIMITER ~ Text.DELIMITER);
				return;
			}

			if (name == "MessageBox") {
				MessageBox dialog = new MessageBox (shell, SWT.ICON_INFORMATION);
				dialog.setMessage ("This is a MessageBox demo");
				dialog.setText ("Title");
				int result = dialog.open ();
				textWidget.append ("MessageBox" ~ Text.DELIMITER);
				textWidget.append (format( "Result: %s", result ) ~ Text.DELIMITER ~ Text.DELIMITER);
			}

		}
	});

	return group;
}
private Control getDateTimeTab(TabFolder tabFolder) {

    Group group = new Group (tabFolder, SWT.NONE);

	GridLayout gridLayout = new GridLayout();
	gridLayout.numColumns = 3;
    gridLayout.makeColumnsEqualWidth = true;
	group.setLayout(gridLayout);

	new Label(group, SWT.LEFT).setText("Short Date Format");
	new Label(group, SWT.LEFT).setText("Medium Date Format");
	new Label(group, SWT.LEFT).setText("Long Date Format");

	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);

	new DateTime (group, SWT.DATE | SWT.SHORT);
	new DateTime (group, SWT.DATE | SWT.MEDIUM);
	new DateTime (group, SWT.DATE | SWT.LONG);

	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);

	new Label(group, SWT.LEFT).setText("Short Time Format");
	new Label(group, SWT.LEFT).setText("Medium Time Format");
	new Label(group, SWT.LEFT).setText("Long Time Format");

	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);

	new DateTime (group, SWT.TIME | SWT.SHORT);
	new DateTime (group, SWT.TIME | SWT.MEDIUM);
	new DateTime (group, SWT.TIME | SWT.LONG);

	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);

	Label label = new Label(group, SWT.CENTER);
	label.setText("Calendar");
	GridData gridData = new GridData(SWT.FILL, SWT.FILL, true, false);
	gridData.horizontalSpan = 3;
	label.setLayoutData(gridData);

	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);
	new Label(group, SWT.NONE);

	DateTime dt = new DateTime (group, SWT.CALENDAR);
	gridData = new GridData(SWT.FILL, SWT.FILL, true, false);
	gridData.horizontalSpan = 3;
	dt.setLayoutData(gridData);

	return group;
}

private Control getCoolBarTab(TabFolder tabFolder) {
	
    CoolBar coolBar;
    CoolItem pushItem, dropDownItem, radioItem, checkItem, textItem;
    Group coolBarGroup;

   Point size;
   Point coolSize;

    Point[] sizes;
    int[] wrapIndices;
    int[] order;

    coolBarGroup = new Group (tabFolder, SWT.NONE);
    coolBarGroup.setLayout (new GridLayout ());
    coolBarGroup.setLayoutData (new GridData (SWT.FILL, SWT.FILL, true, true));

    int style = 0;
	int itemStyle = 0;
	
    int toolBarStyle = SWT.FLAT;
    bool vertical = false;
    style |= SWT.HORIZONTAL;
    toolBarStyle |= SWT.HORIZONTAL;
	itemStyle |= SWT.DROP_DOWN;

    coolBar = new CoolBar (coolBarGroup, style);

    ToolBar toolBar = new ToolBar (coolBar, toolBarStyle);
    ToolItem item = new ToolItem (toolBar, SWT.PUSH);
    item.setImage (openFolderImage);
    item.setToolTipText ("SWT.PUSH");
    item = new ToolItem (toolBar, SWT.PUSH);
    item.setImage (closedFolderImage);
    item.setToolTipText ("SWT.PUSH");
    item = new ToolItem (toolBar, SWT.PUSH);
    item.setImage (targetImage);
    item.setToolTipText ("SWT.PUSH");
    item = new ToolItem (toolBar, SWT.SEPARATOR);
    item = new ToolItem (toolBar, SWT.PUSH);
    item.setImage (openFolderImage);
    item.setToolTipText ("SWT.PUSH");
    item = new ToolItem (toolBar, SWT.PUSH);
    item.setImage (closedFolderImage);
    item.setToolTipText ("SWT.PUSH");
    pushItem = new CoolItem (coolBar, 0);
    pushItem.setControl (toolBar);
	//todo pushItem.addSelectionListener (new CoolItemSelectionListener());

    toolBar = new ToolBar (coolBar, toolBarStyle);
    item = new ToolItem (toolBar, SWT.DROP_DOWN);
    item.setImage (openFolderImage);
    item.setToolTipText ("SWT.DROP_DOWN");
    item = new ToolItem (toolBar, SWT.DROP_DOWN);
    item.setImage (closedFolderImage);
    item.setToolTipText ("SWT.DROP_DOWN");
    dropDownItem = new CoolItem (coolBar, itemStyle);
    dropDownItem.setControl (toolBar);
	//todo dropDownItem.addSelectionListener (new CoolItemSelectionListener());

    toolBar = new ToolBar (coolBar, toolBarStyle);
    item = new ToolItem (toolBar, SWT.RADIO);
    item.setImage (closedFolderImage);
    item.setToolTipText ("SWT.RADIO");
    item = new ToolItem (toolBar, SWT.RADIO);
    item.setImage (closedFolderImage);
    item.setToolTipText ("SWT.RADIO");
    item = new ToolItem (toolBar, SWT.RADIO);
    item.setImage (closedFolderImage);
    item.setToolTipText ("SWT.RADIO");
    radioItem = new CoolItem (coolBar, itemStyle);
    radioItem.setControl (toolBar);
	//todo radioItem.addSelectionListener (new CoolItemSelectionListener());

    toolBar = new ToolBar (coolBar, toolBarStyle);
    item = new ToolItem (toolBar, SWT.CHECK);
    item.setImage (closedFolderImage);
    item.setToolTipText ("SWT.CHECK");
    item = new ToolItem (toolBar, SWT.CHECK);
    item.setImage (targetImage);
    item.setToolTipText ("SWT.CHECK");
    item = new ToolItem (toolBar, SWT.CHECK);
    item.setImage (openFolderImage);
    item.setToolTipText ("SWT.CHECK");
    item = new ToolItem (toolBar, SWT.CHECK);
    item.setImage (targetImage);
    item.setToolTipText ("SWT.CHECK");
    checkItem = new CoolItem (coolBar, itemStyle);
    checkItem.setControl (toolBar);
	//todo checkItem.addSelectionListener (new CoolItemSelectionListener());

    Text text = new Text (coolBar, SWT.BORDER | SWT.SINGLE);
    textItem = new CoolItem (coolBar, itemStyle);
    textItem.setControl (text);
	//todo textItem.addSelectionListener (new CoolItemSelectionListener())

    CoolItem[] coolItems = coolBar.getItems();
    for (int i = 0; i < coolItems.length; i++) {
        CoolItem coolItem = coolItems[i];
        Control control = coolItem.getControl();
        size = control.computeSize(SWT.DEFAULT, SWT.DEFAULT);
        coolSize = coolItem.computeSize(size.x, size.y);
        if ( auto bar = cast(ToolBar)control ) {
            if (bar.getItemCount() > 0) {
                if (vertical) {
                    size.y = bar.getItem(0).getBounds().height;
                } else {
                    size.x = bar.getItem(0).getWidth();
                }
            }
        }
        coolItem.setMinimumSize(size);
        coolItem.setPreferredSize(coolSize);
        coolItem.setSize(coolSize);
    }

	new Label(coolBarGroup, SWT.LEFT).setText(
		"Use the controls to resize the cool bar widgets, then press to reset: ");

    Button b1 = new Button(coolBarGroup, SWT.PUSH);
    b1.setText("Reset");
    
    b1.addSelectionListener(new class SelectionAdapter
    {
        override public void widgetSelected(SelectionEvent e)
	    {
			tabItem[3].setControl(getTab[3](tabFolder));
        }
    });
    
	return coolBarGroup;        
}

private Control getComboTab(TabFolder tabFolder) {
	
	static string[] ListData;

    ListData = ["ListData0", "ListData1", "ListData2",  "ListData3", "ListData4",
				"ListData5", "ListData6", "ListData7", "ListData8"];

	Composite composite = new Composite(tabFolder, SWT.NONE);
	GridLayout gridLayout = new GridLayout();
	gridLayout.numColumns = 3;
	composite.setLayout(gridLayout);
	
	Group demoGroup = new Group(composite, SWT.NONE);
	gridLayout.numColumns = 3;
	demoGroup.setLayout(gridLayout);
	//demoGroup.setText("Combo");

	
	new Label(demoGroup, SWT.LEFT).setText("Simple: ");
    new Label(demoGroup, SWT.LEFT).setText("Dropdown: ");
    new Label(demoGroup, SWT.LEFT).setText("Read Only: ");

    Combo combo1 = new Combo (demoGroup, SWT.SIMPLE);
    combo1.setItems (ListData);
    if (ListData.length >= 3) {
        combo1.setText(ListData[2]);
    }
    
    GridData gridData = new GridData();
	gridData.verticalSpan = 2;
	gridData.grabExcessVerticalSpace = true;
	combo1.setLayoutData(gridData);

    Combo combo2 = new Combo (demoGroup, SWT.DROP_DOWN);
    combo2.setItems (ListData);
    if (ListData.length >= 3) {
        combo2.setText(ListData[2]);
    }

    Combo combo3 = new Combo (demoGroup, SWT.READ_ONLY);
    combo3.setItems (ListData);
    if (ListData.length >= 3) {
        combo3.setText(ListData[2]);
    }

	return composite;
}

private Control getCanvasTab(TabFolder tabFolder) {

    /* Example widgets and groups that contain them */
    Canvas canvas;
    Group canvasGroup;

    int paintCount;
    int cx, cy;
    int maxX, maxY;

	static const int[] colors = [
        SWT.COLOR_LIST_BACKGROUND,
        SWT.COLOR_RED,
        SWT.COLOR_GREEN,
        SWT.COLOR_BLUE,
        SWT.COLOR_MAGENTA,
        SWT.COLOR_YELLOW,
        SWT.COLOR_CYAN,
        SWT.COLOR_DARK_RED,
        SWT.COLOR_DARK_GREEN,
        SWT.COLOR_DARK_BLUE,
        SWT.COLOR_DARK_MAGENTA,
        SWT.COLOR_DARK_YELLOW,
        SWT.COLOR_DARK_CYAN
    ];

    const string canvasString = "Resize Window to Change Color";

	Composite composite = new Composite(tabFolder, SWT.NONE);
	composite.setLayout(new FillLayout());

	Group buttonGroup = new Group(composite, SWT.BORDER);
	buttonGroup.setLayout(new RowLayout()); //normal button
	//buttonGroup.setLayout(new FillLayout()); //large button
	//buttonGroup.setText("Button");

    Button b1 = new Button(buttonGroup, SWT.PUSH);
    b1.setText("Change Color");

    b1.addSelectionListener(new class SelectionAdapter
		{
			override public void widgetSelected(SelectionEvent e)
			{
				canvas.redraw();
			}
		});

    canvasGroup = new Group (composite, SWT.NONE);
	canvasGroup.setLayout(new FillLayout(SWT.VERTICAL));
    //canvasGroup.setText ("Canvas Demo");

    paintCount = 0; cx = 0; cy = 0;
    canvas = new Canvas (canvasGroup, SWT.NONE);
    canvas.addPaintListener(new class() PaintListener {
        public void paintControl(PaintEvent e) {
            paintCount++;
            GC gc = e.gc;
            Color color = e.display.getSystemColor (colors [paintCount % colors.length]);
            gc.setBackground(color);
            gc.fillRectangle(e.x, e.y, e.width, e.height);
            Point size = canvas.getSize();
            gc.drawArc(cx + 1, cy + 1, size.x - 2, size.y - 2, 0, 360);
            gc.drawRectangle(cx + (size.x - 10) / 2, cy + (size.y - 10) / 2, 10, 10);
            Point extent = gc.textExtent(canvasString);
            gc.drawString(canvasString, cx + (size.x - extent.x) / 2, cy - extent.y + (size.y - 10) / 2, true);
        }
    });
    
	return composite;
}

private Control getTextTab(TabFolder tabFolder) {

	immutable textLine = "The quick brown fox jumped over the very lazy hogs.";
	immutable ncols = 3;

	Group group = new Group (tabFolder, SWT.NONE);
	GridLayout gridLayout = new GridLayout();
	gridLayout.numColumns = ncols;
	group.setLayout (gridLayout);
	//demoGroup.setText ("Text");

	Button b1 = new Button(group, SWT.PUSH);
    b1.setText("Set Text");

	Button b2 = new Button(group, SWT.PUSH);
    b2.setText("Append Text");

	Button b3 = new Button(group, SWT.PUSH);
    b3.setText("Clear Text");

	Text text = new Text (group, SWT.BORDER | SWT.MULTI );
	GridData gdText = new GridData (SWT.FILL, SWT.FILL, true, true);
	gdText.horizontalSpan = ncols;
	text.setLayoutData (gdText);
	
    b1.addSelectionListener(new class SelectionAdapter
    {
        override public void widgetSelected(SelectionEvent e)
	    {
			text.setText(textLine ~ Text.DELIMITER);
        }
    });
    
    b2.addSelectionListener(new class SelectionAdapter
		{
			override public void widgetSelected(SelectionEvent e)
			{
				text.append(textLine ~ Text.DELIMITER);
			}
		});

    b3.addSelectionListener(new class SelectionAdapter
		{
			override public void widgetSelected(SelectionEvent e)
			{
				text.setText("");
			}
		});

	return group;
}

private Control getButtonTab(TabFolder tabFolder) {

	Composite composite = new Composite(tabFolder, SWT.NONE);
	composite.setLayout(new FillLayout(SWT.VERTICAL));

	Group g1 = new Group(composite, SWT.NONE);
	g1.setText("Text Buttons");
	GridLayout gridLayout = new GridLayout();
	gridLayout.numColumns = 9;
	g1.setLayout (gridLayout);

	new Label(g1, SWT.LEFT).setText("Push: ");
	new Button(g1, SWT.PUSH).setText("One");
	new Button(g1, SWT.PUSH).setText("Two");
	new Button(g1, SWT.PUSH).setText("Three");

	new Label(g1, SWT.NONE);

	new Label(g1, SWT.LEFT).setText("Check: ");
	new Button(g1, SWT.CHECK).setText("One");
	new Button(g1, SWT.CHECK).setText("Two");
	new Button(g1, SWT.CHECK).setText("Three");

	new Label(g1, SWT.LEFT).setText("Toggle: ");
	new Button(g1, SWT.TOGGLE).setText("One");
	new Button(g1, SWT.TOGGLE).setText("Two");
	new Button(g1, SWT.TOGGLE).setText("Three");

	new Label(g1, SWT.NONE);

	new Label(g1, SWT.LEFT).setText("Radio: ");
	new Button(g1, SWT.RADIO).setText("One");
	new Button(g1, SWT.RADIO).setText("Two");
	new Button(g1, SWT.RADIO).setText("Three");

	new Label(g1, SWT.LEFT).setText("Arrow: ");
	new Button(g1, SWT.ARROW).setText("One");
	new Button(g1, SWT.ARROW).setText("Two");
	new Button(g1, SWT.ARROW).setText("Three");

	Group g2 = new Group(composite, SWT.SHADOW_OUT);
	g2.setText("Image Buttons");
	g2.setLayout(new GridLayout(2, true));
	g2.setLayoutData(new GridData(GridData.HORIZONTAL_ALIGN_FILL | GridData.VERTICAL_ALIGN_FILL));
	g2.setLayout(new RowLayout(SWT.HORIZONTAL));

	new Button(g2, SWT.PUSH).setImage(closedFolderImage);
	new Button(g2, SWT.PUSH).setImage(openFolderImage);
	new Button(g2, SWT.PUSH).setImage(targetImage);

	Group g3 = new Group(composite, SWT.SHADOW_OUT);
	g3.setText("Image and Text Buttons");
	g3.setLayout(new GridLayout(2, true));
	g3.setLayoutData(new GridData(GridData.HORIZONTAL_ALIGN_FILL | GridData.VERTICAL_ALIGN_FILL));

	g3.setLayout(new RowLayout(SWT.HORIZONTAL));
	Button b1 = new Button(g3, SWT.PUSH);
	b1.setText("One");
	b1.setImage(closedFolderImage);
	b1 = new Button(g3, SWT.PUSH);
	b1.setText("Two");
	b1.setImage(openFolderImage);
	b1 = new Button(g3, SWT.PUSH);
	b1.setText("Three");
	b1.setImage(targetImage);

	return composite;
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

void setShellSizeCenter() {
	
	Point size = shell.computeSize(SWT.DEFAULT, SWT.DEFAULT);
	Rectangle monitorArea = shell.getMonitor().getClientArea();
	//shell.setSize(min(size.x +100, monitorArea.width), min(size.y, monitorArea.height));
	shell.setSize(monitorArea.width/2, monitorArea.height/2);

	centerShell();

}

void LoadImageFromThisExe() {

	//dispose previous image, if any
 	imageDispose(shellIcon);

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
    if (hIcon !is null) shellIcon = Image.win32_new (null, SWT.ICON, hIcon);

    //show the icon, if null then show the default icon for exe files 
   	shell.setImage (shellIcon);
}

void imageDispose(Image sourceImage) {
    if (sourceImage !is null && !sourceImage.isDisposed()) {
	    sourceImage.dispose();
        sourceImage = null;
    }
}

void doClose()
{
	imageDispose(closedFolderImage);
	imageDispose(openFolderImage);
	imageDispose(targetImage);
	imageDispose(shellIcon);
	display.close();
}
