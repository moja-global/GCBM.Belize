# Implementation of the GCBM in Belize
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors)

GCBM implementation in Belize, initially with a focus on DOM modelling.

This project is based on the Standalone Template for the GCBM, downloaded from https://carbon.nfis.org/cbm

**Disclaimer:** The calculations performed in this repository are not official and do not represent the Government of Belize in any way.

## Installation and usage instructions

1. Clone the repository

2. Download the installation tools from releases: [install_tools](https://github.com/moja-global/GCBM.Belize/releases/tag/install_tools), and unzip them into Standalone_GCBM/tools folder.

3. Follow the installation instructions, located in Standalone_GCBM/readme.txt

4. Modify the Standalone_GCBM/run_all.bat file to activate or deactivate the custom parameter modifications (explained below), as default, all custom configurations are enabled

4. Execute the run_all.bat

This codebase was tested using a Windows 10 system, the Standalone_GCBM/readme.txt file contains further explanation on the GCBM usage, and tutorials on the model can be found in the moja.global [Youtube Channel](https://www.youtube.com/channel/UCfQUrrNP1Xf-Fv4c8uHYXhQ)

## Custom configuration for Belize

This implementation of the GCBM includes several parameter changes, that were included to adapt the model to Belize´s local conditions

the Standalone_GCBM/run_all.bat file includes all the steps that were taken to adapt the model:

1. A custom Generic Tropical species in created (input_database\add_species_vol_to_bio.py) using a linear volume to biomass conversion factor and proportions of stem, bark, foliage and branches extracted from local literature. 

2. A custom set of root parameters (to convert from AGB to BGB) is applied (input_database\modify_root_parameters.py)

3. A set of decay parameters that was compiled from the scientific literature (input_database\custom_parameters\decay parameters.py) and is used to mofify the default ones (input_database\modify_decay_parameters.py)

4. A sensitive turnover parameter (tree mortality) was modified (input_database\modify_turnover_parameters.py)

5. The disturbance regime of the spinup procedure was changed to "Generic mortality 40%" every 10 years to reflect the effect of Hurricanes in Belize (input_database\modify_spinup_parameters.py)

Steps 3, 4 and 5 can be enabled/disabled in the run_all.bat file to perform a sensitivity analysis on the DOM pools

## Postprocessing and sensitivity analysis

Postprocessing codes using R are included in the Postprocessing folder for reference purposes.

If you are going to use this coded, we recommend to use [Rstudio](https://www.rstudio.com/) and open the Postprocessing/GCBM_Belize_Sensitivity.Rproj file, the [renv](https://rstudio.github.io/renv/articles/renv.html) package was used for library management, and a renv.lock file with the required packages is included

In order to perform sensitivity analysis, the Standalone_GCBM folder can be duplicated with another name (e.g. Standalone_GCBM_decaymod) and the run_all.bat can me modified and run. Then, the Postprocessing/Summarize_DOM_Stocks.R code has to be modified to generate graphs and tables with this new configuration (instructions in the code)

## How to Get Involved?  

moja global welcomes a wide range of contributions as explained in [Contributing document](https://github.com/moja-global/About-moja-global/blob/master/CONTRIBUTING.md) and in the [About moja-global Wiki](https://github.com/moja-global/.github/wiki).  

  
## FAQ and Other Questions  

* You can find FAQs on the [Wiki](https://github.com/moja.global/.github/wiki).  
* If you have a question about the code, submit [user feedback](https://github.com/moja-global/About-moja-global/blob/master/Contributing/How-to-Provide-User-Feedback.md) in the relevant repository  
* If you have a general question about a project or repository or moja global, [join moja global](https://github.com/moja-global/About-moja-global/blob/master/Contributing/How-to-Join-moja-global.md) and 
    * [submit a discussion](https://help.github.com/en/articles/about-team-discussions) to the project, repository or moja global [team](https://github.com/orgs/moja-global/teams)
    * [submit a message](https://get.slack.help/hc/en-us/categories/200111606#send-messages) to the relevant channel on [moja global's Slack workspace](mojaglobal.slack.com). 
* If you have other questions, please write to info@moja.global   
  

## Contributors

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore -->
<table><tr><td align="center"><a href="http://moja.global"><img src="https://avatars1.githubusercontent.com/u/19564969?v=4" width="100px;" alt="moja global"/><br /><sub><b>moja global</b></sub></a><br /><a href="#projectManagement-moja-global" title="Project Management">📆</a></td></tr></table>

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!


## Maintainers Reviewers Ambassadors Coaches

The following people are Maintainers Reviewers Ambassadors or Coaches  
<table><tr><td align="center"><a href="http://moja.global"><img src="https://avatars1.githubusercontent.com/u/19564969?v=4" width="100px;" alt="moja global"/><br /><sub><b>moja global</b></sub></a><br /><a href="#projectManagement-moja-global" title="Project Management">📆</a></td></tr></table>


**Maintainers** review and accept proposed changes  
**Reviewers** check proposed changes before they go to the Maintainers  
**Ambassadors** are available to provide training related to this repository  
**Coaches** are available to provide information to new contributors to this repository  
