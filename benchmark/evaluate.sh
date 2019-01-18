#!/bin/bash

BATCH_SIZE=256
EVAL_DIR="$HOME/train/backup-float16-ckpnt"
#BATCH_SIZE=128
#EVAL_DIR="$HOME/train/backup-float32-ckpnt"

MPIRUN="mpirun -np 64 --hostfile $HOME/8hosts --bind-to none --map-by slot -mca pml ob1 -mca btl ^openib"
ENV="-x NCCL_DEBUG=INFO -x NCCL_MIN_NRINGS=4 -x MXNET_USE_OPERATOR_TUNING=0"
CMD="/home/ubuntu/.virtualenvs/mxnet/bin/python /home/ubuntu/train/accuracy/evaluate_model.py"
for dir in $(ls ${EVAL_DIR});
do
    OPTIONS="--batch-size $BATCH_SIZE --checkpoint-dir $EVAL_DIR/$dir"
    echo "=====Start Evaluate Training: $dir====="
    echo "$MPIRUN $ENV $CMD $OPTIONS"
    $MPIRUN $ENV $CMD $OPTIONS
    echo "=====Done Evaluate Training: $dir====="
    sleep 30
done