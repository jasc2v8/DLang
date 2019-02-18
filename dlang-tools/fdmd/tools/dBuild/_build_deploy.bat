@echo off

%file%=%1
if "%file%"=="" set file=dBuild

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

echo Deploy to ..\

	copy /Y %file%.exe ..\
	
echo Finished building and deploying %file%

IF %0 == "%~0"  pause

