@echo off

if not exist src_bak ren src src_bak

if exist .dub rmdir /S /Q .dub
if exist bin rmdir /S /Q bin
if exist src rmdir /S /Q src
if exist dub.selections.json del /Q dub.selections.json

mkdir src

if exist src_bak copy /Y src_bak\*.d src

if exist src_bak rmdir /S /Q src_bak

echo Dub reset finished.

if %0 == "%~0"  pause

