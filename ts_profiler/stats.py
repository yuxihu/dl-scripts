from pynvml import *
import psutil
import time


class GPUStats(object):
    def __init__(self):
        self._handles = []
        try:
            nvmlInit()
            for i in range(nvmlDeviceGetCount()):
                self._handles.append(nvmlDeviceGetHandleByIndex(i))
        except NVMLError:
            pass
    
    def __del__(self):
        try:
            nvmlShutdown()
        except NVMLError:
            pass

    def util(self):
        results = []
        for handle in self._handles:
            util = nvmlDeviceGetUtilizationRates(handle)
            results.append(util.gpu)
        return results
    
    def memory(self):
        results = []
        for handle in self._handles:
            mem = nvmlDeviceGetMemoryInfo(handle)
            results.append(int(mem.used / mem.total * 100))
        return results
    
    def util_and_memory(self):
        utils = []
        memory = []
        for handle in self._handles:
            util = nvmlDeviceGetUtilizationRates(handle)
            utils.append(util.gpu)
            mem = nvmlDeviceGetMemoryInfo(handle)
            memory.append(int(mem.used / mem.total * 100))
        return (utils, memory)


class CPUStats(object):
    def util(self):
        return psutil.cpu_percent(percpu=True)


class MemoryStats(object):
    def util(self):
        return psutil.virtual_memory().percent


class DiskStats(object):
    def __init__(self):
        self._prev_io = None
        self._cur_io = None
        self._cur_time = time.time()
    
    def read_throughput(self):
        self._prev_io = self._cur_io
        prev_time = self._cur_time
        self._cur_time = time.time()
        self._cur_io = psutil.disk_io_counters()
        if self._prev_io is None:
            return 0.0

        interval = self._cur_time - prev_time
        read_tput = (self._cur_io.read_bytes - self._prev_io.read_bytes) / interval
        return read_tput


class NetworkStats(object):
    def __init__(self):
        self._prev_io = None
        self._cur_io = None
        self._cur_time = time.time()

    def throughput(self):
        self._prev_io = self._cur_io
        prev_time = self._cur_time
        self._cur_time = time.time()
        self._cur_io = psutil.net_io_counters()
        if self._prev_io is None:
            return (0.0, 0.0)
        
        interval = self._cur_time - prev_time
        send_tput = (self._cur_io.bytes_sent - self._prev_io.bytes_sent) / interval
        recv_tput = (self._cur_io.bytes_recv - self._prev_io.bytes_recv) / interval

        return (send_tput, recv_tput)
