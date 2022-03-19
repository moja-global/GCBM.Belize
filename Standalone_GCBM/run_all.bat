@echo off

REM *************************** USER CONFIGURATION ***************************
REM Set simulation start and end years.
set SIMULATION_START_YEAR=1900
set SIMULATION_END_YEAR=2050

REM Set Python path - change this to your Python installation directory.
set GCBM_PYTHON=C:\Python37

REM Is your version of MS Access 32 (x86) or 64 (x64) bit?
set PLATFORM=x64
REM **************************************************************************

REM Set GDAL library paths.
set GDAL_BIN=%GCBM_PYTHON%\lib\site-packages\osgeo
set GDAL_DATA=%GDAL_BIN%\data\gdal

set PYTHONPATH=%GCBM_PYTHON%;%GCBM_PYTHON%\lib\site-packages
set PATH=%GCBM_PYTHON%;%GDAL_BIN%;%GDAL_DATA%;%GCBM_PYTHON%\scripts;%GCBM_PYTHON%\lib\site-packages

REM Clean up log and output directories.
if exist logs rd /s /q logs
if exist processed_output rd /s /q processed_output
if exist gcbm_project\output rd /s /q gcbm_project\output
if exist layers\tiled rd /s /q layers\tiled
md logs
md processed_output
md gcbm_project\output
md layers\tiled

REM Run the tiler to process spatial input data.
pushd layers\tiled
    echo Tiling spatial layers...
    "%GCBM_PYTHON%\python.exe" ..\..\tools\tiler\tiler.py
popd

REM Generate the GCBM input database from a yield table and CBM3 ArchiveIndex database.
echo Generating GCBM input database...
tools\recliner2gcbm-%PLATFORM%\recliner2gcbm.exe -c input_database\recliner2gcbm_config.json

REM Create new species
echo Creating Generic species and adding vol to bio factors
"%GCBM_PYTHON%\python.exe" input_database\add_species_vol_to_bio.py input_database\gcbm_input.db

echo Modify root parameters
"%GCBM_PYTHON%\python.exe" input_database\modify_root_parameters.py input_database\gcbm_input.db


REM Create new species

echo Modify decay parameters
"%GCBM_PYTHON%\python.exe" input_database\modify_decay_parameters.py input_database\gcbm_input.db

echo Modify turnover parameters
"%GCBM_PYTHON%\python.exe" input_database\modify_turnover_parameters.py input_database\gcbm_input.db

echo Modify spinup parameters
"%GCBM_PYTHON%\python.exe" input_database\modify_spinup_parameters.py input_database\gcbm_input.db


REM Configure GCBM.
echo Updating GCBM configuration...
"%GCBM_PYTHON%\python.exe" tools\tiler\update_gcbm_config.py --layer_root layers\tiled --template_path gcbm_project\templates --output_path gcbm_project --input_db_path input_database\gcbm_input.db --start_year %SIMULATION_START_YEAR% --end_year %SIMULATION_END_YEAR% --log_path logs
    
REM Run the GCBM simulation.
pushd gcbm_project
    echo Running GCBM...
    ..\tools\GCBM\moja.cli.exe --config_file gcbm_config.cfg --config_provider provider_config.json
popd

REM Merge the raw spatial output and convert to GeoTIFF format.
echo Compiling spatial output...
"%GCBM_PYTHON%\python.exe" tools\compilegcbmspatialoutput\create_tiffs.py --indicator_root gcbm_project\output --start_year %SIMULATION_START_YEAR% --output_path processed_output\spatial --output_type tif

REM Create the results database from the raw simulation output.
echo Compiling results database...
"%GCBM_PYTHON%\python.exe" tools\compilegcbmresults\compileresults.py sqlite:///gcbm_project/output/gcbm_output.db --output_db sqlite:///processed_output/compiled_gcbm_output.db

echo Done!
pause
