## DVC PIPELINE FOR GCBM.Belize
### Stages


Reminder : 
- First you need to install [dvc](https://dvc.org/doc/install/windows)
  - Setup your default remote storage [(help here)](https://dvc.org/doc/command-reference/remote/add)
  - In `dvc.yaml` line 2 refactor :`python.path:<your_local_python37_path>`
  - In every stage that has an outputs field dvc tracks the included files (i.e. `logs\tiler_log.txt` in the `tiler` stage) so after the completion of a stage that has outputs run `dvc push` to store the files in your deafult remote
- After you installed the requirements from [README](https://github.com/radistoubalidis/GCBM.Belize/blob/master/README.md "README" ) you can test the pipeline with :
  - `dvc repro` or `dvc exp run`

#### Tiler
> Working Directory: `Standalone_GCBM\layers\tiled`

>Command: `python ..\..\tools\Tiler\tiler.py`

>Dependencies (Relative paths):
- ` ..\..\tools\Tiler\tiler.py`
-   ` ..\raw\environment`
- `..\raw\inventory`

>Outputs:
- `..\..\logs\tiler_log.txt`

#### recliner2gcbm_x64
> Working Directory: `Standalone_GCBM`

>Command: `tools\Recliner2GCBM-x64\Recliner2GCBM.exe -c input_database\recliner2gcbm_config.json`

>Dependencies(Relative paths):
 - `input_database\gcbm_input.db`
 - `tools\recliner2gcbm-x64\recliner2gcbm.exe`
 - `input_database\Growth_Curves.csv`
 - `input_database\recliner2gcbm_config.json`
 - `input_database\ArchiveIndex_Beta_Install.mdb`

#### add_species_vol_to_bio
> Working Directory: `Standalone_GCBM`

>Command: `python input_database\add_species_vol_to_bio.py input_database\gcbm_input.db`

>Dependencies(Relative paths):
- `input_database\add_species_vol_to_bio.py`
- `input_database\gcbm_input.db`

#### modify_root_parameters
> Working Directory: `Standalone_GCBM`

>Command: `python input_database\modify_root_parameters.py input_database\gcbm_input.db`

>Dependencies(Relative paths):
- `input_database\modify_root_parameters.py`
- `input_database\gcbm_input.db`

#### modify_decay_parameters
> Working Directory: `Standalone_GCBM`

>Command: `python input_database\modify_decay_parameters.py input_database\gcbm_input.db`

>Dependencies(Relative paths):
- `input_database\modify_decay_parameters.py`
- `input_database\gcbm_input.db`

#### modify_turnover_parameters
> Working Directory:`Standalone_GCBM`

>Command: `python input_database\modify_turnover_parameters.py input_database\gcbm_input.db`

>Dependencies(Relative paths):
- `input_database\modify_turnover_parameters.py`
- `input_database\gcbm_input.db`

#### modify_spinup_parameters
> Working Directory:`Standalone_GCBM`

>Command: `python input_database\modify_spinup_parameters.py input_database\gcbm_input.db`

>Dependencies(Relative paths):
- `input_database\modify_spinup_parameters.py`
- `input_database\gcbm_input.db`

#### update_GCBM_Configuration
> Working Directory: `Standalone_GCBM\gcbm_project`

>Command: `update_GCBM_configuration.bat`

>Dependencies(Relative paths):
- `update_gcbm_configuration.bat`
- `templates`
- `..\input_database\gcbm_input.db`
- `..\layers\tiled`
- `..\tools\tiler\update_gcbm_config.py`

>Outputs:
- `..\logs\update_gcbm_config.log`

#### run_gcbm
>Working Directory:`Standalone_GCBM\gcbm_project`

>Command: `run_gcbm.bat`

>Dependencies(Relative paths):
- `run_gcbm.bat`
- `..\tools\GCBM\moja.cli.exe`
- `gcbm_config.cfg`
- `provider_config.json`
- `..\input_database\gcbm_input.db`
- `output\gcbm_output.db`

>Outputs: `..\logs\Moja_Debug.log`

#### create_tiffs
>Working Directory: `Standalone_GCBM\tools\CompileGCBMSpatialOutput`

>Command: `create_tiffs.bat`

>Dependencies(Relative paths):
- `create_tiffs.bat`
- `create_tiffs.py`
- `..\..\gcbm_project\output`

>Outputs:
- `..\..\logs\create_tiffs.log`
- `..\..\processed_output\spatial`

#### compile_results
>Working Directory: `Standalone_GCBM\tools\CompileGCBMResults`

>Command: `compileGCBMResults.bat`

>Dependencies(Relative paths):
- `compileGCBMResults.bat`
- `compileresults.py`
- `compileresults.json`
- `..\..\gcbm_project\output\gcbm_output.db`
- `..\..\processed_output\compiled_gcbm_output.db`

#### post_processing
>Working Directory: `Postprocessing`

>Command: `C:\Develop\R-4.1.3\bin\R.exe CMD BATCH Summarize_DOM_Stocks.R`

>Dependencies(Relative paths):
- `Summarize_DOM_Stocks.R`
- `..\Standalone_GCBM\processed_output\compiled_gcbm_output.db`
- `Tables`
- `Rplots.pdf`

>Output Plots: `./Figures`