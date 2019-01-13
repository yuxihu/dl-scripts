#!/bin/bash

MODEL=$1
LR_MODE=$2
DTYPE=$3
BATCH_SIZE=$4
ALLREDUCE=$5

if ls ${MODEL}* 1> /dev/null 2>&1; then
    SAVE_DIR=checkpoint/${MODEL}_${LR_MODE}_${DTYPE}_${BATCH_SIZE}_${ALLREDUCE}
    mkdir -p $SAVE_DIR
    mv ${MODEL}* $SAVE_DIR
fi