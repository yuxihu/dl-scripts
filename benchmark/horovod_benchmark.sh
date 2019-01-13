#!/bin/bash

function run_benchmark() {
    NUM_WORKERS=$1
    NUM_HOSTS=$(expr $NUM_WORKERS / 8)
    MODEL=$2
    MODE=$3
    DATA_SRC=$4
    MEASURE=$5
    ALLREDUCE=$6
    DTYPE=$7
    BATCH_SIZE=$8

    MPIRUN="mpirun -np $NUM_WORKERS --hostfile $HOME/${NUM_HOSTS}hosts --bind-to none --map-by slot -mca pml ob1 -mca btl ^openib"
    ENV="-x NCCL_DEBUG=INFO -x NCCL_MIN_NRINGS=4 -x MXNET_USE_OPERATOR_TUNING=0 -x HOROVOD_STALL_CHECK_DISABLE=1"
    if [[ $ALLREDUCE = "ha" ]]; then
        ENV="$ENV -x HOROVOD_HIERARCHICAL_ALLREDUCE=1"
    fi

    SAVE_FREQ=30
    if [[ $BATCH_SIZE = 128 ]]; then
        LR=0.05
    else
        LR=0.1
    fi
    OPTIONS="--model $MODEL --dtype $DTYPE --batch-size $BATCH_SIZE --lr $LR --lr-mode $MODE --save-frequency $SAVE_FREQ --data-nthreads 2 --last-gamma"
    if [[ $MEASURE == "accuracy" ]]; then
        OPTIONS="$OPTIONS --warmup-epochs 5 --num-epochs 91"
    else
        OPTIONS="$OPTIONS --warmup-epochs 0 --num-epochs 1"
    fi

    SLEEP_TIME=10
    if [[ $DATA_SRC != "synthetic" ]]; then
        OPTIONS="$OPTIONS --use-rec --rec-train /media/ramdisk/train-480px-q95.rec --rec-train-idx /media/ramdisk/train-480px-q95.idx --rec-val /media/ramdisk/val-480px-q95.rec --rec-val-idx /media/ramdisk/val-480px-q95.idx"
        SLEEP_TIME=60
    fi

    CMD="/home/ubuntu/.virtualenvs/mxnet/bin/python /home/ubuntu/horovod/examples/mxnet_imagenet_resnet50.py"
    echo "=====Start ${NUM_WORKERS}GPU $MODEL $ALLREDUCE $DTYPE $DATA_SRC====="
    echo "$MPIRUN $ENV $CMD $OPTIONS"
    TIC=$(date +%s)
    $MPIRUN $ENV $CMD $OPTIONS
    TOC=$(date +%s)
    echo "=====Done ${NUM_WORKERS}GPU $MODEL $ALLREDUCE $DTYPE $DATA_SRC in $(($TOC - $TIC)) Seconds====="

    if ls ${MODEL}* 1> /dev/null 2>&1; then
        save_checkpoint $MODEL $LR_MODE $DTYPE $BATCH_SIZE $ALLREDUCE
    fi

    sleep $SLEEP_TIME
}

function start_benchmark() {
    run_benchmark $1 $2 $3 $4 $5 "non-ha" "float32" 128
    run_benchmark $1 $2 $3 $4 $5 "ha" "float32" 128
    run_benchmark $1 $2 $3 $4 $5 "non-ha" "float16" 256
    run_benchmark $1 $2 $3 $4 $5 "ha" "float16" 256
    run_benchmark $1 $2 $3 $4 $5 "non-ha" "float16" 128
    run_benchmark $1 $2 $3 $4 $5 "ha" "float16" 128
}

function save_checkpoint() {
    CMD="cd ~/train && ./save_checkpoint.sh $1 $2 $3 $4 $5"
    ssh 172.31.13.223 "${CMD}"
    ssh 172.31.5.191 "${CMD}"
    ssh 172.31.5.144 "${CMD}"
    ssh 172.31.8.109 "${CMD}"
    ssh 172.31.5.222 "${CMD}"
    ssh 172.31.14.230 "${CMD}"
    ssh 172.31.13.113 "${CMD}"
    ssh 172.31.4.198 "${CMD}"
}

if [ "$#" -ne 5 ]; then
    echo "Usage: ./benchmark.sh <num_gpus> <model> <lr_mode> <data_src> <measure>"
    echo "Example: ./benchmark.sh 8 resnet50_v1 poly synthetic speed"
    exit
fi

start_benchmark $1 $2 $3 $4 $5
