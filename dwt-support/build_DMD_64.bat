@echo off

REM
REM Requires the Microsoft Build Tools Prompt
REM
REM C:\Program Files (x86)\Microsoft Visual C++ Build Tools>
REM C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\bin\amd64>
REM
REM Change to your environment
REM

set source=hello_dwt

set DWT="D:\DEV\Libs\dwt64"

echo Build and Run: %source%

dmd src\%source% res\resource.res -m64 -release -O  -boundscheck=off ^
	-I%DWT%\imp -J%DWT%\res -L/LIBPATH:%DWT%\lib ^
	"-Lorg.eclipse.swt.win32.win32.x86.lib" "-Ldwt-base.lib" ^
	-L/SUBSYSTEM:Windows -L/ENTRY:mainCRTStartup -L/RELEASE 

del *.obj /Q

IF %0 == "%~0"  pause

start %source%

