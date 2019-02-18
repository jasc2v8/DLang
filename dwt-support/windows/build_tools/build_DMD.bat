@echo off

REM Change to your environment
set source=hello_dwt.d
set DWT="D:\DEV\Libs\dwt"

echo Build and Run: %source%

dmd src\%source% res\resource.res -release -O -boundscheck=off ^
	-I%DWT%\imp -J%DWT%\res -L+%DWT%\lib\ ^
	-L+org.eclipse.swt.win32.win32.x86.lib -L+dwt-base.lib ^
	-L/SUBSYSTEM:WINDOWS

del *.obj /Q

IF %0 == "%~0"  pause

start %source%

