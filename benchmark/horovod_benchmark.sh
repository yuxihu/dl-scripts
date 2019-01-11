#!/bin/bash

function run_benchmark() {
    NUM_WORKERS=$1
    NUM_HOSTS=$(expr $NUM_WORKERS / 8)
    MODEL=$2
    MODE=$3
    ALLRECUDE=$4
    DTYPE=$5
    DATA_SRC=$6

    if [[ $DTYPE = "float32" ]]; then
        LR=0.05
        BATCH_SIZE=128
    else
        LR=0.1
        BATCH_SIZE=256
    fi

    ENV="-x NCCL_DEBUG=INFO -x NCCL_MIN_NRINGS=4 -x MXNET_USE_OPERATOR_TUNING=0 -x HOROVOD_STALL_CHECK_DISABLE=1"
    if [[ $ALLRECUDE = "HA" ]]; then
        ENV="$ENV -x HOROVOD_HIERARCHICAL_ALLREDUCE=1"
    fi

    OPTIONS="--model $MODEL --dtype $DTYPE --batch-size $BATCH_SIZE --lr $LR --lr-mode $MODE --warmup-epochs 5 --num-epochs 91 --data-nthreads 4 --last-gamma"
    if [[ $DATA_SRC != "synthetic" ]]; then
        OPTIONS="$OPTIONS --use-rec --rec-train /media/ramdisk/train-480px-q95.rec --rec-train-idx /media/ramdisk/train-480px-q95.idx --rec-val /media/ramdisk/val-480px-q95.rec --rec-val-idx /media/ramdisk/val-480px-q95.idx"
    fi

    MPIRUN="mpirun -np $NUM_WORKERS --hostfile $HOME/${NUM_HOSTS}hosts --bind-to none --map-by slot -mca pml ob1 -mca btl ^openib"
    CMD="/home/ubuntu/.virtualenvs/mxnet/bin/python /home/ubuntu/horovod/examples/mxnet_imagenet_resnet50.py"
    echo "=====Start $1GPU $2 $3 $4 $5 $6====="
    echo "$MPIRUN $ENV $CMD $OPTIONS"
    TIC=$(date +%s)
    $MPIRUN $ENV $CMD $OPTIONS
    TIC=$(date +%s)
    echo "=====Done $1GPU $2 $3 $4 $5 $6 in $(($TOC - $TIC)) Seconds====="
    sleep 10
}

if [ "$#" -ne 3]; then
    echo "Usage: ./benchmark.sh <num_gpus> <model> <lr_mode>"
    exit
fi

run_benchmark $1 $2 $3 "non-HA" "float32" "synthetic"
run_benchmark $1 $2 $3 "non-HA" "float32" "imagenet"
run_benchmark $1 $2 $3 "HA" "float32" "synthetic"
run_benchmark $1 $2 $3 "HA" "float32" "imagenet"
run_benchmark $1 $2 $3 "non-HA" "float16" "synthetic"
run_benchmark $1 $2 $3 "non-HA" "float16" "imagenet"
run_benchmark $1 $2 $3 "HA" "float16" "synthetic"
run_benchmark $1 $2 $3 "HA" "float16" "imagenet"
