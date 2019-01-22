import re
import sys


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


def parse_time(time_file):
    with open(time_file, "r") as inf:
        train_time = []
        epoch_time = []
        cur_epoch = 0
        for line in inf:
            if "Start" in line:
                print(line.replace("\n", ""))
            if "Time cost" in line:
                epoch = int(re.search(r"Epoch\[([0-9]+)\]", line).group(1))
                tc = float(line.split("=")[1])
                if epoch != cur_epoch:
                    train_time.append((cur_epoch, round(sum(epoch_time) / len(epoch_time), 2)))
                    cur_epoch = epoch
                    epoch_time = []
                epoch_time.append(tc)
            if "Done" in line:
                samples = 1281167
                train_time.sort(key=lambda tup: tup[1])
                print("max=%s" % str(train_time[-1]))
                print("min=%s" % str(train_time[0]))
                print("speed=%s" % str(round(samples / train_time[0][1], 2)))
                print("")
                train_time = []


if __name__ == "__main__":
    if sys.argv[1] == "acc":
        parse_accuracy(sys.argv[2])
    elif sys.argv[1] == "time":
        parse_time(sys.argv[2])
    else:
        if len(sys.argv) != 4:
            print("Usage: python parse_results.py <result_file> <epoch_num> <batch_num>")
            sys.exit()

        res_file = sys.argv[1]
        epoch_num = sys.argv[2]
        batch_num = sys.argv[3]
        parse(res_file, epoch_num, batch_num)
