#dwt-support

##Load Icon Demo

###Objectives

 1. Help for new D programmers and hobbyists
 2. Make it more fun and enjoyable to learn D with DWT GUI apps
 3. Advance the use of the D language

###Overview

This is a demo of the various methods to extract and load icons in DWT.

It is written in modular form so each function can be reused in your code.

The key takeway is the Win32 API LoadImage function.

Use to set the Shell icon from the program icon linked with icons.res in this exe file.

1. Edit \res\icons.rc to include your icons
2. Compile with rcc.bat
3. Compile loadicon with either DUB (uses dub.json) or DMD (dmd_loadicon.bat)
4. Launch and press the NEXT button to see the icons change
5. Refer to the doNext function and follow the code to the numbered function
 
The minimum recommended display size for this demo is 1024x768 (maximize window for 800x600) 
