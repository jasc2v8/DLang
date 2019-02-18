@echo off

dmd rdub.d -release -O -boundscheck=off

if exist rdub.obj del /s /q rdub.obj > nul

echo DMD build finished.

if %0 == "%~0"  pause

