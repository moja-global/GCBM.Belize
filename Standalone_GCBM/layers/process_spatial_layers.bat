@echo off

REM *************************** USER CONFIGURATION ***************************
REM Set Python path - change this to where Python is installed on your machine.
set GCBM_PYTHON=C:\Python37
REM **************************************************************************

REM Set GDAL library paths.
set GDAL_BIN=%GCBM_PYTHON%\lib\site-packages\osgeo
set GDAL_DATA=%GDAL_BIN%\data\gdal

set PYTHONPATH=%GCBM_PYTHON%;%GCBM_PYTHON%\lib\site-packages
set PATH=%GCBM_PYTHON%;%GDAL_BIN%;%GDAL_DATA%;%GCBM_PYTHON%\scripts;%GCBM_PYTHON%\lib\site-packages

REM Clean up any existing tiled layers.
if exist tiled rd /s /q tiled
md tiled
if not exist ..\logs md ..\logs

pushd tiled
  echo Tiling spatial layers...
  "%GCBM_PYTHON%\python.exe" ..\..\tools\tiler\tiler.py
popd

echo Done!
pause
