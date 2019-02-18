# saveWip

If you compile your source code frequently to check your work while learning a new language, for example the D language, then saveWip is for you!

Saves source files to a work in progress folder with timestamp.

The timestamp file format is: wip\app.d_20170401_163556_6770.wip

Intended to be used as a Pre-Build command in your favorite IDE.

Saves your work before building and makes it easy to recover from coding misakes or revert portions of your code to an earlier version.

Optionally, you may build the savewip.exe then save on your system PATH.

WORKING and tested on:

	- Windows 10 Home  32-bit and 64-bit
	- Ubuntu 16.04 LTS 32-bit and 64-bit
	- DMD32 D Compiler v2.074.0, DUB version 1.3.0

```

savewip -h

Saves source files to a work in progress folder with timestamp

Usage: saveWip  [file | folder | path/* [./src]] [-keep=#] [-list] [-quiet]

-l  --list List files without saving to wip
-k  --keep Keep # versions in wip, purge older files
-q --quiet Supress listing files saved to wip
-h  --help This help information.

The ./wip folder is created if not present
The ./src folder is used by default if the source file or folder is not specified

Wildcards not allowed for the file or folder
Wildcards are allowed for path/*.ext but not for path/file.*

```
