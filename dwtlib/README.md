[![LICENSE](https://img.shields.io/badge/License-EPL%201.0-red.svg)](https://code.dlang.org/packages/dwtlib)
[![Build Status](https://travis-ci.org/jasc2v8/dwtlib.svg?branch=master)](https://travis-ci.org/jasc2v8/dwtlib) 
[![Dub Downloads](https://img.shields.io/dub/dt/dwtlib.svg)](https://code.dlang.org/packages/dwtlib)

## dwtlib - Alternate DUB package for the D Widget Toolkit

[DWT](https://github.com/d-widget-toolkit/dwt) is a library for creating cross-platform GUI applications.
It's a port of the [SWT](http://www.eclipse.org/swt) Java library from Eclipse.

[dwtlib](https://github.com/jasc2v8/dwtlib) is a dub package repository for DWT.

## Status

WORKING and tested on:

	- Windows 10 Home  32-bit and 64-bit
	- Ubuntu 16.04 LTS 32-bit and 64-bit
	- DMD32 D Compiler v2.074.0, DUB version 1.3.0
    
## Building (refer to doc/dlang-install)

1. Install DMD (includes DUB)

    - Browse to http://dlang.org/
    - Click to download the lastest version
    - Click to download the latest version (e.g. 2.074.0)
    - Open with Software install (Ubuntu)
    - Install

    Check Version
    
        $ dmd --version
        DMD32 D Compiler vX.XX.X
        
        $ dub --version
        DUB version X.X.X

    Quick Test
    
        $ rdmd examples/console/hello.d

2. Fetch the DUB package

		$ dub fetch dwtlib

3. Get the linux libraries (no extra libs required for Windows):

        $ cd /home/<USER>/.dub/packages/dwtlib-X.X.X/dwtlib/tools/get-libs
        $ cd /home/<USER>/.dub/packages/dwtlib-3.1.1/dwtlib/tools/get-libs

		$ bash ./get-libs.sh

4. Build the DWT static libraries:

		$ cd /home/<USER>/.dub/packages/dwtlib-X.X.X/dwtlib

		$ dub fetch dwtlib
		$ cd /home/<USER>/.dub/packages/dwtlib-3.1.1/dwtlib

		Ubuntu  32-bit and 64-bit: $ bash ./build_dwtlib.bat
		Windows 32-bit           : $ build_dwtlib.bat
		Windows 64-bit           : $ build_dwtlib_m64.bat

		$ cd ../examples

		Ubuntu : $ bash ./example.sh
		Windows: $ example.bat
	
5.	Add a dependency to your app's dub.json or dub.sdl, see the examples.
		
		dependency "dwtlib" version=">=3.1.1"

## Snippets

Run Snippets in the examples folder:

	$ example_console
        $ example_gui
        $ snippets_demo
        $ widgets_demo (this demo currently works on Windows only)

Or, run Snippets using rdub in the examples folder:

        $ rdmd rdub snippets\Snippet251 --force
        
Here is a screenshot of the widgets_demo (a simplified version of the SWT controlexample):

![Settings Window](https://raw.github.com/jasc2v8/dwtlib/master/examples/demo/widgetdemo.png)
	
