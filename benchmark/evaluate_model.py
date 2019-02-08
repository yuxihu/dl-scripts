import argparse
import logging
import os
import sys

import horovod.mxnet as hvd
import mxnet as mx
from mxnet import gluon


# Evaluation settings
parser = argparse.ArgumentParser(description='Evaluate Validation Metrics',
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('--model', type=str, default='resnet50_v1b',
                    help='type of model to use. see vision_model for options.')
parser.add_argument('--batch-size', type=int, default=256,
                    help='training batch size per device (default: 256)')
parser.add_argument('--data-nthreads', type=int, default=4,
                    help='number of threads for data decoding')
parser.add_argument('--rec-val', type=str, default='/media/ramdisk/val-480px-q95.rec',
                    help='the validation data')
parser.add_argument('--rec-val-idx', type=str, default='/media/ramdisk/val-480px-q95.idx',
                    help='the index of validation data')
parser.add_argument('--no-cuda', action='store_true', default=False,
                    help='disables CUDA training (default: False)')
parser.add_argument('--checkpoint-dir', type=str, default='checkpoint',
                    help='directory name for model checkpoint')

args = parser.parse_args()

logging.basicConfig(level=logging.INFO)
logging.info(args)

# Initialize Horovod
hvd.init()
local_rank = hvd.local_rank()

# Horovod: pin GPU to local rank.
context = mx.cpu() if args.no_cuda else mx.gpu(local_rank)

def get_data_rec():
    # kept each node to use full val data to make it easy to monitor results
    mean_rgb = [123.68, 116.779, 103.939]
    val_data = mx.io.ImageRecordIter(
        path_imgrec=os.path.expanduser(args.rec_val),
        path_imgidx=os.path.expanduser(args.rec_val_idx),
        preprocess_threads=args.data_nthreads,
        shuffle=False,
        batch_size=args.batch_size,
        resize=256,
        label_width=1,
        rand_crop=False,
        rand_mirror=False,
        data_shape=(3, 224, 224),
        mean_r=mean_rgb[0],
        mean_g=mean_rgb[1],
        mean_b=mean_rgb[2],
        device_id=local_rank
    )

    return val_data

val_data = get_data_rec()


def evaluate():
    ckpnt_dir = args.checkpoint_dir
    cur_dir = os.path.dirname(os.path.realpath(__file__))
    epoches = [89]
    for epoch in epoches:
        # Make model files ready
        prefix = "%s-%d" % (args.model, hvd.rank())
        param_file = "%s-%04d.params" % (prefix, epoch)
        sym_file = "%s-symbol.json" % prefix
        mv_param_cmd = "mv %s/%s %s/" % (ckpnt_dir, param_file, cur_dir)
        mv_sym_cmd = "mv %s/%s %s/" % (ckpnt_dir, sym_file, cur_dir)
        os.system(mv_param_cmd)
        os.system(mv_sym_cmd)

        # Load model
        mod = mx.mod.Module.load(prefix, epoch, context=context)
        mod.bind(data_shapes=val_data.provide_data,
                 label_shapes=val_data.provide_label)

        # Evaluate performance
        acc_top1 = mx.metric.Accuracy()
        acc_top5 = mx.metric.TopKAccuracy(5)
        res = mod.score(val_data, [acc_top1, acc_top5])
        for name, val in res:
            logging.info('Epoch[%d] Rank[%d] Validation-%s=%f', epoch - 1, hvd.rank(), name, val)

        # Restore model files
        rs_param_cmd = "mv %s/%s %s/" % (cur_dir, param_file, ckpnt_dir)
        rs_sym_cmd = "mv %s/%s %s/" % (cur_dir, sym_file, ckpnt_dir)
        os.system(rs_param_cmd)
        os.system(rs_sym_cmd)


if __name__ == '__main__':
    evaluate()
