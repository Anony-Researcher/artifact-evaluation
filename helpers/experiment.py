from prometheus_api_client import PrometheusConnect
from datetime import datetime
import pandas as pd
import subprocess, os, signal, sys, threading
import time
import argparse
import json, yaml
import matplotlib.pyplot as plt
import seaborn as sns

with open('experiment_params.yml', 'r') as file:
    parameters = yaml.safe_load(file)   
step = parameters['step']
precision = parameters['precision']
pre_experiment_sleep = parameters['pre_experiment_sleep']
between_script_sleep = parameters['between_script_sleep']
post_experiment_sleep = parameters['post_experiment_sleep']
collect_docker_stats_command = parameters['collect_docker_stats_command']
docker_stats_result = parameters['docker_stats_result']
system_metrics_url = parameters['system_metrics_url']
ethereum_metrics_url = parameters['ethereum_metrics_url']
good_contract = parameters['good_contract']
bad_contract = parameters['bad_contract']

should_exit = False
start_time = end_time = None
good_contract_start_time = good_contract_end_time = None
bad_contract_start_time = bad_contract_end_time = None

def signal_handler(sig, frame):
    global should_exit
    should_exit = True
    exit(1)

def run_command():
    print("command_thread started")
    while threading.main_thread().is_alive() and not should_exit:
        subprocess.run(collect_docker_stats_command, shell=True)
        time.sleep(15)
    print("command_thread exited")

def perform_experiment():
    global should_exit
    global start_time, end_time, good_contract_start_time, good_contract_end_time, bad_contract_start_time, bad_contract_end_time
    signal.signal(signal.SIGINT, signal_handler)

    start_time = datetime.now()

    command_thread = threading.Thread(target=run_command)
    command_thread.start()

    time.sleep(pre_experiment_sleep)

    good_contract_start_time = datetime.now()
    subprocess.run(["npx", "hardhat", "run", good_contract, "--network", "network1"], cwd = "../hardhat")
    good_contract_end_time = datetime.now()

    time.sleep(between_script_sleep)

    bad_contract_start_time = datetime.now()
    subprocess.run(["npx", "hardhat", "run", bad_contract, "--network", "network2"], cwd = "../hardhat")
    bad_contract_end_time = datetime.now()

    time.sleep(post_experiment_sleep)
    end_time = datetime.now()
    should_exit = True
    command_thread.join()

def plot_metrics(metrics_df, timestamps, metric_name, path):
    global good_contract_start_time, good_contract_end_time, bad_contract_start_time, bad_contract_end_time
    good_contract_duration = int((good_contract_end_time - good_contract_start_time).total_seconds())
    bad_contract_duration = int((bad_contract_end_time - bad_contract_start_time).total_seconds())
    good_contract_start_index = pre_experiment_sleep//15
    good_contract_end_index = good_contract_start_index + good_contract_duration//15
    bad_contract_start_index = good_contract_end_index + between_script_sleep//15
    bad_contract_end_index = bad_contract_start_index + bad_contract_duration//15

    timestamps = [x - timestamps[0] for x in timestamps]
    origin_index = pre_experiment_sleep//15 - 2 # this index will be the datapoint at the origin of graph. -2 to deal with edge cases (equivalent to including last 30 seconds of pre_experiment in graph)
    column_length = len(timestamps)
    df = pd.DataFrame()
    df['timestamp'] = timestamps[origin_index:]

    if metric_name == "gas":
        for column in metrics_df.columns:
            if column != "timestamp":
                df[f"node{column[26]}"] = metrics_df[column][origin_index:] # magic number 26. node1 corresponds to column ethereum-metrics-exporter-1-lighthouse-geth, 1 is the 26th character

    else:
        num_nodes = 0
        for column in metrics_df.columns:
            if (column.startswith('el-') or column.startswith('cl-') or column.startswith('vc-')) and column[3].isdigit():
                num_nodes = max(num_nodes, int(column[3]))
        
        temp_dict = {}
        for i in range(1, num_nodes + 1):
            temp_dict[f"node{i}"] = [0]*column_length
        
        for column in metrics_df.columns:
            if (column.startswith('el-') or column.startswith('cl-') or column.startswith('vc-')) and column[3].isdigit():
                temp_dict[f"node{column[3]}"] += metrics_df[column]
        
        for i in range(1, num_nodes + 1):
            baseline = sum(temp_dict[f"node{i}"][0:origin_index])/origin_index
            df[f"node{i}"] = [(temp_dict[f"node{i}"][j] - baseline) for j in range(origin_index, column_length)]
    
    df["node_sum"] = [0]*len(df["timestamp"])
    num_nodes = 0
    for column in df.columns:
        if column != "timestamp":
            num_nodes = num_nodes + 1
            df["node_sum"] += df[column]
    df["node_avg"] = [x/num_nodes for x in df["node_sum"]]

    new_df = pd.DataFrame()
    new_df['timestamp'] = df['timestamp']
    new_df['node_sum'] = df["node_sum"]
    new_df["node_avg"] = df["node_avg"]

    fig = plt.figure()
    ax1 = fig.add_subplot(111)
    ax2 = ax1.twiny()
    fig.subplots_adjust(bottom=0.2)
    ax2.spines["bottom"].set_position(("axes", -0.1))
    ax2.xaxis.set_ticks_position("bottom")
    ax2.spines["bottom"].set_visible(True)

    lp = sns.lineplot(x='timestamp', y='value', ax = ax1, hue='variable', data=pd.melt(new_df, ['timestamp']) )
    lp.set(xlabel=None)
    ax1.set_ylabel(metric_name)

    xticks = [timestamps[good_contract_start_index], timestamps[good_contract_end_index], timestamps[bad_contract_start_index], timestamps[bad_contract_end_index]]
    xticklabels = ["gcds", "gcde", "bcds", "bcde"]
    ax2.set_xticks(xticks)
    ax2.set_xticklabels(xticklabels, rotation=45, color='blue')
    ax2.set_xlim(ax1.get_xlim())
    ax1.axvline(xticks[0], linestyle='--')
    ax1.axvline(xticks[1], linestyle='--')
    ax1.axvline(xticks[2], linestyle='--')
    ax1.axvline(xticks[3], linestyle='--')

    plt.title(metric_name)
    plt.savefig(path + ".png", dpi=400, bbox_inches='tight')
    # plt.show()

