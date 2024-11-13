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


def process_file(filename):
    gpu_tot_sim_cycle_sum = 0
    gpu_tot_sim_insn_sum = 0

    try:
        with open(filename, 'r') as f:
            for line in f:
                line = line.strip()
                if line.startswith('gpu_tot_sim_cycle ='):
                    parts = line.split('=')
                    if len(parts) == 2:
                        value = int(parts[1].strip())
                        gpu_tot_sim_cycle_sum += value
                elif line.startswith('gpu_tot_sim_insn ='):
                    parts = line.split('=')
                    if len(parts) == 2:
                        value = int(parts[1].strip())
                        gpu_tot_sim_insn_sum += value
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.", file=sys.stderr)
        return

    if gpu_tot_sim_cycle_sum == 0:
        total_ipc = 0.0
    else:
        total_ipc = gpu_tot_sim_insn_sum / gpu_tot_sim_cycle_sum

    #benchmark_name = extract_benchmark_name(filename)
    benchmark_name, config_name = extract_benchmark_and_config(filename);

    # Print the results as a space-delimited CSV row
    print(f"{benchmark_name} {config_name} {gpu_tot_sim_insn_sum} {gpu_tot_sim_cycle_sum} {total_ipc}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: script.py filename1 [filename2 ...]")
        sys.exit(1)

    for filename in sys.argv[1:]:
        process_file(filename)

