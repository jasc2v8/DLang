@echo off

%file%=%1
if "%file%"=="" set file=saveWip

echo Compile resources

	::assumes rcc.exe is on your PATH
	rcc resources.rc -32

echo Compile and link source with resources

	dmd %file% resources.res -release -boundscheck=off -O 

echo Compress exe

	copy /Y %file%.exe %file%_before_upx.exe
	
	upx %file%.exe

:: clean (del *.obj)

	del /Q *.obj

echo Finished building %file%

IF %0 == "%~0"  pause