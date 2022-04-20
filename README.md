# x_BGC
## Template for running parameterized 'x_BGC' family model simulations on a supercomputer.

### Introduction
A self-contained structure including several scripts to allow for the parameterization of experiments with a single model version (i.e., 'x' in 'x_BGC'), while maintaining version control and organizing outputs with the input files that produced them for sub-experiments.
The intent is for the 'x_BGC' to be replaced throughout with a descriptor of your model version. The model included with the template is Paleo-BGC (White et al. 2020).

User front-end us in x_BGC_Launcher.sh, which in turn parameterizes x_BGC_iniWriter.sh.
Utility scripts for operations on a cluster computer running something like PBS start with the letter 'q...' and are meant to be passed to PBS using qsub.

Sofware is provided as is, with no guarantees. Please contact the author with any issues, questions, etc.

### Filestructure and script names
In addition to a few git-specific items that can be ignored, the filestructure contains several **folders** and * *scripts* * organized and named so that this template will function. This scheme can be changed in the code.

**src** contains x_BGC source files. To use a different model version in x_BGX just update the source files and make. This will produce a new executable (called bgc, by default) in the src directory. You can then copy this to the x_BGC directory (this is why there is a bgc.bak, good practice).

**metdata** contains meteorological (.mtc43) input files. I've included several sets of example metfiles in metdata.bak* folders

**epc** contains ecophysiological (.epc) input files

**ini** contains example ini files only, ini files produced by scripts will be stored in experiment directory

_x_BGC_Launcher.sh_ NOTE: This script must be called from within your 'x_BGC' directory. It has one input, a custom name for this set of model runs. Everything else is hard coded by intention. This is the user-endpoint for parametric runs of x_BGC. The sofware is named 'x_BGC', because the directory, and newly added scriopts are intended as a template to be renamed as a unit for each experimental set of runs.  e.g., modelUpdate02042022_BGC, modelUpdate02042022_BGC_Launcher.sh etc. This provides internal source control, as you are forced to update a couple of lines in each code (marked !!!). NOTE: if you've run this with the same batch name before you'll need to remove or rename directories created first i.e. rm -r ${BATCHDIR}, where the variables are replaced with actual names this is intentionally not automated to prevent accidental data loss (see qMv and qRm to use PBS to do this on compute nodes; preferred and faster). x_BGC_Lanucher is intended to take inputs from upstream software that creates input files with systematic names (e.g., cesm_to_mtc43.ncl). x_BGC_Lanucher then runs iniWriter using automatically generated inputs.

_x_BGC_iniWriter.sh_ This is intended to be called and automatically parameterized by x_BGC_launcher. The general scheme is that input filenames contain information about the runs to be performed. iniWriter functions to create ini files in a parameterized fashion, creates an individual PBS command file for each simulation, and submits that simulation to PBS iniWriter is intended to take inputs from upstream software that
#1)creates input files with systematic names (e.g., cesm_to_mtc43.ncl) and then 2)the details of how this should be done will depend on the filenames generated, therefore some alternative examples are left in the comments

_qLauncher.sh_ Three inputs:  experiment name, x_BGC directory, launcher name. 

_qMkDo.sh_ Hardcoded. Utility to collect x_BGC outputs to a single folder and use awk to pull specific variables and collate in a new text file.

_qMv.sh_ Three inputs: run name, experiment directory, target directory. Utility to move directory for a run on compute node.

