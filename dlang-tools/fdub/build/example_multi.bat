@echo off

rdmd rdub multi/hello multi/util --force

if %0 == "%~0"  pause