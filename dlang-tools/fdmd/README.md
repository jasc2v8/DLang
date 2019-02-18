# dBuild

dBuild is a front-end for the DMD compilier

## Key Features

1. If .d source file(s)s not specified, searches the src folder for all *.d file(s) to pass to DMD (shallow search)
2. The default source folder is src or ..\src
3. The default output folder is bin\debug

	dBuild -h

	```
	dBuild is a front-end for DMD.  All arguments passed to DMD except:

	-clean  Delete bin\debug\* and bin\release\*.
	-quiet  Supresses dBuild messages.
	-run    Runs the target after build.
	-help   This help information.
	```
