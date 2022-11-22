Postprocessing
==============

After the simulation is complete, either by running the **run_all.bat** script or following the step-by-step procedure, for postprocessing, the following steps are to be followed:

1. Install `R <https://www.r-project.org/>`_ based on the OS

2. Get the path to the R executable, e.g. **c:\\"Program Files"\R\R-4.2.1\bin\R.exe**, on Windows

3. Navigate to the `Standalone_GCBM\\Postprocessing` and execute **c:\\"Program Files"\\R\\R-4.2.1\\bin\\R.exe CMD BATCH Summarize_DOM_Stocks.R** .

This generates the plots `Figures\\Belize_Sensitivity_TropicalDry.png`, `Figures\\Belize_Sensitivity_TropicalMoist.png` and `Figures\\Belize_Sensitivity_TropicalPremontane.png`

4. The logs are written into **Summarize_DOM_Stocks.Rout**, missing R packages, if any, can be installed by following the steps mentioned here: https://www.datacamp.com/tutorial/r-packages-guide