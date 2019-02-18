# Config DWT GUI for Eclipse DDT on Windows

##Reference

The [d-widget-toolkit](https://www.github.com/d-widget-toolkit/dwt) on GitHub
 * The "Building" instructions from the `README.markdown` document
 * The `build.d` file

## Introduction

**DWT - D Widget Toolkit**

1. DWT is a library for creating cross-platform GUI applications
1. It's a port of the SWT Java library from Eclipse
1. DWT is compatible with D2 using the standard library (Phobos)

## Objectives
1. Help new D programmers and hobbyists to config DWT for Eclipse DDT on Windows
1. Make it more fun and enjoyable to learn D with a stable and easy to use gui
1. Advance the use of the D language
 
## High-Level Overview
1. Start with Windows 10 Home (or other compatible Windows version)
1. Install DMD, the D2 language compiler (includes DUB, the D2 language package manager)
1. Install Eclipse
1. Install the Eclipse DDT plugin
1. Clone the DWT repository from GitHub
1. Build the cloned DWT library on your local PC
1. Create a new DUB project in Eclipse with DDT called "hello-dwt"
1. Edit the dub.json file to link with the DWT library on your local PC
1. Enter the D code for a simple "Hellow World" window using DWT
1. Run hello-dwt. If successful, a simple "Hello World!" window will appear
1. Modify the Build Target for a "release" build version

## Step-by-Step Instructions
1. Start with Windows 10 Home (or other compatible Windows version)
 - *test version: 10.0.14393 Build 14393*
1. Install DMD (includes DUB)
 - Download DMD from [dlang.org](https://www.dlang.org), press `Install.exe`
 - *test version: DMD32 D Compiler v2.073.0*
1. Install Eclipse
 - Download from [eclipse.org](https://www.eclipse.org/downloads), click "Get Eclipe Neon", press the orange button `DOWNLOAD 64 BIT`
 - This will download the installer: `eclipse-inst-win64.exe`
 - Select **"Eclipse IDE for Java Developers"**
 - *test version: Neon.2 Release (4.6.2), Build id: 20161208-0600*
1. Install DDT plugin
 - In Eclipse: Help, Eclipse Marketplace, Search, Find: DDT, Install
 - Do **not** exit Eclipse
 - *test version: D Development Tools 1.0.3.v201611011228*
1. Clone the DWT repository from GitHub
 - Download from [d-widget-toolkit](https://www.github.com/d-widget-toolkit/dwt), press the green button, `Clone or download`
 - *(do not download because it will download the folders only, not everything)*
 - Copy the git uri to clipboard `https://github.com/d-widget-toolkit/dwt.git`
 - In Eclispe: File, import, Git, Projects from Git, Clone URI
 - Paste the git uri for DWT, press Next
 - Select the master branch, press Next
 - Enter your local directory `E:\DEV\Data\GitHub\dwt`
 - **CHECK** `Clone submodules`, press Next
 - Do ***not*** import into the project, press Cancel
1. Build the DWT library on your local PC
 - Copy the Git clone:
 
	  - From: your local git repository `E:\DEV\Data\GitHub\dwt`
	  - To:   your local lib directory  `E:\DEV\Libs\dwt`
	  
 - Open a command window in your local lib directory:
 
	```dos
	E:\DEV\Libs\dwt>
	```

 - Enter the rdmd build command, then press ENTER to execute:
 
	```dos
	E:\DEV\Libs\dwt>rdmd build.d base swt
	```
	
 - You should see the following command line output during the short build process:

	```dos
	E:\DEV\Libs\dwt> rdmd build.d base swt
	(in E:\DEV\Libs\dwt)
	Building dwt-base
	workdir=>E:\DEV\Libs\dwt\base\src
	dmd.exe @E:\DEV\Libs\dwt\rsp
	dmd.exe @E:\DEV\Libs\dwt\rsp > E:\DEV\Libs\dwt\olog.txt
	Building org.eclipse.swt.win32.win32.x86
	workdir=>E:\DEV\Libs\dwt\org.eclipse.swt.win32.win32.x86\src
	dmd.exe @E:\DEV\Libs\dwt\rsp
	dmd.exe @E:\DEV\Libs\dwt\rsp > E:\DEV\Libs\dwt\olog.txt
	E:\DEV\Libs\dwt>
	```

 - Create a simple DUB Project, "Hellow World" 
 - Eclipse with DDT: File, New, Other, D, DUB Project, press Next,
 - Enter Project name: `hello-dwt`, press Finish
1. Edit the dub.json file to link with the DWT library on your local PC
 - In the hello-dwt project: Open the `dub.json` file,
 - Replace the entire contents with the following:
	
	```json
	{
		"name": "hello-dwt",
		"description": "Hello World - A minimal DUB bundle.",
		"dflags": ["-Ie:\\dev\\libs\\dwt\\imp\\",
			"-Je:\\dev\\libs\\dwt\\res\\"],
		"lflags": ["-L+e:\\dev\\libs\\dwt\\lib\\",
			" -L+e:\\dev\\libs\\dwt\\lib\\org.eclipse.swt.win32.win32.x86.lib",
			" -L+e:\\dev\\libs\\dwt\\lib\\dwt-base.lib",
			" /SUBSYSTEM:WINDOWS:4.0"]
	}
	```
	
 - Edit the above for your local lib path: e:\\dev\\libs\\dwt)
 - Note the required space before the dash in lines 7 and 8 above: " -L+e..."

1. Enter the D code for a simple "Hellow World" window using DWT
 - In the `hello-dwt` project:
 - Open the `app.d` file, and replace the entire contents with the following:
	
	```d
	import org.eclipse.swt.widgets.Display;
	import org.eclipse.swt.widgets.Shell;
	void main ()
	{
		auto display = new Display;
		auto shell = new Shell;
		shell.setText("Hello World!");
		shell.open();
		while (!shell.isDisposed)
			if (!display.readAndDispatch())
				display.sleep();
		display.dispose();
	}
	```

1. Run `hello-dwt`
 - Eclipse menu: Run, Run As, 1 D Application
 - If successful, a simple "Hello World!" window will appear.
	
	```
	Hello World!
	```

1. Modify the Build Target for a "release" build version
 - Eclispe DDT comes with only two Build Targets - default and unittest
 - The default target builds a "debug" version, and the unittest target builds a "unittest" version
 - Currently, you cannot create a build rarget "release", so here is a work-around:
 - Eclipse menu: Run, Run Configurations, double-click on "D Application"
 - Build Command: UNcheck "Use Build Target Settings"
 - Default is: ${DUB_TOOL_PATH} build
 - Modfiy  to: ${DUB_TOOL_PATH} build -b=release-nobounds
 - Note that by default, a DUB release build is -release -O -inline, we just added the nobounds
 - Here is the impact on the exe size with my Windows environment:
	  - "debug" version of hellow-dwt = 2,580 KB
	  - "release" version of hellow-dwt = 714 KB
	  - After upx --brute compression = 615 KB *(the use of upx is not included in this document)*
