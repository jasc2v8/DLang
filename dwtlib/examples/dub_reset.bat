@echo off

if exist .dub rmdir /S /Q .dub
if exist bin rmdir /S /Q bin
if exist src rmdir /S /Q src
if exist src_bak rmdir /S /Q src_bak

if exist dub.selections.json del /Q dub.selections.json

echo Dub reset finished.

if %0 == "%~0"  pause

