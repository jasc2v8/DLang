@echo off

cd ..

rdmd build_dwtlib.d clean

if exist ..\..\.dub rmdir /S /Q ..\..\.dub

if exist ..\..\examples\.dub rmdir /S /Q ..\..\examples\.dub
if exist ..\..\examples\bin  rmdir /S /Q ..\..\examples\bin
if exist ..\..\examples\src  rmdir /S /Q ..\..\examples\src

IF %0 == "%~0"  pause
