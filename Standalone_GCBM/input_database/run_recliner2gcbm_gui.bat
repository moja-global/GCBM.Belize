@echo off

REM *************************** USER CONFIGURATION ***************************
REM Is your version of MS Access 32 (x86) or 64 (x64) bit?
set PLATFORM=x64
REM **************************************************************************

start ..\tools\recliner2gcbm-%PLATFORM%\Recliner2GCBM-GUI.exe