def export_metrics(prom, query, group_by, experiments_folder, metric_name):
    global start_time, end_time
    data = prom.custom_query_range(query, start_time=start_time, end_time=end_time, step=step)
    container_data = {}
    min_len = float('inf')
    # print(data)
    for result in data:
        container = result['metric'][group_by]
        values = [float(sample[1]) for sample in result['values']]
        min_len = min(min_len, len(values))
        container_data[container] = values

    for container in container_data:
        container_data[container] = container_data[container][0:min_len]

    timestamps = [int(sample[0]) for sample in data[0]['values']][0:min_len]
    # print(timestamps)
    df = pd.DataFrame(container_data)
    df.insert(0, 'timestamp', timestamps)

    path = experiments_folder + metric_name
    df.to_csv(path + ".csv", index=False)
    plot_metrics(df, timestamps, metric_name, path)

    return timestamps


def export_disk_metrics(experiments_folder, timestamps, metric_name):
    # docker_stats.jsonl is a file where each line is a json object with the stats of a container
    # we will read this file and extract the BlockIO stats of each container and combine them into a single csv file
    # each column of the csv file is the name of a container and each row is a timestamp
    # we use the timestamps from the prometheus data
    with open(docker_stats_result, "r") as file:
        container_data = {}
        res_len = 0
        for line in file:
            stats = json.loads(line)
            container = stats['Name']
            if container not in container_data:
                container_data[container] = []
            # BlockIO is of the form 5.61MB / 30.8GB. we only want the first part
            # We also convert the number to be in terms of kB and just store the number without the unit
            blockio = stats['BlockIO']
            blockio = blockio.split(" / ")[0]
            if blockio[-2:] == "kB":
                blockio = float(blockio[:-2])
            elif blockio[-2:] == "MB":
                blockio = float(blockio[:-2]) * 1000
            elif blockio[-2:] == "GB":
                blockio = float(blockio[:-2]) * 1000 * 1000
            elif blockio[-1:] == "B":
                blockio = float(blockio[:-1]) / 1000
            
            if len(container_data[container]) < len(timestamps):
                container_data[container].append(blockio)
            res_len = len(container_data[container])

        df = pd.DataFrame(container_data)
        df.insert(0, 'timestamp', timestamps[0:res_len])

        path = experiments_folder + metric_name
        df.to_csv(path + ".csv", index=False)
        plot_metrics(df, df['timestamp'], metric_name, path)

