@echo off

REM *************************** USER CONFIGURATION ***************************
REM Set Python path - change this to your Python installation directory.
set GCBM_PYTHON=C:\Python37
REM **************************************************************************

REM Set GDAL library paths.
set GDAL_BIN=%GCBM_PYTHON%\lib\site-packages\osgeo
set GDAL_DATA=%GDAL_BIN%\data\gdal

set PYTHONPATH=%GCBM_PYTHON%;%GCBM_PYTHON%\lib\site-packages
set PATH=%GCBM_PYTHON%;%GDAL_BIN%;%GDAL_DATA%;%GCBM_PYTHON%\scripts;%GCBM_PYTHON%\lib\site-packages

REM Clean up output directory.
if exist output rd /s /q output
md output

REM Run the GCBM simulation.
..\tools\GCBM\moja.cli.exe --config_file gcbm_config.cfg --config_provider provider_config.json
pause
