REM Download rcc.exe from http://ftp.digitalmars.com/bup.zip
REM ico files limited to 128X128 size?

@echo off

echo.
echo Compiling Resource Files:
dir *.rc /b /o
echo.

for %%f in (*.rc) do rcc %%f -w32

echo.
echo Compiled Resources:
dir *.res /b /o
echo.

pause
