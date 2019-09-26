import stats
import time
import multiprocessing as mp


DATA_COLLECTION_INTERVAL = 0.1
US_PER_S = 1000000
DATA_PATH = "/home/ec2-user/SageMaker/profiler/output/"


def disk_collector():
    # Time Spent Collection:  0.0030367374420166016
    # Time Spent Write:  4.38690185546875e-05
    disk = stats.DiskStats()
    with open(DATA_PATH + "disk_read_throughput.txt", "w") as outf:
        while True:
            disk_rput = disk.read_throughput()
            outf.write(str(time.time()) + "," + str(disk_rput) + "\n")
            time.sleep(DATA_COLLECTION_INTERVAL)


def network_collector():
    # Time Spent Collection:  0.00033926963806152344
    # Time Spent Write:  6.437301635742188e-05
    net = stats.NetworkStats()
    with open(DATA_PATH + "net_throughput.txt", "w") as outf:
        while True:
            net_tput = net.throughput()
            outf.write(str(time.time()) + "," + str(net_tput[0]) + "," + str(net_tput[1]) + "\n")
            time.sleep(DATA_COLLECTION_INTERVAL)


def memory_collector():
    # Time Spent Collection:  0.00026488304138183594
    # Time Spent Write:  4.410743713378906e-05
    mem = stats.MemoryStats()
    with open(DATA_PATH + "memory_util.txt", "w") as outf:
        while True:
            mem_util = mem.util()
            outf.write(str(time.time()) + "," + str(mem_util) + "\n")
            time.sleep(DATA_COLLECTION_INTERVAL)


def cpu_collector():
    # Time Spent Collection:  0.003710508346557617
    # Time Spent Write:  0.0003070831298828125
    cpu = stats.CPUStats()
    with open(DATA_PATH + "cpu_util.txt", "w") as outf:
        while True:
            cpu_util = cpu.util()
            now = time.time()
            for i in range(len(cpu_util)):
                if cpu_util[i] > 0:
                    outf.write(str(now) + "," + str(i) + "," + str(cpu_util[i]) + "\n")
            time.sleep(DATA_COLLECTION_INTERVAL)


def gpu_collector():
    # Time Spent Collection:  0.002592802047729492
    # Time Spent Write:  8.630752563476562e-05
    gpu = stats.GPUStats()
    # with open(DATA_PATH + "gpu_util_memory.txt", "w") as outf:
    with open(DATA_PATH + "gpu_util.txt", "w") as outf:
        while True:
            gpu_util = gpu.util()
            now = time.time()
            for i in range(len(gpu_util)):
                if gpu_util[i] > 0:
                    outf.write(str(now) + "," + str(i) + "," + str(gpu_util[i]) + "\n")
            time.sleep(DATA_COLLECTION_INTERVAL)
            # util_mem = gpu.util_and_memory()
            # now = time.time()
            # for i in range(len(util_mem[0])):
            #     outf.write(str(now) + "," + str(i) + "," + str(util_mem[0][i])+ "," + str(util_mem[1][i]) + "\n")
            # time.sleep(DATA_COLLECTION_INTERVAL)


def all_collector():
    # Time Spent Collection:  0.00940847396850586
    # Time Spent Write:  0.00020503997802734375
    gpu = stats.GPUStats()
    cpu = stats.CPUStats()
    mem = stats.MemoryStats()
    disk = stats.DiskStats()
    net = stats.NetworkStats()
    with open(DATA_PATH + "metrics.txt" , "w") as outf:
        while True:
            tic = time.time()
            gs = gpu.util_and_memory()
            cs = cpu.util()
            ms = mem.util()
            ds = disk.read_throughput(DATA_COLLECTION_INTERVAL)
            ns = net.throughput(DATA_COLLECTION_INTERVAL)
            toc = time.time()
            print("Time Spent Collection: ", toc - tic)
            outf.write(str(toc) + "," + str(ds) + "\n")
            outf.write(str(toc) + "," + str(ns[0]) + "," + str(ns[1]) + "\n")
            outf.write(str(toc) + "," + str(ms) + "\n")
            for i in range(len(gs[0])):
                outf.write(str(toc) + "," + str(i) + "," + str(gs[0][i])+ "," + str(gs[1][i]) + "\n")
            for i in range(len(cs)):
                outf.write(str(toc) + "," + str(i) + "," + str(cs[i]) + "\n")
            print("Time Spent Write: ", time.time() - toc)
            time.sleep(DATA_COLLECTION_INTERVAL)


def collect():
    # workers = [cpu_collector, gpu_collector]
    workers = [cpu_collector, gpu_collector, network_collector, disk_collector]

    processes = []
    for i in range(len(workers)):
        p = mp.Process(target=workers[i])
        processes.append(p)
        p.daemon = True
        p.start()

    for p in processes:
        p.join()


if __name__ == '__main__':
    collect()

    # disk_collector()
    # network_collector()
    # memory_collector()
    # cpu_collector()
    # gpu_collector()
    # all_collector()
