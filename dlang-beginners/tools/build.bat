@echo off

REM works correctly when only 1 file in src
for /f %%t in ('dir /b ..\src\*.d' ) do set baseName=%%t

set file=%baseName:~0, -2%
	
echo Build and Run: %file%

rem dmd ..\src\%file% -of..\bin\debug\%file%.exe -debug

dmd ..\src\%file% -of..\bin\release\%file%.exe -release -O -boundscheck=off

del /s /q ..\bin\*.obj > nul

echo Press Ctrl-C to abort, or:
pause

rem call ..\bin\debug\%file%.exe
call ..\bin\release\%file%.exe

