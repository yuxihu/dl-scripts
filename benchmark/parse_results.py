import math
import re
import sys


SAMPLES=1281167


def parse(res_file, epoch_num, batch_num):
    train_acc = []
    val_acc = []
    speed = []
    epoch = "Epoch[%s]" % epoch_num
    with open(res_file, "r") as inf:
        for line in inf:
            if "Done" in line:
                print(line.replace("\n", ""))
                print_result(train_acc, "Train Accuracy")
                print_result(val_acc, "Validation Accuracy")
                print_result(speed, "Throughput")
                print("")
                train_acc = []
                val_acc = []
                speed = []
            if epoch not in line:
                continue
            if "Train" in line:
                train_acc.append(float(line.replace("\n", "").split("=")[-1]))
            if "Validation" in line:
                val_acc.append(float(float(line.replace("\n", "").split("=")[-1])))
            if "Batch" in line and batch_num not in line:
                sd = float(line.split(":")[3].split(" ")[1])
                if sd >= 100.0:
                    speed.append(sd)
    

def print_result(result, label):
    if len(result) > 0:
        decimal = 2
        if label != "Throughput":
            decimal = 4
        max_num = round(max(result), decimal)
        min_num = round(min(result), decimal)
        mean_num = round(sum(result) / len(result), decimal)
        print(label + " : max=%s min=%s mean=%s" % (max_num, min_num, mean_num))


def parse_accuracy(acc_file):
    with open(acc_file, "r") as inf:
        accuracy = []
        for line in inf:
            if "Start" in line:
                setting = line.split(": ")[1].split("=")[0]
                print("=====%s=====" % setting)
            if "Validation-accuracy" in line:
                rank = int(re.search(r"Rank\[([0-9]+)\]", line).group(1))
                acc = float(line.split("=")[1])
                accuracy.append((rank, acc))
            if "Done" in line:
                if len(accuracy) > 0:
                    accuracy.sort(key=lambda tup: tup[1])
                    print("max=%s" % str(accuracy[-1]))
                    print("min=%s" % str(accuracy[0]))
                    print("")
                    accuracy = []


def parse_time(time_file, batch_size):
    with open(time_file, "r") as inf:
        train_time = []
        epoch_time = []
        train_speed = []
        epoch_speed = []
        cur_time_epoch = 0
        cur_speed_epoch = 0
        nbatch = 1
        num_gpus = 64
        for line in inf:
            if "Start" in line:
                print(line.replace("\n", ""))
                train_time = []
                epoch_time = []
                train_speed = []
                epoch_speed = []
                cur_time_epoch = 0
                cur_speed_epoch = 0

                num_gpus = 64
                act_gpu = re.search(r"GPU=([0-9]+)", line)
                if act_gpu is not None:
                    num_gpus = int(act_gpu.group(1))
                nbatch = int(math.ceil(int(SAMPLES // num_gpus) / batch_size))

            if "Time cost" in line:
                epoch = int(re.search(r"Epoch\[([0-9]+)\]", line).group(1))
                tc = float(line.split("=")[1])
                if epoch != cur_time_epoch:
                    train_time.append((cur_time_epoch, round(sum(epoch_time) / len(epoch_time), 2)))
                    cur_time_epoch = epoch
                    epoch_time = []
                epoch_time.append(tc)

            if "Speed" in line:
                epoch = int(re.search(r"Epoch\[([0-9]+)\]", line).group(1))
                sd = float(line.split(": ")[1].split(" ")[0])
                if epoch != cur_speed_epoch:
                    train_speed.append((cur_speed_epoch, round(sum(epoch_speed) / len(epoch_speed), 2)))
                    cur_speed_epoch = epoch
                    epoch_speed = []
                epoch_speed.append(sd)

            if "Done" in line:
                train_time.append((cur_time_epoch, round(sum(epoch_time) / len(epoch_time), 2)))
                train_time.sort(key=lambda tup: tup[1])
                all_time = [t for i, t in train_time if i != 0 and i != 90]
                avg_time = round(sum(all_time) / len(all_time), 2)
                print("max_time=%s" % str(train_time[-1]))
                print("min_time=%s" % str(train_time[0]))
                print("avg_time=%s" % str(avg_time))

                train_speed.append((cur_speed_epoch, round(sum(epoch_speed) / len(epoch_speed), 2)))
                train_speed.sort(key=lambda tup: tup[1])
                all_speed = [s for i, s in train_speed  if i != 0 and i != 90]
                avg_speed = round(sum(all_speed) / len(all_speed), 2)
                print("max_speed=%s" % str(train_speed[-1]))
                print("min_speed=%s" % str(train_speed[0]))
                print("avg_speed=%s" % str(avg_speed))

                speed_gpu = round(nbatch * batch_size / avg_time, 2)
                speed_node = speed_gpu * 8
                speed_train = speed_gpu * num_gpus

                print("speed_gpu=%s, speed_node=%s, speed_all=%s" %
                      (str(speed_gpu), str(speed_node), str(speed_train)))
                print("")


if __name__ == "__main__":
    if sys.argv[1] == "acc":
        parse_accuracy(sys.argv[2])
    elif sys.argv[1] == "time":
        parse_time(sys.argv[2], int(sys.argv[3]))
    else:
        if len(sys.argv) != 4:
            print("Usage: python parse_results.py <result_file> <epoch_num> <batch_num>")
            sys.exit()

        res_file = sys.argv[1]
        epoch_num = sys.argv[2]
        batch_num = sys.argv[3]
        parse(res_file, epoch_num, batch_num)
