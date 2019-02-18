/*
 * Copyright (C) 2017 by jasc2v8 at yahoo dot com
 * License: http://www.boost.org/LICENSE_1_0.txt
 *
 * This is a demo of the various methods to extract and load icons in DWT
 * It is written in modular form so each function can be reused in your code
 * 
 * The key takeway is the Win32 API LoadImage function, used to -
 *     set the Shell icon from the program icon linked with icons.res in this exe file
 *
 * 1. Edit \res\icons.rc to include your icons
 * 2. Compile with rcc.bat
 * 3. Compile loadicon with either DUB (uses dub.json) or DMD (dmd_loadicon.bat)
 * 4. Launch and press the NEXT button to see the icons change
 * 5. Refer to the doNext function and follow the code to the numbered function
 * 
 * The minimum recommended display size for this demo is 1024x768 (maximize window for 800x600) 
*/

module loadicon;

//d lang imports
import std.stdio;			//writeln
import std.conv;			//to!string
import std.file;			//thisExePath
import std.path;			//baseName

//dwt imports
import org.eclipse.swt.all;

//Win32 imports
import org.eclipse.swt.internal.win32.OS;

//Globals
Display display;
Shell shell;
Image image;
Font normFont;
Label label;
Label icon;
int count;

/*
	 1-Set Icon from External File
	 2-Set Icon from Program *.inf
	 3-Load Icon from this EXE
	 4-Load Icon from Windows Predefined icons
	 5-Load Image from External File
	 6-Load Image from This EXE
	 7-Load image from OEM Icon
	 8-Extract Icon from Resource, index 0 (this exe)
	 9-index 1
	 10-index 2
	 11-index 3
	 12-index 4
	 Extract Icon from an Application Icon
	 Extract Icon from External File
	 NOT included:
	 Set Icon from SWT SystemImage
	 http://www.java2s.com/Tutorial/Java/0280__SWT/UsingSystemIconImage.htm
*/
	 
void main () {

	buildShell();
	
    shell.setText("Load Icon Demo");
    
    shell.open ();
	    
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    
    display.dispose ();
}

void setIconFromFile() {
	
	//dispose and erase previous image, if any
	imageDispose(image);
	
	//load icon from external file
	image = new Image(display, r"res\iconD.ico");
	
	//set as shell icon
    shell.setImage(image);
}

void setIconFromProgram(string ext) {
	//help: Program.d line 80
	//load an icon asscociated with a program that is in the windows registry
	//Program.getImageData returns a small icon only

	imageDispose(image);

	Program p = Program.findProgram (ext);

    if (p !is null) {
        ImageData imageData = p.getImageData ();
        if (imageData !is null) {
            image = new Image (display, imageData);
            shell.setImage (image);
        }
    }
}

void LoadIconFromThisExe() {
	
	/*
	help: Browser search msdn LoadIcon, and Display.d line 2610
	Loads the specified icon resource from the executable (.exe) file associated with an application instance
	This function has been superseded by the LoadImage function, use it instead of this one
	*/
	
	//dispose and erase previous image, if any
	imageDispose(image);

	//get the handle for this.exe
	auto hMod = OS.GetModuleHandle(null);
	
	//the name of the icon in the .res file is IDI_ICON
    //LPCWSTR MYICON  = StrToWCHARz ("IDI_ICON");
    
    //get the icon handle from the exe using the given index string
 	//auto hIcon = OS.LoadIcon(hMod, MYICON);

    //alternate combine the two lines above into one line
 	auto hIcon = OS.LoadIcon(hMod, StrToWCHARz ("IDI_ICON"));

	//alternate method using cast versus StrToWCHARz
 	//auto hIcon = OS.LoadIcon(hMod, cast(wchar*)"IDI_ICON");

    //alternate get the icon handle of the default application
    //in other words, the icon in the Windows Registry for .exe files
 	//auto hIcon = OS.LoadIcon(hMod, cast(wchar*)IDI_APPLICATION);

	//if handle is found, get the image
    if (hIcon !is null) image = Image.win32_new (null, SWT.ICON, hIcon);
    
    //show the icon, if null then show the default icon for exe files 
   	shell.setImage (image);

}

