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


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python parse_results.py <result_file> <epoch_num> <batch_num>")
        sys.exit()

    res_file = sys.argv[1]
    epoch_num = sys.argv[2]
    batch_num = sys.argv[3]
    parse(res_file, epoch_num, batch_num)
