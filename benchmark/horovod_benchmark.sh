#!/bin/bash

function run_benchmark() {
  NUM_WORKERS=$1
  MODEL=$2
  LR_MODE=$3
  TRAIN_MODE=$4
  ALLREDUCE=$5
  DTYPE=$6
  BATCH_SIZE=$7
  OPT=$8
  WARM_EP=$9

  MPIRUN="mpirun -np $NUM_WORKERS --hostfile $HOME/hosts --bind-to none --map-by slot -mca pml ob1 -mca btl ^openib"
  ENV="-x NCCL_MIN_NRINGS=4 -x MXNET_USE_OPERATOR_TUNING=0 -x MXNET_OPTIMIZER_AGGREGATION_SIZE=4 -x HOROVOD_STALL_CHECK_DISABLE=1"
  if [[ $ALLREDUCE = "ha" ]]; then
    ENV="$ENV -x HOROVOD_HIERARCHICAL_ALLREDUCE=1"
  fi

  SAVE_FREQ=90
  EVAL_FREQ=0
  if [[ $BATCH_SIZE = 128 ]]; then
    LR=0.05
    DT=2
  else
    LR=0.1
    DT=4
  fi
  OPTIONS="--model $MODEL --dtype $DTYPE --batch-size $BATCH_SIZE --lr $LR --lr-mode $LR_MODE --mode $TRAIN_MODE --optimizer $OPT"
  OPTIONS="$OPTIONS --save-frequency $SAVE_FREQ --eval-frequency $EVAL_FREQ --data-nthreads $DT --warmup-epochs $WARM_EP --num-epochs 91 --last-gamma"
  OPTIONS="$OPTIONS --use-rec --rec-train /media/ramdisk/train-480px-q95.rec --rec-train-idx /media/ramdisk/train-480px-q95.idx --rec-val /media/ramdisk/val-480px-q95.rec --rec-val-idx /media/ramdisk/val-480px-q95.idx"

  CMD="/home/ubuntu/.virtualenvs/mxnet/bin/python /home/ubuntu/horovod/examples/mxnet_imagenet_resnet50.py"
  echo "=====Start ${NUM_WORKERS}GPU $TRAIN_MODE $ALLREDUCE $DTYPE $BATCH_SIZE $OPT $WARM_EP====="
  echo "$MPIRUN $ENV $CMD $OPTIONS"
  TIC=$(date +%s)
  $MPIRUN $ENV $CMD $OPTIONS
  TOC=$(date +%s)
  echo "=====Done ${NUM_WORKERS}GPU $TRAIN_MODE $ALLREDUCE $DTYPE $BATCH_SIZE $OPT $WARM_EP in $(($TOC - $TIC)) Seconds====="

  if ls ${MODEL}* 1> /dev/null 2>&1; then
    SSH_CMD="cd ~/train && ./save_checkpoint.sh $MODEL $TRAIN_MODE $LR_MODE $DTYPE $BATCH_SIZE $ALLREDUCE $OPT $WARM_EP"
    run_ssh_cmd "${SSH_CMD}"
  fi

  sleep 300
}

function start_benchmark() {
  # Train in gluon mode
  run_benchmark $1 $2 $3 "gluon" "ha" "float16" 256 "sgd" 10
  run_benchmark $1 $2 $3 "gluon" "ha" "float16" 256 "sgd" 5
  run_benchmark $1 $2 $3 "gluon" "ha" "float16" 256 "nag" 10
  run_benchmark $1 $2 $3 "gluon" "ha" "float16" 256 "nag" 5

  run_benchmark $1 $2 $3 "gluon" "non-ha" "float16" 256 "sgd" 10
  run_benchmark $1 $2 $3 "gluon" "non-ha" "float16" 256 "sgd" 5
  run_benchmark $1 $2 $3 "gluon" "non-ha" "float16" 256 "nag" 10
  run_benchmark $1 $2 $3 "gluon" "non-ha" "float16" 256 "nag" 5

  # Train in module mode
  # run_benchmark $1 $2 $3 "module" "ha" "float16" 256 "sgd" 10
  # run_benchmark $1 $2 $3 "module" "ha" "float16" 256 "sgd" 5
  # run_benchmark $1 $2 $3 "module" "ha" "float16" 256 "nag" 10
  # run_benchmark $1 $2 $3 "module" "ha" "float16" 256 "nag" 5

  # run_benchmark $1 $2 $3 "module" "ha" "float32" 128 "sgd" 10
  # run_benchmark $1 $2 $3 "module" "ha" "float32" 128 "sgd" 5
  # run_benchmark $1 $2 $3 "module" "ha" "float32" 128 "nag" 10
  # run_benchmark $1 $2 $3 "module" "ha" "float32" 128 "nag" 5

  # run_benchmark $1 $2 $3 "module" "non-ha" "float16" 256 "sgd" 10
  # run_benchmark $1 $2 $3 "module" "non-ha" "float16" 256 "sgd" 5
  # run_benchmark $1 $2 $3 "module" "non-ha" "float16" 256 "nag" 10
  # run_benchmark $1 $2 $3 "module" "non-ha" "float16" 256 "nag" 5

  # run_benchmark $1 $2 $3 "module" "non-ha" "float32" 128 "sgd" 10
  # run_benchmark $1 $2 $3 "module" "non-ha" "float32" 128 "sgd" 5
  # run_benchmark $1 $2 $3 "module" "non-ha" "float32" 128 "nag" 10
  # run_benchmark $1 $2 $3 "module" "non-ha" "float32" 128 "nag" 5
}

function run_ssh_cmd() {
  CMD=$1
  echo $CMD
  ssh 172.31.13.223 "${CMD}"
  ssh 172.31.5.191 "${CMD}"
  ssh 172.31.5.144 "${CMD}"
  ssh 172.31.8.109 "${CMD}"
  ssh 172.31.5.222 "${CMD}"
  ssh 172.31.14.230 "${CMD}"
  ssh 172.31.13.113 "${CMD}"
  ssh 172.31.4.198 "${CMD}"
}

if [ "$#" -ne 3 ]; then
  echo "Usage: ./benchmark.sh <num_gpus> <model> <lr_mode>"
  echo "Example: ./benchmark.sh 8 resnet50_v1 poly"
  exit
fi

start_benchmark $1 $2 $3
