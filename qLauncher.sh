#!/bin/bash
export EXP=$1
export DIR=$2
export LAUNCHER=$3
#or just hardcode


cd ${DIR}
./${LAUNCHER} ${EXP}

#usage example qsub qLauncher.sh experimentName /exp/dir launcherName.sh
