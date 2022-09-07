## DVC PIPELINE FOR GCBM.Belize
### Stages


Reminder : 
- First you need to install [dvc](https://dvc.org/doc/install/windows) along with the driver for the remote storage you wish to upload your files (e.g. google drive)
- Setup your default remote storage [(help here)](https://dvc.org/doc/command-reference/remote/add)
- In `dvc.yaml` in the `vars` field refactor :`python.path:<your_local_python37_path>` , and `R_path:<your_local_R_path>`
- After you installed the requirements from [README](https://github.com/radistoubalidis/GCBM.Belize/blob/master/README.md "README" ) you can test the pipeline by running :
  - `dvc repro` or `dvc exp run`
    - Dvc as a default does not define an order in the pipeline stages , it does it only if for each `i-th` stage with output `x` its next one `i+1-th` has `x` as a dependency.By creating a log file for each stage and adding it as a dependency for the next stage we achieve pipeline execution in order.
  - you can see the metrics created in `post_processing` stage from the `analyze.py` script by running `dvc metrics show`
- After the pipeline is executed and you have setup your remote storage you can run `dvc push` and for every stage, the files that are included in the `outs` field are going to be pushed in your remote storage.
- There is a demonstration video of the pipeline execution with only one command [here](https://drive.google.com/file/d/14yS4d7IXVUto8MmrEQ8y9fv-58e_jVCT/view)

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

>Command: `tools\Recliner2GCBM-x64\Recliner2GCBM.exe -c input_database\recliner2gcbm_config.json >> logs\reclner_log.txt`

>Dependencies(Relative paths):
 - `logs\tiler_log.txt`
 - `input_database\gcbm_input.db`
 - `tools\recliner2gcbm-x64\recliner2gcbm.exe`
 - `input_database\Growth_Curves.csv`
 - `input_database\recliner2gcbm_config.json`
 - `input_database\ArchiveIndex_Beta_Install.mdb`
>Outputs:
 - `logs\recliner_log.txt`

#### add_species_vol_to_bio
> Working Directory: `Standalone_GCBM`

>Command: `python input_database\add_species_vol_to_bio.py input_database\gcbm_input.db`

>Dependencies(Relative paths):
- `logs\recliner_log.txt`
- `input_database\add_species_vol_to_bio.py`
- `input_database\gcbm_input.db`
>Outputs:
- `logs\add_species_vol_to_bio.log`

#### modify_root_parameters
> Working Directory: `Standalone_GCBM`

>Command: `python input_database\modify_root_parameters.py input_database\gcbm_input.db`

>Dependencies(Relative paths):
- `logs\add_species_vol_to_bio.log`
- `input_database\modify_root_parameters.py`
- `input_database\gcbm_input.db`
>Outputs:
- `logs\modify_root_parameters.log`

#### modify_decay_parameters
> Working Directory: `Standalone_GCBM`

>Command: `python input_database\modify_decay_parameters.py input_database\gcbm_input.db`

>Dependencies(Relative paths):
- `logs\modify_root_parameters.log`
- `input_database\modify_decay_parameters.py`
- `input_database\gcbm_input.db`

>Outputs:
- `logs\modify_decay_parameters.log`

#### modify_turnover_parameters
> Working Directory:`Standalone_GCBM`

>Command: `python input_database\modify_turnover_parameters.py input_database\gcbm_input.db`

>Dependencies(Relative paths):
- `logs\modify_decay_parameters.log`
- `input_database\modify_turnover_parameters.py`
- `input_database\gcbm_input.db`

>Outputs:
- `logs\modify_turnover_parameters.log`

#### modify_spinup_parameters
> Working Directory:`Standalone_GCBM`

>Command: `python input_database\modify_spinup_parameters.py input_database\gcbm_input.db`

>Dependencies(Relative paths):
- `logs\modify_turnover_parameters.log`
- `input_database\modify_spinup_parameters.py`
- `input_database\gcbm_input.db`

>Outputs:
- `logs\modify_spinup_parameters.log`

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
- `..\logs\update_gcbm_config.log`
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
- `..\..\logs\Moja_Debug.log`
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
- `..\..\logs\create_tiffs.log`
- `compileGCBMResults.bat`
- `compileresults.py`
- `compileresults.json`
- `..\..\gcbm_project\output\gcbm_output.db`
- `..\..\processed_output\compiled_gcbm_output.db`

>Outputs:
- `..\..\logs\compile_results.log`

#### post_processing
>Working Directory: `Postprocessing`

>Commands:
- `${R_path} CMD BATCH Summarize_DOM_Stocks.R`
- `${python_path} analyze.py`

>Dependencies(Relative paths):
- `..\Standalone_GCBM\logs\compile_results.log`
- `Summarize_DOM_Stocks.R`
- `..\Standalone_GCBM\processed_output\compiled_gcbm_output.db`
- `Tables`
- `Rplots.pdf`

>Outputs:
- Plots: `Postprocessing\Figures`
- metrics: `PostProcessing\Metrics`