void LoadIconFromPredefined() {
	
	/*
	help: Browser search msdn LoadIcon, and Display.d line 2610
	Loads a Windows predefined icon
	This function has been superseded by the LoadImage function, use it instead of this one
	
	help: WINAPI.d, not all of the Windows predefined icons are defined (not worth the effort)
	Line 2320:     IDI_APPLICATION
	Line 2321:     IDI_HAND
	Line 2322:     IDI_QUESTION
	Line 2323:     IDI_EXCLAMATION
	Line 2324:     IDI_ASTERISK
	Line 2325:     IDI_WINLOGO = Windows 200 only
	*/
	
	//dispose and erase previous image, if any
	imageDispose(image);

	//get the handle for this.exe
	auto hMod = OS.GetModuleHandle(null);
	
    //get the handle of a predefined icon
 	auto hIcon = OS.LoadIcon(null, cast(wchar*)IDI_EXCLAMATION);

	//if handle is found, get the image
    if (hIcon !is null) image = Image.win32_new (null, SWT.ICON, hIcon);
    
    //show the icon, if null then show the default icon for exe files 
   	shell.setImage (image);

}

void LoadImageFromFile() {

	//dispose and erase previous image, if any
	imageDispose(image);

	//load and external icon
	string filename = r"res\iconD.ico";

	//convert
    LPCWSTR lpszName  = StrToWCHARz (filename);
 	
 	//int LR_LOADFROMFILE = 0x00000010;
 	auto hIcon = OS.LoadImage(null, lpszName, OS.IMAGE_ICON, 0, 0, LR_LOADFROMFILE);
 	
	//if handle is found, get the image
    if (hIcon !is null) image = Image.win32_new (null, SWT.ICON, hIcon);
    
    //show the icon, if null then show the default icon for exe files 
   	shell.setImage (image);
	
}