def experiment_success(experiments_folder):
    global start_time, end_time, good_contract_start_time, good_contract_end_time, bad_contract_start_time, bad_contract_end_time
    with open(experiments_folder + "success", "w") as file:
        file.write(f"Experiment started at {start_time.strftime('%Y-%m-%d %H:%M:%S')} and ended at {end_time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        file.write(f"Good contract started at {good_contract_start_time.strftime('%Y-%m-%d %H:%M:%S')} and ended at {good_contract_end_time.strftime('%Y-%m-%d %H:%M:%S')} and took {(good_contract_end_time - good_contract_start_time).total_seconds():.2f} seconds\n")
        file.write(f"Bad contract started at {bad_contract_start_time.strftime('%Y-%m-%d %H:%M:%S')} and ended at {bad_contract_end_time.strftime('%Y-%m-%d %H:%M:%S')} and took {(bad_contract_end_time - bad_contract_start_time).total_seconds():.2f} seconds\n")
    print("Experiment finished")

def handle_args():
    parser = argparse.ArgumentParser(description="Process experiment results and store them in a specified folder.")
    parser.add_argument("folder_name", type=str, help="Folder name where experiment results will be stored")
    args = parser.parse_args()
    folder_name = args.folder_name
    if not folder_name:
        print("python3 experiment.py <folder_name>")
        exit(1)
    if not os.path.exists(f'../experiments/{folder_name}'):
        print(f"Folder {folder_name} does not exist")
        print("list of folders that exist: ", os.listdir('../experiments'))
        exit(1)
    try:
        system_prom = PrometheusConnect(url=system_metrics_url, disable_ssl=True)
        system_prom.custom_query("up")
    except:
        print(f"Invalid prometheus url: {system_metrics_url}")
        exit(1)
    try:
        ethereum_prom = PrometheusConnect(url=ethereum_metrics_url, disable_ssl=True)
        ethereum_prom.custom_query("up")
    except:
        print(f"Invalid prometheus url: {ethereum_metrics_url}")
        exit(1)
    if not os.path.exists(good_contract):
        print(f"File {good_contract} does not exist")
        exit(1)
    if not os.path.exists(bad_contract):
        print(f"File {bad_contract} does not exist")
        exit(1)
    
    return folder_name, system_prom, ethereum_prom

def main():
    folder_name, system_prom, ethereum_prom = handle_args()
    with open(docker_stats_result, "w") as file: # clear docker_stats.jsonl
        file.write("")

    experiments_folder = None
    print("starting experiment....")

    try:
        perform_experiment()
        experiments_folder = f'../experiments/{folder_name}/{start_time.strftime("%Y-%m-%d_%H-%M-%S")}/'
        os.mkdir(experiments_folder)
        
    except Exception as e:
        global should_exit
        print(f"An exception occurred in perform_experiment(): {e}")
        should_exit = True
        exit(1)

    cpu_query = f'sum(rate(container_cpu_usage_seconds_total{{instance=~".*",name=~".*",name=~".+"}}[{precision}])) by (name) * 100'
    mem_query = f'sum(container_memory_working_set_bytes{{instance=~".*",name=~".*",name=~".+"}}) by (name)'
    mem_cached_qeury = f'sum(container_memory_usage_bytes{{instance=~".*",name=~".*",name=~".+"}}) by (name)'
    recv_network_query = f'sum(rate(container_network_receive_bytes_total{{instance=~".*",name=~".*",name=~".+"}}[{precision}])) by (name)'
    send_network_query = f'sum(rate(container_network_transmit_bytes_total{{instance=~".*",name=~".*",name=~".+"}}[{precision}])) by (name)'
    gas_query = f'sum(eth_exe_block_head_gas_used) by (job)'

    timestamps = export_metrics(system_prom, cpu_query, "name", experiments_folder, "cpu_%")
    export_metrics(system_prom, mem_query, "name", experiments_folder, "mem_B")
    export_metrics(system_prom, mem_cached_qeury, "name", experiments_folder, "mem_cached_B")
    export_metrics(system_prom, recv_network_query, "name", experiments_folder, "recv_network_B")
    export_metrics(system_prom, send_network_query, "name", experiments_folder, "send_network_B")
    export_metrics(ethereum_prom, gas_query, "job", experiments_folder, "gas")
    export_disk_metrics(experiments_folder, timestamps, "blockIO_kB")

    experiment_success(experiments_folder)
    
if __name__ == "__main__":
    main()
