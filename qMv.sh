#!/bin/bash
export EXP=$1
export FROM=$2
export TO=$3
#or just hardcode these

date
cd ${FROM}
mv ${EXP} ${TO}
date


#usage example qsub qMv.sh experimentName /from/dir /to/dir