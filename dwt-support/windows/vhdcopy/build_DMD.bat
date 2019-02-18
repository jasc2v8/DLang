@echo off

REM Change to your environment
set source=app.d
set target=vhdcopy.exe
set DWT="D:\DEV\Libs\dwt"

echo Build and Run: %target%

dmd src\%source% res\icon.res -of%target% -release -O -boundscheck=off ^
	-I%DWT%\imp -J%DWT%\res -L+%DWT%\lib\ ^
	-L+org.eclipse.swt.win32.win32.x86.lib -L+dwt-base.lib ^
	-L/SUBSYSTEM:WINDOWS:4.0

del *.obj /Q

REM pause

start %target%

