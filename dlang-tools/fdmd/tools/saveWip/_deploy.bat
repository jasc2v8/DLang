@echo off

%file%=%1
if "%file%"=="" set file=saveWip

	copy /Y %file%.exe ..\
	
echo Finished deploying %file%

IF %0 == "%~0"  pause