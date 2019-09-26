import numpy as np
import pandas as pd
import holoviews as hv
from holoviews import opts
from data import *


hv.extension('bokeh', 'matplotlib')


DATA_PATH = '/home/ec2-user/SageMaker/profiler/output/'
PHASE_INDEX = {'Forward': 0, 'Backward': 1, 'SGD': 2}


class SaturatedNetwork:
    def __init__(self, bandwidth):
        self._bandwidth = bandwidth
        self._events = parse_events()
        self._timestamps = []
        self._send_rates = []
        self._recv_rates = []
        self._total_rates = []

    def analyze(self):
        prepare_data(['net_throughput'])

        self._timestamps = []
        self._send_rates = []
        self._recv_rates = []
        self._total_rates = []
        with open(DATA_PATH + 'net_throughput.csv', 'r') as inf:
            for line in inf:
                fields = line.split(',')
                self._timestamps.append(float(fields[0]))

                send_gbps = round(float(fields[1]) * 8 / GB, 2)
                recv_gbps = round(float(fields[2]) * 8 / GB, 2)
                self._send_rates.append(send_gbps)
                self._recv_rates.append(recv_gbps)
                self._total_rates.append(send_gbps + recv_gbps)

    def graph(self):
        net_tput = pd.DataFrame(data={'Time': self._timestamps, 'Send': self._send_rates,
                                      'Recv': self._recv_rates, 'Total': self._total_rates})
        net_tput['Time'] = net_tput.Time.astype('datetime64[s]')

        net_vdims = [('Recv', 'Throughput')]
        net_ds = hv.Dataset(net_tput, ['Time'], net_vdims)

        net_curve = net_ds.to(hv.Curve, 'Time', 'Recv').options(ylim=(0, self._bandwidth * 1.2))
        overlay =  net_curve * hv.HLine(self._bandwidth)
        overlay.opts(opts.HLine(color='red', line_width=3))
        return overlay

    def summary(self):
        count = 0
        max_rate = 0
        for rate in self._recv_rates:
            if rate >= self._bandwidth:
                count += 1
            max_rate = max(rate, max_rate)
        
        message = ''
        if count > 0:
            message = 'Network throughput reached its limit for %d times during %d steps of training. ' % (count, len(self._events))
            message += 'Upgrading your network bandwidth may improve your training speed.'
        else:
            util = round(float(max_rate) / self._bandwidth, 2) * 100
            message = 'The network utilization is below %d during the training. ' % util
            message += 'The network bandwidth is sufficient for your training job.'
        return message


class InefficientDataLoading():
    def __init__(self, cpu_upper_threshold=80, gpu_lower_threshold=20):
        self._cpu_upper_threshold = cpu_upper_threshold
        self._gpu_lower_threshold = gpu_lower_threshold
        self._events = parse_events()
        self._cpu_util = None
        self._gpu_util = None
    
    def analyze(self):
        prepare_data(['cpu_util', 'gpu_util'])
        self._cpu_util = pd.read_csv(DATA_PATH + 'cpu_util.csv', names=['Time', 'CPU_Id', 'Util'])
        self._cpu_util['Time'] = self._cpu_util.Time.astype('datetime64[s]')

        self._gpu_util = pd.read_csv(DATA_PATH + 'gpu_util.csv', names=['Time', 'GPU_Id', 'Util'])
        self._gpu_util['Time'] = self._gpu_util.Time.astype('datetime64[s]')

    def _filter_cpu_util(self, st, et):
        cpu_util = self._cpu_util[(self._cpu_util['Time'] >= st)]
        cpu_util = cpu_util[(cpu_util['Time'] <= et)]
        return cpu_util

    def _filter_gpu_util(self, st, et):
        gpu_util = self._gpu_util[(self._gpu_util['Time'] >= st)]
        gpu_util = gpu_util[(gpu_util['Time'] <= et)]
        return gpu_util
    
    def _get_st_et(self, batch_start, batch_end, index):
        if index == -1:
            st = pd.Timestamp(self._events[batch_start][0], unit='s')
            et = pd.Timestamp(self._events[batch_end][-1], unit='s')
        else:
            st = pd.Timestamp(self._events[batch_start][index], unit='s')
            et = pd.Timestamp(self._events[batch_end][index + 1], unit='s')
        return (st, et)

    def graph(self, epoch=-1, batch_start=-1, batch_end=-1, phase=''):
        cpu_util = self._cpu_util
        gpu_util = self._gpu_util
        if epoch != -1:
            phase_index = -1
            if phase:
                phase_index = PHASE_INDEX[phase]
            st, et = self._get_st_et(batch_start, batch_end, phase_index)
            cpu_util = self._filter_cpu_util(st, et)
            gpu_util = self._filter_gpu_util(st, et)

        cpu_vdims = [('Util', 'Utilization')]
        cpu_ds = hv.Dataset(cpu_util, ['Time', 'CPU_Id'], cpu_vdims)
        gpu_vdims = [('Util', 'Utilization')]
        gpu_ds = hv.Dataset(gpu_util, ['Time', 'GPU_Id'], gpu_vdims)

        cpu_agg = cpu_ds.aggregate('Time', function=np.mean, spreadfn=np.std)
        gpu_agg = gpu_ds.aggregate('Time', function=np.mean, spreadfn=np.std)
        cpu_plt = hv.Curve(cpu_agg, label='CPU').options(ylim=(0, 100))
        gpu_plt = hv.Curve(gpu_agg, label='GPU')
        overlay = cpu_plt * gpu_plt
        return overlay

