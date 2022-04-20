# x_BGC
##Template for running parameterized 'x_BGC' family model simulations on a supercomputer.

### Introduction
A self-contained structure including several scripts to allow for the parameterization of experiments with unifying factors, while maintaining version control and organizing outputs with the input files that produced them for sub-experiments.
The intent is for the 'x_BGC' to be replaced throughout with a descriptor of your model version. The model included with the template is Paleo-BGC (White et al. 2020).

User front-end us in x_BGC_Launcher.sh, which in turn parameterizes x_BGC_iniWriter.sh.
Utility scripts for operations on a cluster computer running something like PBS start with the letter 'q...' and are meant to be passed to PBS using qsub.

Sofware is provided as is, with no guarantees. Please contact the author with any issues, questions, etc.

### Filestructure and script names
In addition to a few git-specific items that can be ignored, the filestructure contains several **folders** and * *scripts* * organized and named so that this template will function. This scheme can be changed in the code.

**src** contains x_BGC source files

**metdata** contains meteorological (.mtc43) input files. I've included several sets of example metfiles in metdata.bak* folders

**epc** contains ecophysiological (.epc) input files

**ini** contains example ini files only, ini files produced by scripts will be stored in experiment directory

* *in progress* *
