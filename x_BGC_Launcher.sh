#!/bin/bash

##### ##### ##### x_BGC_Lanucher.sh 
##### ##### William J Matthaeus April 2022
#this software is provded as-is and comes with no guarantees
#for assistance please contact the author at willmatt@udel.edu
#
#NOTE: This script must be called from within your 'x_BGC' directory. It has one input,
#a custom name for this set of model runs. Everything else is hard coded by intention.
#
#This is the user-endpoint for parametric runs of x_BGC. The sofware is named 'x_BGC', 
#because the directory, and newly added scriopts are intended as a template
#to be renamed as a unit for each experimental set of runs.
# 
#e.g., modelUpdate02042022_BGC, modelUpdate02042022_BGC_Launcher.sh etc.
#This provides internal source control, as you are forced to update a couple of lines 
#in each code (marked !!!).
#
#
#the general scheme is that input filenames contain information about the runs to be
#performed.
#
#run x_BGC_Lanucher in your experiment directory (i.e., 'x_BGC') for very small runs
#but it is prefered to used a PBS command file (i.e., qLauncher) to run the entire tree 
# of commands that x_BGC_Lanucher will produce on compute notes rather than a login node.
#
#x_BGC_Lanucher will create a Batch directory corresponding to the experiment 'x_BGC'
#to hold files of MET and EPC names to be included in this run,
# and the checksums for job creation.
#
#NOTE: if you've run this with the same batch name before
#you'll need to remove or rename directories created first 
#i.e. rm -r ${BATCHDIR}, where the variables are replaced with actual names
#this is intentionally not automated to prevent accidental data loss
#(see qMv and qRm to use PBS to do this on compute nodes; preferred and faster)
#
#x_BGC_Lanucher is intended to take inputs from upstream software that
#1)creates input files with systematic names (e.g., cesm_to_mtc43.ncl)
#
#x_BGC_Lanucher then runs iniWriter using automatically generated inputs
#

## .mtc43 metfiles must be in a subdirectory of the one containing this file
#NOTE: never include terminal / in any location, hardcoded or input
#set working directory to your 'x_BGC'
export BIN=$(pwd)

#redundant
export BINDIR=${BIN}
#rename binary for version control
export BINARY=bgc
#!!! rename to your 'x_BGC_iniWriter'
export WRITERNAME=${BINDIR}\/x_BGC_iniWriter\.sh

#input location and set derivative dir's (e.g. for different experiments with same model)
#here, a set of MET and EPC files define an experiment
export METD=metdata
export METDIR=${BIN}\/${METD}
export EPCD=epc
export EPCDIR=${BIN}\/${EPCD}
#the one input for this script, a custom name for this set of model runs
export BATCH=$1
export BATCHDIR=${BIN}\/${BATCH}

#

#if either of these bombs, check for last run and move to another directory or delete
if mkdir ${BATCHDIR}; then
	echo "We made batch directory: ${BATCHDIR}"
else
	echo "Cannot make ${BATCHDIR}" 1>&2
	exit 1
fi

cd ${BATCHDIR}
if [ "$?" != "0" ]; then
	echo "Cannot cd to ${BATCHDIR}" 1>&2
	exit 1
fi

##extract file names:
#make list of all met files in METDIR
ls ${METDIR}/*.mtc43 > METnamesF 
NUMMET=$(cat METnamesF | wc -l)
echo "Found ${NUMMET} MET files"
#make list of all epc files in EPCDIR
ls ${EPCDIR}/*.epc > EPCnamesF 
NUMEPC=$(cat EPCnamesF|wc -l)
echo "Found ${NUMEPC} EPC files"
#check there is at least one of each files
if ((NUMEPC==0||NUMMET==0)); then
    echo "Files are missing" 1>&2
    exit 1
fi

#remove extension
#cut METnamesF -d "." -f 1 > METnames0
#cut EPCnamesF -d "." -f 1 > EPCnames0
#remove Full path
rev METnamesF | cut -d '/' -f1 | rev > METnames
rev EPCnamesF | cut -d '/' -f1 | rev > EPCnames


##iniwriter takes seven inputs
# METF=$1 #GLAC_182_28_A.mtc43
# EPCF=$2 #cordaites_MEDCN_MEDg.epc
# BATCHDIR=$3 #/home/matthaeusw/paleo_model/st_083021
# BINDIR=$4 #/home/matthaeusw/paleo_model
# BINARY=$5 #bgc
# METD=$6 #metdata
# EPCD=$7 #epc

#######making a unique ini file for each MET and EPC
#executable, and also log of all writer calls for debuging
touch writerCalls
while read EPC; do
    while read MET; do
        echo "${WRITERNAME} ${MET} ${EPC} ${BATCHDIR} ${BINDIR} ${BINARY} ${METD} ${EPCD}" >> writerCalls
    done < METnames
done < EPCnames


###RUN writer calls
chmod +x writerCalls
${BATCHDIR}/writerCalls > check
#print the number of lines in the stdout file, should match #EPC times #MET 
#i.e., the number of unique ini files
wc -l check 

date