void LoadImageFromThisExe() {
	//browser search msdn LoadImage
	//Display.d line 2438
	//Winapi.d  Line 1998 HANDLE LoadImageA(HINST, LPCSTR, UINT, int, int, UINT); //ansi
	//Winapi.d  line 2398 HANDLE LoadImageW(HINST, LPCWSTR, UINT, int, int, UINT); //unicode
	
	//dispose previous image, if any
 	imageDispose(image);

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

void LoadImageOEM() {
	//browser search msdn LoadImage
	//Display.d line 2438
	//Winapi.d  Line 1998 HANDLE LoadImageA(HINST, LPCSTR, UINT, int, int, UINT); //ansi
	//Winapi.d  line 2398 HANDLE LoadImageW(HINST, LPCWSTR, UINT, int, int, UINT); //unicode
	
	//dispose previous image, if any
 	imageDispose(image);

	//get the handle for this.exe
	auto hMod = OS.GetModuleHandle(null);
	
   	//load a OEM icon
	//OS.OIC_WINLOGO wont load because it's only available in Windows 2000
	auto hIcon = OS.LoadImage (null, cast(wchar*)OS.OIC_QUES, OS.IMAGE_ICON, 0, 0, OS.LR_SHARED);
	
	//if handle is found, get the image
    if (hIcon !is null) image = Image.win32_new (null, SWT.ICON, hIcon);
    
    //show the icon, if null then show the default icon for exe files 
   	shell.setImage (image);
   	
}

void ExtractIconFromResource(string filename, int index) {
	//msdn ExtractIcon
	//creates an array of handles to large or small icons extracted from exe, DLL, or icon file
	//Program.d line 368
	//load an embeded resource icon from a file
	//designed to set the shell icon from this exe that has an embedded icon

	//dispose previous image, if any
 	imageDispose(image);

	//set index
    int nIconIndex = index;
    int nIcons=1;

	//convert filename
    StringT lpszFile = StrToTCHARs (0, filename, true);
    
    //extract icon
    HICON [1] phiconSmall, phiconLarge;
    OS.ExtractIconEx (lpszFile.ptr, nIconIndex, phiconLarge.ptr, phiconSmall.ptr, nIcons);    
    image = Image.win32_new (null, SWT.ICON, phiconLarge [0]); //Image.d line 2151
    
    //show the icon, if null then show the default icon for exe files 
   	shell.setImage (image);
}

void doNext() {
	count++;	
	switch (count)
	{
	    default:
		    count = 1;
	        goto case;
        case 1:
		    setIconFromFile();
			icon.setImage(image);
			label.setText("\n  1. Shell icon set from external file res\\iconD.ico");
            break;
        case 2:
		    setIconFromProgram(".inf");
			icon.setImage(image);
            label.setText("\n  2. Shell icon set from Program '.inf' file association in Windows registry");
            break;
        case 3:
            LoadIconFromThisExe();
			icon.setImage(image);
			label.setText("\n  3. Win32 API LoadIcon IDI_ICON (this exe icon)");
            break;
        case 4:
            LoadIconFromPredefined();
			icon.setImage(image);
			label.setText("\n  4. Win32 API LoadIcon IDI_SHIELD (Windows predefined icon)");
            break;
	    case 5:
		    LoadImageFromFile();
			icon.setImage(image);
			label.setText("\n  5. Win32 API LoadImage from external file res\\iconD.ico");
		    break;
        case 6:
	        LoadImageFromThisExe();
			icon.setImage(image);
			label.setText("\n  6. Win32 API LoadImage IDI_ICON (this exe icon)");
            break;
        case 7:
            LoadImageOEM();
			icon.setImage(image);
            label.setText("\n  7. Win32 API LoadImage OEM icon");
            break;
        case 8:
	        ExtractIconFromResource(r"res\\iconD.ico", 0);
			icon.setImage(image);
            label.setText("\n  8. Win32 API ExtractImagex from external file res\\iconD.ico");
            break;
        case 9:
	        ExtractIconFromResource(thisExePath(), 0);
			icon.setImage(image);
            label.setText("\n  9. Win32 API ExtractImagex from linked resource.res, index 0 (this exe icon)");
            break;
        case 10:
	        ExtractIconFromResource(thisExePath(), 1);
			icon.setImage(image);
            label.setText("\n  10. Win32 API ExtractImagex from linked resource.res, index 1");
            break;
        case 11:
	        ExtractIconFromResource(thisExePath(), 2);
			icon.setImage(image);
            label.setText("\n  11. Win32 API ExtractImagex from linked resource.res, index 2");
            break;
        case 12:
	        ExtractIconFromResource(thisExePath(), 3);
			icon.setImage(image);
            label.setText("\n  12. Win32 API ExtractImagex from linked resource.res, index 3");
            break;
        case 13:
	        ExtractIconFromResource(thisExePath(), 4);
			icon.setImage(image);
            label.setText("\n  13. Win32 API ExtractImagex from linked resource.res, index 4");
            break;
	}
}

void buildShell() {
	
 	display = new Display ();
    shell = new Shell (display);
   	shell.setBackground(display.getSystemColor(SWT.COLOR_BLACK));

    RowLayout rowLayout = new RowLayout();
    shell.setLayout(rowLayout);
    
    FontData defaultFont = shell.getFont().getFontData()[0];
    normFont = new Font(display, defaultFont.getName(), 14, SWT.NORMAL);

    label = new Label(shell, SWT.BORDER);
	label.setFont(normFont);
	label.setBackground(display.getSystemColor(SWT.COLOR_LIST_BACKGROUND));
    label.setLayoutData(new RowData(680, 64));
    
    icon = new Label(shell, SWT.BORDER | SWT.CENTER);
	icon.setBackground(display.getSystemColor(SWT.COLOR_LIST_BACKGROUND));
    icon.setLayoutData(new RowData(64, 64));
    
    Button next = new Button (shell, SWT.PUSH);
   	next.setFont(normFont);
    next.setLayoutData(new RowData(64, 69));
    next.setText ("NEXT");
    
    //show an initial icon for exe files
    setIconFromProgram(".exe");
	icon.setImage(image);
    label.setText("\n  Keep pressing the NEXT button to change the icon");

   	shell.pack ();
   	centerShell(shell);
   	
    //Button listener
    next.addSelectionListener(new class SelectionAdapter {
        override
        public void widgetSelected(SelectionEvent e) {
           	doNext();
        }
    });
    
    //Shell Close
    shell.addListener(SWT.Close, new class Listener
    {
	    public void handleEvent(Event e)
	    {
	        //e.doit = false;
	        //doCancel();
	        normFont.dispose();
	        imageDispose(image);
	    }
    });
}

void imageDispose(Image sourceImage) {
    if (sourceImage !is null && !sourceImage.isDisposed()) {
	    sourceImage.dispose();
        sourceImage = null;
    }
}

void centerShell(Shell shell)
{
    Monitor primary = display.getPrimaryMonitor();
    Rectangle bounds = primary.getBounds();
    Rectangle rect = shell.getBounds();

    int x = bounds.x + (bounds.width - rect.width) / 2;
    int y = bounds.y + (bounds.height - rect.height) / 2;

    shell.setLocation(x, y);
}