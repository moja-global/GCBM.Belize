## Prerequisites

Refer to moja.global's GCBM training video series before proceeding to run the
model. ([Part 1](https://www.youtube.com/watch?v=y5fbzDPOjkc) and [Part 2](https://www.youtube.com/watch?v=pSfUlDk37Jk&t))

If not completed earlier, download the installation tools from releases: [install_tools](https://github.com/moja-global/GCBM.Belize/releases/tag/install_tools), and unzip them into `Standalone_GCBM\tools` folder. 
On unzipping, `Standalone_GCBM\tools` will contain a folder `tools` with the folders `python_3_installer` and `VC_redist`
The configuration is strictly for Python3.7, it will not work with other versions

## Description of contents

| **Folder** | **Description** | 
| --- | ----------- |
| `documentation\` | Assorted GCBM-related documentation: Python snippets, configuration examples, database schema diagram |
| `gcbm_project\` |The files needed to run GCBM - config files, SQL for retrieving parameters from the input database |
| `input_database\` | The GCBM input database for the project which contains all of the non-spatial model parameters, plus the files needed to generate the input database using the Recliner2GCBM tool. |
| `layers\` | The spatial layers for the project, both the originals and the output of the tiler script which processes the original layers into the format used by GCBM |
| `logs\` | The log files created by most of the pre- and post-processing tools as well as the GCBM |
| `processed_output\` | Contains the fully-processed (analysis ready) output of the simulation: Spatial output in GeoTIFF format, and database output in SQLite format. Analysis ready tables containing various ecosystem indicators are the tables prefixed with "v_". |
| `tools\` | `CompileGCBMResults` - Python script for turning raw SQLite output database from the model into a more user-friendly format that includes most of the indicators from CBM3 (NPP, NEP, pools, etc.). <br> `CompileGCBMSpatialOutput` - Python script for turning raw GCBM spatial output into final TIFF layers. <br> `GCBM` - The simulation model. <br>`Recliner2GCBM-[x86/x64]` - Tool for preparing the SQLite input database for GCBM, which holds non-spatial (or coarse spatially-referenced) model parameters. Use the x64 version and fall back to the x86 version if you don't have the 64-bit MS Access driver installed. <br> The tool has both a GUI version to guide you through the process the first time, and a command-line version to update a database from a saved configuration, provided that the columns in the input data have not changed. <br> `Tiler` - Converts raster and vector layers into the format required by GCBM. |

## Setting up the simulation environment

The document `documentation\GCBM_Installation_Guide_2019_11_14.docx` can be used reference

Install Python3.7:

If you have Python3.7 already installed:

From the command prompt in `\Standalone_GCBM\tools\tools\python_3_installer`, type:
        
    install_modules_only (path to existing Python installation)
            
For example, if your computer already has 64-bit Python3.7 installed in c:\Python37:
            
    install_modules_only c:\Python37

If you do not have Python3.7 installed:

From the command prompt in `\Standalone_GCBM\tools\tools\python_3_installer`, type:
        
    install_python
            
If you do not have MS Access installed, you will need to install a driver in
order to connect to MS Access databases. The driver can be found in:
`Standalone_GCBM\tools\tools\python_3_installer\installers\AccessDatabaseEngine_x64.exe`
    
Install the Visual C++ Redistributable packages required to run the GCBM and related tools and the .NET framework 4.7.2 redistributable package required to run the Recliner2GCBM tool. Navigate to `Standalone_GCBM\tools\tools\VC_redist`, and run the following command:
    
    install_vc_redist

## Running the simulation (shorter version):

Navigate to `Standalone_GCBM\`, edit `run_all.bat` and set the `GCBM_PYTHON` path and `PLATFORM` variables in the
`USER CONFIGURATION` section near the top to the correct values for your system, as mentioned in `documentation\GCBM_Installation_Guide_2019_11_14.docx`

Run `run_all.bat`, which performs the following preprocessing, and simulation

## Running the project (the long version):    

Step-by-step instructions for running the simulation

Working directory: Refers to the directory in which the command has to be run

The commands are written assuming the path to python3.7 is `c:\python37`, if python3.7 is located at a different path, replace it in the commands.

| **Working directory** |       **Command**     | **Description** | **Output** |
| --------------------- |-----------------------|-----------------|------------|
| `Standalone_GCBM\layers\tiled`| `c:\python37\python.exe  ..\..\tools\Tiler\tiler.py` |  1. define all spatial layers needed for the simulation - can be raster or shapefile: <br> - bounding box <br> - age <br> - classifiers <br> - disturbance events (optional) <br> 2. crops all layers to a bounding box and reprojects to WGS84 processes layers into GCBM tile/block/cell format <br> 3. Output is a number of zip files containing GCBM-format data plus a json file containing metadata and an optional attribute table | Logs written into  `Standalone_GCBM\logs\tiler_log.txt` |
| `Standalone_GCBM` | `tools\Recliner2GCBM-x64\Recliner2GCBM.exe -c input_database\recliner2gcbm_config.json` |  1. runs the command-line version of Recliner2GCBM (`tools\Recliner2GCBM-[x86\x64]\Recliner2GCBM.exe`) on the saved project configuration made by running the GUI tool (Recliner2GCBM-GUI.exe) <br> 2. note: the paths in the saved `recliner2gcbm_config.json` file are relative to the location of the json file <br> 3. Output is a SQLite database: gcbm_input.db which contains all of the non-spatial data required to run the project parameters taken from a CBM3 ArchiveIndex database: disturbance matrices, default climate data, etc.
| `Standalone_GCBM` | `c:\python37\python.exe input_database\add_species_vol_to_bio.py input_database\gcbm_input.db` | Adding a generic tropical species and Vol to Bio parameters |
| `Standalone_GCBM` | `c:\python37\python.exe input_database\modify_root_parameters.py input_database\gcbm_input.db` | Modify root parameters |
| `Standalone_GCBM` | `c:\python37\python.exe input_database\modify_decay_parameters.py input_database\gcbm_input.db` | Modify decay parameters | 
| `Standalone_GCBM` | `c:\python37\python.exe input_database\modify_turnover_parameters.py input_database\gcbm_input.db` | Modify turnover parameters | 
| `Standalone_GCBM` | `c:\python37\python.exe input_database\modify_spinup_parameters.py input_database\gcbm_input.db` | Modify spinup parameters | 
| `Standalone_GCBM\gcbm_project` | `update_gcbm_configuration.bat` | 1. Update the GCBM configuration <br> 2. Automatically updates the GCBM configuration files based on the tiled layers: <br> - scans for all of the tiled layers and adds them to the provider configuration file <br> - sets the tile, block, and cell size in the config files so that the model knows the overall resolution of the simulation (the lowest common denominator of all the tiled layer resolutions) <br> - updates the list of disturbance layers in the simulation based on the DisturbanceLayer items in tiler.py <br> - updates the initial classifier set with the classifier layers tagged in tiler.py | Logs generated in `Standalone_GCBM\logs\update_gcbm_config.log` | Logs written into `Standalone_GCBM\logs\update_gcbm_config.log` |
| `Standalone_GCBM\gcbm_project` | `run_gcbm.bat` | 1. Run the GCBM model <br> 2. Project configuration is split between multiple files listed in `gcbm_project\gcbm_config.cfg` <br> 3. Data source configuration (spatial layers + SQLite) is in `gcbm_project\provider_config.json`| Logs generated in `Standalone_GCBM\logs\Moja_Debug.log` |
| `Standalone_GCBM\tools\CompileGCBMSpatialOutput` | `create_tiffs.bat` | 1. Compile the spatial output <br> 2.  Generates tiff layers from raw GCBM spatial output <br> 3. Output is a tiff layer per indicator and timestep in `processed_output\spatial` | Logs written into `Standalone_GCBM\logs\create_tiffs.log`, output to `Standalone_GCBM\processed_output\spatial` |
| `Standalone_GCBM\tools\CompileGCBMResults` | `compileGCBMResults.bat` |1. Compile the GCBM results <br> 2. Turns the raw GCBM output database into a more user-friendly format containing most of the familiar indicators from the CBM3 Toolbox <br> 3. Produces `processed_output\compiled_gcbm_output.db` |

## Postprocessing

After the simulation is complete, either by running the `run_all.bat` script or following the step-by-step procedure, for postprocessing, the following steps are to be followed:

1. [Install R](https://www.datacamp.com/tutorial/installing-R-windows-mac-ubuntu) based on the OS
2. Get the path to the R executable, e.g. `c:\"Program Files"\R\R-4.2.1\bin\R.exe`, on Windows
3. Navigate to the `Standalone_GCBM\Postprocessing` and execute `c:\"Program Files"\R\R-4.2.1\bin\R.exe CMD BATCH Summarize_DOM_Stocks.R`
This generates the plots `Figures\Belize_Sensitivity_TropicalDry.png`, `Figures\Belize_Sensitivity_TropicalMoist.png`
and `Figures\Belize_Sensitivity_TropicalPremontane.png`

The logs are written into `Summarize_DOM_Stocks.Rout`, missing R packages, if any, can be installed by following the steps mentioned here: https://www.datacamp.com/tutorial/r-packages-guide
