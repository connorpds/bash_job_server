#!/usr/bin/env python3

import sys
import re
import os

def extract_benchmark_name(filename):
    # Extract the substring up to the first underscore
    idx = filename.find('.')
    if idx == -1:
        benchmark_name = filename
    else:
        benchmark_name = filename[:idx]
        # If the underscore is immediately preceded by a hyphen, omit the hyphen
        if benchmark_name.endswith('-'):
            benchmark_name = benchmark_name[:-1]
    return benchmark_name


def extract_benchmark_and_config(filepath):
    filename = os.path.basename(filepath)
    # Define the regular expression pattern
    pattern = r"(.+?)_(BASELINE|VELRR_ONLY|VELRU_L1|VELRR_VELRU_L1)\.dat"
    
    # Match the pattern against the filename
    match = re.match(pattern, filename)
    if match:
        benchmark_name = match.group(1)  # Extracts BENCHMARK-NAME
        config_name = match.group(2)     # Extracts CONFIG
        return benchmark_name, config_name
    else:
        return None, None  # Return None if the pattern doesn't match


def process_simfile(filename):
    pattern = re.compile(r'gpu_tot_ipc\s*=\s*([^\s#]+)', re.IGNORECASE)
    last_value = None
    try:
        with open(filename, 'r') as file:
            for line_number, line in enumerate(file, 1):
                match = pattern.search(line)
                if match:
                    last_value_str = match.group(1)
                    # Attempt to convert to float or int
                    try:
                        if '.' in last_value_str:
                            last_value = float(last_value_str)
                        else:
                            last_value = int(last_value_str)
                    except ValueError:
                        # If conversion fails, keep it as a string
                        last_value = last_value_str
    except FileNotFoundError:
        print(f"Error: The file '{filename}' does not exist.")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None
    return last_value


def calculate_ipc_improvement(workload, config, kernel_ipcs):
    #print(workload)
    #print(kernel_ipcs)
    #print("_________________")
    baseline_ipc = kernel_ipcs[(workload, 'BASELINE')]
    augment_ipc = kernel_ipcs[(workload, config)]
    if (baseline_ipc != 0):
        return augment_ipc / baseline_ipc
    else:
        return 1.0

def parse_last_tot_ipc(simfile):
    benchmark_name, config_name = extract_benchmark_and_config(simfile) 
    total_ipc = process_simfile(simfile)
    return total_ipc, benchmark_name, config_name

def generate_kernel_improvements(simfiles):
    kernel_ipcs = dict()
    for filename in simfiles:
        benchmark_name, config_name = extract_benchmark_and_config(filename)
        total_ipc = process_simfile(filename)
        name_conf = (benchmark_name, config_name)
        kernel_ipcs[name_conf] = total_ipc
        
    improvements = dict()
    for workload, config in kernel_ipcs:
        ipcs = kernel_ipcs[(workload, config)]
        n_conf = (workload, config)
        improvements[n_conf] = calculate_ipc_improvement(workload, config, kernel_ipcs)
    #print (improvements)
    return improvements


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: script.py filename1 [filename2 ...]")
        sys.exit(1)

    total_ipc, benchmark_name, config_name = parse_last_tot_ipc(sys.argv[1])
    #print("Workload\t Configuration\t, IPC")
    print(benchmark_name, config_name, total_ipc)
    
    
   
