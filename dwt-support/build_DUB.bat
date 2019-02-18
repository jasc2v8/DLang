@echo off

echo Start DUB Build...

REM dub -b=debug

dub -b=release-nobounds

echo End DUB Build.

IF %0 == "%~0" pause
