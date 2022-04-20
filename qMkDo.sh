#!/bin/bash
#extract a subset of output variables.
#see iniWriter for current outputs, remeber awk starts index at 1

date
cd /dir/with/your/experiment

#make a new directory and copy all of your target output types to it
mkdir dayOuts
cp */outputs/*.dayout.ascii dayOuts
cd dayOuts

#compile all outputs to single file with 
#first column is filename, second column is file record number (line number within file)
awk '{print ARGV[ARGIND]" "FNR" "$1" "$7" "$8" "$9" "$10" "$11" "$12" "$13" "$20" "$21" "$22" "$25" "$26" "$27" "$28" "$29" "$30" "$31" "$33" "$34" "$35" "$36" "$38" "$41" "$45" "$53" "$54" "$55" "$56" "$57" "$58" "$23" "$24}' *.dayout.ascii > base_v6_102621.txt
date
