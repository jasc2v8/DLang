@echo off
REM assumes rcc.exe and dmd.exe are on the Windows PATH

echo.
echo Compile Resource File: resource.rc
echo.

rcc resource.rc -v -32

echo.
echo Compile and Link Hello program:
echo.

dmd hello.d resource.res

echo.
echo Run the Hello program:
echo.

hello.exe

@echo off

pause
