#!/bin/bash

DATA_SRC=$1

for FUSHION in 16 32 64
do
  for HA in 0 1
  do
    for NODE in 8 4 2 1
    do
      for DT in 8 7 6 5 4 3 2
      do
        GPU=$(($NODE*8))
        FSIZE=$(($FUSHION*1024*1024))
        echo "=====Start FUSHION=${FUSHION}MB HA=$HA DataThreads=$DT GPU=$GPU====="
        MPIRUN="mpirun -np $GPU --hostfile $HOME/${NODE}hosts --bind-to none --map-by slot -mca pml ob1 -mca btl ^openib"
        ENV="-x HOROVOD_HIERARCHICAL_ALLREDUCE=$HA -x HOROVOD_FUSION_THRESHOLD=$FSIZE -x HOROVOD_STALL_CHECK_DISABLE=1 -x NCCL_MIN_NRINGS=4 -x MXNET_USE_OPERATOR_TUNING=0 -x MXNET_OPTIMIZER_AGGREGATION_SIZE=4"
        OPTIONS="--data-nthreads $DT --model resnet50_v1b --mode gluon --dtype float16 --batch-size 256 --lr 0.1 --lr-mode poly --save-frequency 0 --last-gamma"
        if [[ $DATA_SRC != "synthetic" ]]; then
          OPTIONS="$OPTIONS --warmup-epochs 0 --num-epochs 3"
          OPTIONS="$OPTIONS --use-rec --rec-train /media/ramdisk/train-480px-q95.rec --rec-train-idx /media/ramdisk/train-480px-q95.idx --rec-val /media/ramdisk/val-480px-q95.rec --rec-val-idx /media/ramdisk/val-480px-q95.idx"
        else
          OPTIONS="$OPTIONS --warmup-epochs 0 --num-epochs 2"
        fi
        CMD="/home/ubuntu/.virtualenvs/mxnet/bin/python /home/ubuntu/horovod/examples/mxnet_imagenet_resnet50.py"
        echo "$MPIRUN $ENV $CMD $OPTIONS"
        TIC=$(date +%s)
        $MPIRUN $ENV $CMD $OPTIONS
        TOC=$(date +%s)
        echo "=====Done FUSHION=${FUSHION}MB HA=$HA DataThreads=$DT GPU=$GPU in $(($TOC - $TIC)) Seconds====="
        sleep 60
      done
    done
  done
done
