#Key Differences Between DWT 32 and 64 bit

##Reference
The [d-widget-toolkit](https://www.github.com/d-widget-toolkit/dwt) (DWT) on GitHub:

* The `README.markdown` document
* The `build.d` file

Note: References to `E:\DEV\lib\dwt` and `E:\DEV\lib\dwt64` below are the cloned copies of DWT from GitHub in my test environment. Edit to match your local PC environment

##DWT 32 bit Notes

1. Requires [DMD](https://www.dlang.org) and [DWT](https://www.github.com/d-widget-toolkit/dwt)
1. The DWT clone includes the windows libs `E:\DEV\lib\dwt\lib\advapi32.lib` etc.
1. The DMD linker links the DWT windows libs to build 32 bit GUI apps

##DWT 64 bit Notes

1. Requires DMD, DWT, and the Microsoft Visual Studio (MVS) environment
1. The DWT clone build process removes the Windows libs `E:\DEV\lib\dwt64\lib\advapi32.lib` etc.
1. The MVS linker links the installed Windows 64 bit libs to build 64 bit GUI apps

		/LIBPATH:"C:\Program Files (x86)\Windows Kits\10\\lib\10.0.10586.0\ucrt\x64" 

1. The MVS tools are not required to build the DWT library
1. However, the MVS linker is required for DMD to build and link 64 bit DWT GUI apps

##Building DWT 64 bit

1. Install [DMD](https://www.dlang.org) , [DWT](https://www.github.com/d-widget-toolkit/dwt), and the Microsoft Visual Studio (MVS) environment (web search for the current download location)
2. Alternatively, instead of the huge MVS environment, you can install the significantly smaller Visual C++ 2015 x64 Native Build Tools, currenlty located [here.](http://landinghub.visualstudio.com/visual-cpp-build-tools) Be sure to read the notes about the compatiablility between this install and the full Visual Studio suite.
3. Clone the DWT from GitHub library to your local PC, and identify it as the 64 bit library `E:\DEV\lib\dwt64`
4. Build the cloned DWT 64 bit library on your local PC.  You do **not** need the MVS environment to build the DWT lib

	```
	E:\DEV\Libs\dwt64>rdmd build.d base swt -m64
	```
	
1. Launch the `Visual C++ 2015 x64 Native Build Tools Command Prompt` (see instructions from the version you installed)

		C:\Program Files (x86)\Microsoft Visual C++ Build Tools>
		C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\amd64>

1. Compile, link, and run your 64 bit DWT GUI app, for example the `hellow-world` app:

		dmd src\%source% res\resource.res -m64 -release -O  -boundscheck=off ^
			-I%DWT%\imp -J%DWT%\res -L/LIBPATH:%DWT%\lib ^
			"-Lorg.eclipse.swt.win32.win32.x86.lib" "-Ldwt-base.lib" ^
			-L/SUBSYSTEM:Windows -L/ENTRY:mainCRTStartup -L/RELEASE 

##64 bit Link Errors

If you get an error that the linker cannot find `advapi32.lib`, try the following:

1. add the -v (verbose) switch to the build command above
1. Look for the LIBPATH where the MVS linker is looking for the Windows libs
1. Example: `/LIBPATH:"C:\Program Files (x86)\Windows Kits\10\\lib\10.0.10586.0\ucrt\x64"`
1. I have installed and removed MVS and components, so this path no longer existed on my PC
1. As a temporoary work-around, I did copid an existing path:

	`/LIBPATH:"C:\Program Files (x86)\Windows Kits\10\\lib\10.0.14393\ucrt\x64"`
	
1. Pasted it and renamed to what my linker needed:

	`/LIBPATH:"C:\Program Files (x86)\Windows Kits\10\\lib\10.0.10586\ucrt\x64"`

1. Do this at your own risk, the proper action for me is to clean up my MVS install

##How to check if your app is 32 or 64 bit
1. In Windows, right-click on the exe file you want to check
1. Select “Properties”
1. Click the tab “Compatibility”
1. In the section "Compatibility mode"
1. Check the box under "Run this program in compatibility mode for:"
1. Open the drop-down menu that lists operating systems
1. If the list begins with Vista, then the file is 64-bit
1. If the list begins with Window 95, or includes Windows XP, then the file is 32-bit
1. Press the cancel button to avoid making any changes
