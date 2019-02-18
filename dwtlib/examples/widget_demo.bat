@echo off

rdmd rdub demo\widgetdemo.d --force

if %0 == "%~0"  pause
