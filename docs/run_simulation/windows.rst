Simulation on Windows 
=====================

Prerequisites
+++++++++++++


1. Clone the `GCBM Belize <https://github.com/moja-global/GCBM.Belize>`_ repository

2. Download the installation tools from releases: `install_tools <https://github.com/moja-global/GCBM.Belize/releases/tag/install_tools>`_, and unzip them into `Standalone_GCBM\tools` folder. On unzipping, `Standalone_GCBM\tools` will contain a folder tools with the folders `python_3_installer` and `VC_redist` .
The configuration is **strictly for Python3.7**, it will not work with other versions


.. figure:: ../assets/install_tools.PNG
   :alt: Unzipped contents of install tools
   :align: center
   :width: 600px


Running the simulation (short version)
======================================

Navigate to `Standalone_GCBM\`, edit `run_all.bat` and set the `GCBM_PYTHON path` and `PLATFORM`` variables in the `USER CONFIGURATION` section near the top to the correct values for your system

Run `run_all.bat`, which performs the following preprocessing, and simulation

Running the project (long version)
==================================

This involves running each stage of the simulation step by step. There are 12 steps in all. 
It helps in understanding the sequence of steps, inputs, outputs and dependencies to each step 

Step 1 
++++++

- Working directory - **Standalone_GCBM\\layers\\tiled**	
- Command - **c:\\python37\\python.exe ..\\..\\tools\Tiler\tiler.py**	
- Description -  
1. define all spatial layers needed for the simulation - can be raster or shapefile:
    - bounding box
    - age
    - classifiers
    - disturbance events (optional)
2. crops all layers to a bounding box and reprojects to WGS84 processes layers into GCBM tile/block/cell format
3. Output is a number of zip files containing GCBM-format data plus a json file containing metadata and an optional attribute table

- Output - Logs written into **Standalone_GCBM\\logs\\tiler_log.txt**
  