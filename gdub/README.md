[![Dub version](https://img.shields.io/dub/v/gdub.svg)](https://code.dlang.org/packages/gdub)
[![Dub downloads](https://img.shields.io/dub/dt/gdub.svg)](https://code.dlang.org/packages/gdub)

# gdub

GDUB is a DWT GUI front end for [DUB](https://code.dlang.org/getting_started), a D language build tool.

It's designed to build source file(s) without having to edit the dub files: dub.json, dub.sdl, src/app.d, source/app.d

This tool is great for running examples and building/testing small projects!  

Tested on Windows and Posix (Ubuntu).

## Build gdub

Clone this repository then run build.bat

## Examples

gdub will find and list the *.d files in the current folder.

Double-click on hello.d and hello_dwt.d

From the menu: File, Choose Folder, demo. Select and run widgetdemo.d

Choose the snippets folder and run the snippets individually.

## Command line

        gdub           Run and find *.d files in the current folder
        gdub demo      Run and find *.d files in the demo folder
        gdub snippets  Run and find *.d files in the snippets folder
    
## Screenshots

_Help_

![Settings Window](https://raw.github.com/jasc2v8/gdub/master/gdub_screen_help.png)

_Snippets_

![Settings Window](https://raw.github.com/jasc2v8/gdub/master/gdub_screen_snippets.png)
