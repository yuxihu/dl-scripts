#!/bin/bash

MODEL=$1
TRAIN_MODE=$2
LR_MODE=$3
DTYPE=$4
BATCH_SIZE=$5
ALLREDUCE=$6
OPT=$7
WARM_EP=$8

if ls ${MODEL}* 1> /dev/null 2>&1; then
    SAVE_DIR=checkpoint/${MODEL}_${TRAIN_MODE}_${LR_MODE}_${DTYPE}_${BATCH_SIZE}_${ALLREDUCE}_${OPT}_warmup${WARM_EP}
    mkdir -p $SAVE_DIR
    mv ${MODEL}* $SAVE_DIR
fi