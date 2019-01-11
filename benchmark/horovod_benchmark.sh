#!/bin/bash

function run_benchmark() {
    NUM_WORKERS=$1
    NUM_HOSTS=$(expr $NUM_WORKERS / 8)
    MODEL=$2
    MODE=$3
    MEASURE=$4
    ALLREDUCE=$5
    DTYPE=$6
    DATA_SRC=$7

    MPIRUN="mpirun -np $NUM_WORKERS --hostfile $HOME/${NUM_HOSTS}hosts --bind-to none --map-by slot -mca pml ob1 -mca btl ^openib"
    ENV="-x NCCL_DEBUG=INFO -x NCCL_MIN_NRINGS=4 -x MXNET_USE_OPERATOR_TUNING=0 -x HOROVOD_STALL_CHECK_DISABLE=1"
    if [[ $ALLREDUCE = "HA" ]]; then
        ENV="$ENV -x HOROVOD_HIERARCHICAL_ALLREDUCE=1"
    fi

    if [[ $DTYPE = "float32" ]]; then
        LR=0.05
        BATCH_SIZE=128
    else
        LR=0.1
        BATCH_SIZE=256
    fi
    OPTIONS="--model $MODEL --dtype $DTYPE --batch-size $BATCH_SIZE --lr $LR --lr-mode $MODE --data-nthreads 4 --last-gamma"
    if [[ $MEASURE == "accuracy" ]]; then
        OPTIONS="$OPTIONS --warmup-epochs 5 --num-epochs 91"
    else
        OPTIONS="$OPTIONS --warmup-epochs 0 --num-epochs 1"
    fi
    if [[ $DATA_SRC != "synthetic" ]]; then
        OPTIONS="$OPTIONS --use-rec --rec-train /media/ramdisk/train-480px-q95.rec --rec-train-idx /media/ramdisk/train-480px-q95.idx --rec-val /media/ramdisk/val-480px-q95.rec --rec-val-idx /media/ramdisk/val-480px-q95.idx"
    fi

    CMD="/home/ubuntu/.virtualenvs/mxnet/bin/python /home/ubuntu/horovod/examples/mxnet_imagenet_resnet50.py"
    echo "=====Start ${NUM_WORKERS}GPU $MODEL $ALLREDUCE $DTYPE $DATA_SRC====="
    echo "$MPIRUN $ENV $CMD $OPTIONS"
    TIC=$(date +%s)
    $MPIRUN $ENV $CMD $OPTIONS
    TOC=$(date +%s)
    echo "=====Done ${NUM_WORKERS}GPU $MODEL $ALLREDUCE $DTYPE $DATA_SRC in $(($TOC - $TIC)) Seconds====="
    sleep 10
}

if [ "$#" -ne 4 ]; then
    echo "Usage: ./benchmark.sh <num_gpus> <model> <lr_mode> <measure>"
    echo "Example: ./benchmakr.sh 8 resnet50_v1 poly speed"
    exit
fi

NUM_GPUS=$1
MODEL=$2
LR_MODE=$3
MEASURE=$4

run_benchmark $NUM_GPUS $MODEL $LR_MODE $MEASURE "non-HA" "float32" "synthetic"
run_benchmark $NUM_GPUS $MODEL $LR_MODE $MEASURE "non-HA" "float32" "imagenet"
run_benchmark $NUM_GPUS $MODEL $LR_MODE $MEASURE "HA" "float32" "synthetic"
run_benchmark $NUM_GPUS $MODEL $LR_MODE $MEASURE "HA" "float32" "imagenet"
run_benchmark $NUM_GPUS $MODEL $LR_MODE $MEASURE "non-HA" "float16" "synthetic"
run_benchmark $NUM_GPUS $MODEL $LR_MODE $MEASURE "non-HA" "float16" "imagenet"
run_benchmark $NUM_GPUS $MODEL $LR_MODE $MEASURE "HA" "float16" "synthetic"
run_benchmark $NUM_GPUS $MODEL $LR_MODE $MEASURE "HA" "float16" "imagenet"
