@echo off

REM *************************** USER CONFIGURATION ***************************
REM Set simulation start and end years.
set SIMULATION_START_YEAR=2010
set SIMULATION_END_YEAR=2020

REM Set Python path - change this to your Python installation directory.
set GCBM_PYTHON=C:\Python37
REM **************************************************************************

REM Set GDAL library paths.
set GDAL_BIN=%GCBM_PYTHON%\lib\site-packages\osgeo
set GDAL_DATA=%GDAL_BIN%\data\gdal

set PYTHONPATH=%GCBM_PYTHON%;%GCBM_PYTHON%\lib\site-packages
set PATH=%GCBM_PYTHON%;%GDAL_BIN%;%GDAL_DATA%;%GCBM_PYTHON%\scripts;%GCBM_PYTHON%\lib\site-packages

REM Configure GCBM.
echo Updating GCBM configuration...
"%GCBM_PYTHON%\python.exe" ..\tools\tiler\update_gcbm_config.py --layer_root ..\layers\tiled --template_path templates --output_path . --input_db_path ..\input_database\gcbm_input.db --start_year %SIMULATION_START_YEAR% --end_year %SIMULATION_END_YEAR% --log_path ..\logs
    
echo Done!
pause
