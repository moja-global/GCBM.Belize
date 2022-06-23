@echo off

REM *************************** USER CONFIGURATION ***************************
REM Set Python path - change this to where Python is installed on your machine.
set GCBM_PYTHON=C:\Develop\Python\Python37
REM **************************************************************************

set PYTHONPATH=%GCBM_PYTHON%
set PATH=%GCBM_PYTHON%;%GCBM_PYTHON%\scripts

"%GCBM_PYTHON%\python.exe" compileresults.py sqlite:///../../gcbm_project/output/gcbm_output.db --output_db sqlite:///../../processed_output/compiled_gcbm_output.db
pause
