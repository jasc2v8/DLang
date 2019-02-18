@echo off

:: dBuild args
:: %1            %2       %3       %4     %5     %6
:: console|gui  [-clean] [-quiet] [-run]

if "%1"=="console" (

	saveWip
	
	dBuild -debug "%2" "%3" "%4" "%5" "%6"
)

if "%1"=="gui" (

	saveWip

	dBuild -debug "%2" "%3" "%4" "%5" "%6" ^
			-ID:\DEV\Libs\dwt\imp -JD:\DEV\Libs\dwt\res ^
			-L+D:\DEV\Libs\dwt\lib\ -L+org.eclipse.swt.win32.win32.x86.lib -L+dwt-base.lib ^
			-L/SUBSYSTEM:WINDOWS:4.0
)

						



