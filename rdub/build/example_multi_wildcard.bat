@echo off

rdmd rdub multi/*.d --force

if %0 == "%~0"  pause