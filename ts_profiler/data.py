
DATA_PATH = '/home/ec2-user/SageMaker/profiler/output/'
GB = 1024 * 1024 * 1024


def get_start_end_time():
    start_time = 0
    end_time = 0
    with open(DATA_PATH + 'mx_imagenet_events.txt', 'r') as inf:
        for line in inf:
            fields = line.split(',')
            if start_time == 0 and fields[1] == 'start_fwd':
                start_time = float(fields[0])
            if fields[1] == 'end_sgd':
                end_time = float(fields[0])
    return (start_time, end_time)


def parse_events():
    start_time, end_time = get_start_end_time()
    events = {}    
    with open(DATA_PATH + 'mx_imagenet_events.txt', 'r') as inf:
        for line in inf:
            fields = line.split(',')
            batch = int(fields[3])
            if batch not in events:
                events[batch] = [float(fields[0])]
            else:
                events[batch].append(float(fields[0]))
    return events


def prepare_data(metrics):
    start_time, end_time = get_start_end_time()
    for metric in metrics:
        # if metric == 'net_throughput':
        #     parse_network_throughput(start_time, end_time)
        # else:
        outf = open(DATA_PATH + metric + '.csv', 'w')
        with open(DATA_PATH + metric + '.txt', 'r') as inf:
            for line in inf:
                cur_time = float(line.split(',')[0])
                if cur_time >= start_time and cur_time <= end_time:
                    outf.write(line)
        outf.close()


def parse_network_throughput(start_time, end_time):
    outf = open(DATA_PATH + 'net_throughput.csv', 'w')
    with open(DATA_PATH + 'net_throughput.txt', 'r') as inf:
        for line in inf:
            fields = line.split(',')
            if float(fields[0]) < start_time or float(fields[0]) > end_time:
                continue
            
            send_gbps = round(float(fields[1]) * 8 / GB, 2)
            recv_gbps = round(float(fields[2]) * 8 / GB, 2)
            gbps = send_gbps + recv_gbps
            outf.write(fields[0] + ',' + str(send_gbps) + ',' + str(recv_gbps) + ',' + str(gbps) + '\n')
    outf.close()
